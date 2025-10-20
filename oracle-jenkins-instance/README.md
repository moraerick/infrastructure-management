
# Oracle Jenkins Instance (Terraform)

  

This project provisions an Ubuntu instance on **Oracle Cloud Infrastructure (OCI)** using **Terraform**, with **Jenkins** pre-installed and accessible via the public IP.

  

## Overview

  

- A compute instance (Ubuntu 22.04)

- Network interfaces within an existing subnet

- Optional security rules for HTTP (port 8080)

- A startup-ready environment where Jenkins can be installed automatically or manually using the provided script

  

---

  

## Prerequisites

  

Before running Terraform, ensure the following:

  

### Oracle Cloud Infrastructure (OCI)

1. You have an active **Oracle Cloud Free Tier** or paid account.

2. You have created:

- A **Compartment**

- A **Virtual Cloud Network (VCN)**

- A **Subnet** (with Internet access)

3. You have the **Subnet OCID** available.

  

### Network Configuration

Your subnet or its associated security list must allow **ingress** and **egress** traffic for Jenkins.

  

Recommended ingress rules:

  

| Protocol | Port | Source | Description |

|-----------|------|---------------|----------------------|

| TCP         | 22   | 0.0.0.0/0     | SSH access           |

| TCP         | 8080 | 0.0.0.0/0 | Jenkins web access |

  

You can add these using the OCI Console under:

`Networking → Virtual Cloud Networks → <Your VCN> → Security Lists → <Your Security List>`

  

---

  

## Files Structure

  

infrastructure-management/

└── oracle-jenkins-instance/

├── main.tf

├── variables.tf

├── terraform.tfvars

├── backend.tf

├── install_jenkins.sh

└── README.md

  
  
  

-  **main.tf**: Defines the OCI compute instance and resources.

-  **variables.tf**: Input variables for configuration.

-  **terraform.tfvars**: User-provided values for authentication and environment details.

-  **backend.tf**: Defines the remote Terraform state backend in an OCI Object Storage bucket.

-  **install_jenkins.sh**: Script to install and configure Jenkins on Ubuntu.

  

---

  

## Terraform Configuration

  

### 1. Edit `terraform.tfvars`

  

Provide your OCI credentials and instance parameters:

  


    tenancy_ocid = "ocid1.tenancy.oc1..xxxx"
    
    user_ocid = "ocid1.user.oc1..xxxx"
    
    fingerprint = "xx:xx:xx:xx:xx:xx:xx:xx"
    
    private_key_path = "/home/ubuntu/.oci/oci_api_key.pem"
    
    region = "us-ashburn-1"
    
    compartment_ocid = "ocid1.compartment.oc1..xxxx"
    
    subnet_ocid = "ocid1.subnet.oc1..xxxx"
    
    ssh_public_key_path = "/home/ubuntu/.ssh/id_rsa.pub"



### 2. Configure Backend (optional)

If you want to store the Terraform state remotely in OCI Object Storage, your `backend.tf` should look like:

    `terraform {
      backend "oci" {
        bucket         = "terraform-state-bucket"
        namespace      = "your_namespace"
        compartment_ocid = "ocid1.compartment.oc1..xxxx"
        region         = "us-ashburn-1"
        key            = "jenkins/terraform.tfstate"
      }
    }` 

----------

## Deployment Steps

### 1. Initialize Terraform

`terraform init` 

### 2. Validate Configuration

`terraform validate` 

### 3. Plan Resources

`terraform plan` 

### 4. Apply the Configuration

`terraform apply` 

Terraform will:

-   Provision an Ubuntu 22.04 instance
    
-   Attach the SSH key
    
-   Assign a public IP
    
-   Use your existing subnet
    

Once complete, note the **public IP address** in the output.

----------

## Installing Jenkins

After the instance is created:

1.  Connect via SSH:
    
    `ssh -i ~/.ssh/id_rsa ubuntu@<public_ip>` 
    
2.  Copy the installation script (if not already deployed):
    
    `scp -i ~/.ssh/id_rsa install_jenkins.sh ubuntu@<public_ip>:~` 
    
3.  Make it executable:
    
    `chmod +x install_jenkins.sh` 
    
4.  Run the installer:
    
    `sudo ./install_jenkins.sh` 
    

This script will:

-   Install OpenJDK 21
    
-   Install Jenkins and start the service
    
-   Configure the firewall to open port 8080
    
-   Display the initial Jenkins admin password
    

----------

## Accessing Jenkins

Open a browser and visit:

`http://<public_ip>:8080` 

When prompted for the admin password, retrieve it from your instance:

`sudo cat /var/lib/jenkins/secrets/initialAdminPassword` 

Use that password to complete the Jenkins setup wizard.

----------

## Cleanup

To remove all resources created by Terraform:

`terraform destroy` 

----------

## Notes

-   Ensure the subnet has Internet access for Jenkins installation.
    
-   If using Oracle Free Tier, select the `VM.Standard.E2.1.Micro` shape to remain within the free limits.
    
-   Always store your private keys securely and do not commit them to version control.