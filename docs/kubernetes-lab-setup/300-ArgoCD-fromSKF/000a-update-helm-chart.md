```

#!/bin/sh

## USAGE:

## ./update-helm-chart.sh helm-chart-name subfolder
## ./update-helm-chart.sh cert-manager platform-components
## ./update-helm-chart.sh argo-cd

source ./create-work-item-and-pr-for-helm-chart.sh

set -x

## Take first argument as name of helm chart.
## Take second argument as old folder name.

X=$1
SUBFOLDER=$2

## If $SUBFOLDER is not empty, add it to the end of $X

if [ -n "$SUBFOLDER" ]; then
  cd $SUBFOLDER
fi

if [ -z "$X" ]
then
      echo "Please provide a value for the helm chart"
      exit 1
fi

## This will grep the last version.
for i in $(ls -d */ | grep $X); do
  echo $i
  Y=$i
done

echo $Y
CHART_VERSION_OLD=$(echo $Y | grep -o '[0-9]\+[.][0-9]\+[.][0-9]\+')

REPO_URL=https://skfxz98ahelmstg.blob.core.windows.net/helm
REPO_NAME=skf
CREATE_WORK_ITEM=true
NAME=$X

## Download latest helm chart and extract it to a folder
TEMP_DIR=tempforhelm
mkdir $TEMP_DIR

helm repo add $REPO_NAME $REPO_URL
helm repo update $REPO_NAME
helm pull $REPO_NAME/$NAME --destination ./$TEMP_DIR/

tar zxvf $TEMP_DIR/* -C $TEMP_DIR/

# Get the Chart Version from the downloaded chart
CHART_VERSION=$(yq e '.version' $TEMP_DIR/$NAME/Chart.yaml)
echo "Old chart version: $CHART_VERSION_OLD"
echo "New chart version: $CHART_VERSION"
# echo this out to be used for deployment stage
echo "##vso[task.setvariable variable=newChartVersion;isOutput=true]$CHART_VERSION"
echo "##vso[task.setvariable variable=oldChartVersion;isOutput=true]$CHART_VERSION_OLD"

# If $FOLDER_NAME exists, exit
if [ -d "$NAME-$CHART_VERSION" ]; then
  echo "Folder $NAME-$CHART_VERSION already exists. Exiting."
  rm -rf $TEMP_DIR
  # echo this to skip running update-helm-chart-azdo.sh if no upgrade
  echo "##vso[task.setvariable variable=skipAzdo]Yes"
  echo "##vso[task.setvariable variable=deploy;isOutput=true]No"
  exit 0
else
  echo "Folder $NAME-$CHART_VERSION not yet exists. Preparing..."
  echo "##vso[task.setvariable variable=deploy;isOutput=true]Yes"
fi

FOLDER_NAME=$NAME-$CHART_VERSION

cp -r $Y $FOLDER_NAME

# Download values.yaml and chart.yaml
# curl -s $VALUES_YAML > $NAME/values.yaml
# curl -s $CHART_YAML > $NAME/chart.yaml
## Prefix cp with \ to avoid having to confirm.
\cp $TEMP_DIR/$NAME/values.yaml $FOLDER_NAME/values.yaml
\cp $TEMP_DIR/$NAME/Chart.yaml $FOLDER_NAME/Chart.yaml

git add $FOLDER_NAME
git commit -m "Preparing $NAME-$CHART_VERSION helm chart for deployment"
git push origin HEAD:master

# Convert values.yaml to json
yq -o json $FOLDER_NAME/values.yaml > $FOLDER_NAME/values-temp.libsonnet

# Run jsonnetfmt on the file
jsonnetfmt $FOLDER_NAME/values-temp.libsonnet > $FOLDER_NAME/values.libsonnet
rm $FOLDER_NAME/values-temp.libsonnet

echo $CHART_VERSION

# Create json file with $REPO_URL and $CHART_VERSION using jq

cat << EOF > $FOLDER_NAME/parameters.json
{
  "repository": "$REPO_URL",
  "name": "$NAME",
  "version": "$CHART_VERSION"
}
EOF

# If $NAME/customizations.libsonnet does not exist, copy template/customizations.libsonnet there
if [ ! -f "$FOLDER_NAME/customizations.libsonnet" ]; then
    cp template/customizations.libsonnet $FOLDER_NAME/customizations.libsonnet
fi

# If $NAME/chart.libsonnet does not exist, copy template/chart.libsonnet there
if [ ! -f "$FOLDER_NAME/chart.libsonnet" ]; then
    cp template/chart.libsonnet $FOLDER_NAME/chart.libsonnet
fi

BRANCH_NAME=platform-component-upgrade/add-update-$NAME-$CHART_VERSION
git branch $BRANCH_NAME
git checkout $BRANCH_NAME

git add $FOLDER_NAME/
git commit -m "Add $NAME chart version $CHART_VERSION"
git push origin HEAD:$BRANCH_NAME

rm -rf $TEMP_DIR



```

