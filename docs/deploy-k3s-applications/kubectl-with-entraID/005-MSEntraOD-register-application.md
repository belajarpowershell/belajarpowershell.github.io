### **1. Set Up an App Registration in Azure Entra ID**

1. **Go to Azure Portal**:
   - Navigate to **Azure Entra ID** > **App registrations**.
2. **Register a New Application**:
   - Click **New registration**.
   - **Name**: Choose a descriptive name (e.g., `k3s-oidc-auth`).
   - **Supported account types**: Select **Accounts in this organizational directory only** (single tenant).
   - **Redirect URI**: Leave blank for now; k3s doesn’t require it.
   - Click **Register**.
3. **Save Key Info**:
   - After registration, note down the **Application (client) ID** and **Directory (tenant) ID**—you’ll need these for the k3s configuration.

```
applicationID ( clientid) :
export clientid=818d5892-ec0d-46ba-b886-cfb68cd0b79c
Directory (tenantID): 
export tenantID=a01c77f7-d822-4d88-88fd-9a738c46e3ab
```



### **2. Configure API Permissions**

1. In the app registration:
   - Go to **API permissions** > **Add a permission**.
   - Choose **Microsoft Graph** > **Delegated permissions**.
   - Add the following permissions:
     - `openid`
     - `profile`
     - `email`
   - Click **Grant admin consent** to approve the permissions.



### **3. Create a Client Secret**

1. Go to **Certificates & secrets** in your app registration.
2. Click **New client secret**.
3. Provide a description (e.g., `k3s-secret`) and set an expiry period.
4. Click **Add** and copy the generated secret—**you won’t be able to see it again**.

```

export secretid="
export value=""
```

