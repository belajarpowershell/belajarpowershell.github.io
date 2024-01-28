## Welcome to Kubernetes Lab Setup

As part of my training material I have a need to setup Kubernetes infrastructure quickly. As this is a learning platform there is a need to destroy and rebuild multiple times. 

This repository is for my documentation on the setup steps.

The information is provided such that one can replicate this same setup easily. 

Here are some high level on the Kubernetes Lab setup. 

1. the Infrastructure is setup on HyperV, there is little information available for Hyper V environments . It took quite an effort to test , verify and document the stesp.

2. The Kubernetes setup is for a single node and a High Availability setup. The Lightweight Kubernetes is deployed. [Lightweight Kubernetes](https://k3s.io/)

3. The Virtual Machines are setup with Ubuntu 20.04.

4. Alpine Virtual Machine is used for the management and Loadbalancer Virtual Machines.
