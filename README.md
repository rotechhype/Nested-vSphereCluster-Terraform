# Nested-vSphereCluster-Terraform
Using this terraform module you can deploy a nested vSAN cluster in minutes to use it for any testing. 
Requirments : 
1. At least one ESXi host inside a cluster where all nested VMs will run
2. vCenter server
3. Nested ESXi Virtual Appliance which can be downloaded from [here](https://community.broadcom.com/flings/home) (Broadcom account required)
4. Terraform

The ESXi host need to be managed by your vCenter and added into a cluster, even if is 1 node cluster.

How to use: 

1. [Install Terraform ](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
2. Download ESXi Virtual appliance from here [Broadcom Flings](https://community.broadcom.com/flings/home)
3. Clone the repository `git clone https://github.com/rotechhype/Nested-vSphereCluster-Terraform.git`
4. Initialize terraform `terraform init`
5. In same folder with the repository, create a new folder called "ova" and place the ova file you downloaded on step 2.
6. Edit esxihosts.auto.tfvars according to your needs
7. Run terraform plan and check if this is the desired result. `terraform plan`
8. After you check the plan, apply it and deploy the nested environment. `terraform apply`
