# Oracle Cloud Jenkins Instance

Terraform module to provision a fully configured **Jenkins CI server** on Oracle Cloud Infrastructure (OCI) using the Always Free tier. Includes automated Jenkins installation and firewall configuration via a bootstrap shell script.

## What this does

1. Looks up the latest **Ubuntu 22.04 AMD64** image available in your OCI tenancy
2. Provisions a **VM.Standard.E2.1.Micro** compute instance (Always Free eligible)
3. Assigns a public IP and configures SSH access within an existing subnet
4. Bootstraps the instance with Java 21 + Jenkins LTS via `scripts/install_jenkins.sh`
5. Configures **firewalld** to expose Jenkins on port 8080

## Architecture

```
OCI Tenancy
└── Compartment
    └── VCN / Subnet
        └── VM.Standard.E2.1.Micro (Ubuntu 22.04)
            ├── Java 21 (OpenJDK)
            ├── Jenkins LTS
            └── firewalld → port 8080 open
```

---

## Prerequisites

### Oracle Cloud Infrastructure

- An active OCI Free Tier or paid account
- A **Compartment**, **VCN**, and **Subnet** (with Internet access) already created
- The **Subnet OCID** available
- OCI API key credentials (tenancy OCID, user OCID, fingerprint, private key)

### Network — recommended ingress rules

| Protocol | Port | Source    | Description      |
|----------|------|-----------|------------------|
| TCP      | 22   | 0.0.0.0/0 | SSH access       |
| TCP      | 8080 | 0.0.0.0/0 | Jenkins web UI   |

Add these in the OCI Console under:
`Networking → Virtual Cloud Networks → <Your VCN> → Security Lists`

### Local tools

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- SSH key pair

---

## File Structure

```
oracle-jenkins-instance/
├── main.tf                  # OCI compute instance and data sources
├── variables.tf             # Input variable definitions
├── outputs.tf               # Output values (e.g. public IP)
├── provider.tf              # OCI provider configuration
├── terraform.tfvars         # Your values (gitignored)
├── terraform.tfvars.example # Reference template
├── backend.tf               # Remote state config (OCI Object Storage)
└── scripts/
    └── install_jenkins.sh   # Bootstrap: Java + Jenkins + firewalld
```

---

## Usage

### 1. Clone the repo

```bash
git clone https://github.com/moraerick/infrastructure-management.git
cd infrastructure-management/oracle-jenkins-instance
```

### 2. Configure variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
tenancy_ocid          = "ocid1.tenancy.oc1..xxxxx"
user_ocid             = "ocid1.user.oc1..xxxxx"
fingerprint           = "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
private_key_path      = "~/.oci/oci_api_key.pem"
region                = "us-ashburn-1"
compartment_ocid      = "ocid1.compartment.oc1..xxxxx"
subnet_ocid           = "ocid1.subnet.oc1..xxxxx"
ssh_public_key_path   = "~/.ssh/id_rsa.pub"
ssh_public_key        = "ssh-rsa AAAA..."
instance_display_name = "jenkins-instance"
instance_shape        = "VM.Standard.E2.1.Micro"
```

### 3. (Optional) Configure remote state

If you want to store Terraform state in OCI Object Storage, configure `backend.tf`:

```hcl
terraform {
  backend "oci" {
    bucket           = "terraform-state-bucket"
    namespace        = "your_namespace"
    compartment_ocid = "ocid1.compartment.oc1..xxxxx"
    region           = "us-ashburn-1"
    key              = "jenkins/terraform.tfstate"
  }
}
```

### 4. Deploy

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

Once complete, note the **public IP address** from the output.

---

## Variables

| Variable | Description | Default |
|---|---|---|
| `tenancy_ocid` | OCID of your OCI tenancy | required |
| `user_ocid` | OCID of the OCI user | required |
| `fingerprint` | API key fingerprint | required |
| `private_key_path` | Path to OCI API private key | required |
| `region` | OCI region | `us-ashburn-1` |
| `compartment_ocid` | OCID of the target compartment | required |
| `subnet_ocid` | OCID of the subnet for the instance | required |
| `ssh_public_key_path` | Path to your SSH public key file | required |
| `ssh_public_key` | SSH public key string | required |
| `instance_shape` | OCI compute shape | `VM.Standard.E2.1.Micro` |
| `instance_display_name` | Display name for the instance | `jenkins-instance` |

---

## Installing Jenkins

The `scripts/install_jenkins.sh` bootstrap script handles the full Jenkins setup. Run it manually after provisioning:

### 1. Connect via SSH

```bash
ssh -i ~/.ssh/id_rsa ubuntu@<public_ip>
```

### 2. Copy the script (if not already on the instance)

```bash
scp -i ~/.ssh/id_rsa scripts/install_jenkins.sh ubuntu@<public_ip>:~
```

### 3. Run the installer

```bash
chmod +x install_jenkins.sh
sudo ./install_jenkins.sh
```

The script will:
- Install OpenJDK 21
- Add the Jenkins LTS apt repository and install Jenkins
- Enable and start the Jenkins service
- Configure firewalld to open port 8080
- Display the initial admin password

---

## Accessing Jenkins

Open a browser and visit:

```
http://<public_ip>:8080
```

Retrieve the initial admin password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Use that password to complete the Jenkins setup wizard.

---

## Cleanup

```bash
terraform destroy
```

---

## Notes

- `VM.Standard.E2.1.Micro` is part of OCI's **Always Free** tier — no cost to run this
- `terraform.tfvars` is gitignored — never commit credentials
- The `user_data` cloud-init block is commented out in `main.tf` — the bootstrap script can alternatively be triggered via that mechanism for a fully zero-touch deployment
- `preserve_boot_volume = false` ensures the boot volume is deleted on termination to avoid orphaned storage costs
- Ensure the subnet has internet access for package installation during bootstrap

---

## Stack

- **Cloud:** Oracle Cloud Infrastructure (OCI)
- **IaC:** Terraform
- **OS:** Ubuntu 22.04 LTS
- **Runtime:** Java 21 (OpenJDK)
- **CI Server:** Jenkins LTS
- **Firewall:** firewalld

---

## Author

**Erick Mora** — DevOps Engineer  
[GitHub](https://github.com/moraerick) · [Upwork](https://www.upwork.com/freelancers/~0149e55b219704f472)
