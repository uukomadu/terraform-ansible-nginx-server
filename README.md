# Overview

This repository contains Terraform and Ansible code that provisions and configures a web server on AWS.

# Objective

Use Terraform to provision the AWS infrastructure and use Ansible to configure an Ubuntu EC2 instance as an Nginx web server that displays `Hello, World!`.

The deployment includes:

1. An S3 bucket used exclusively for Terraform remote state.
2. One Terraform-managed Ubuntu EC2 web server.
3. One security group that permits web and administrative access.
4. One manually created EC2 instance that acts as the Ansible controller.
5. An Ansible playbook that installs Nginx and deploys the required webpage.

# Submission

1. A private GitHub repository containing the Terraform and Ansible code.
2. This README file with instructions for:

- Setting up the environment
- Deploying the infrastructure
- Configuring the web server
- Understanding the Terraform and Ansible code

3. The URL of the deployed webpage.
4. Repository access for the project mentor.

# Solution Overview

The bootstrap Terraform configuration creates a private, encrypted, versioned S3 bucket for remote Terraform state. The root Terraform configuration uses that backend and provisions an Ubuntu EC2 web server in the account's default VPC.

Terraform uses an existing public subnet, route table, and internet gateway. It adds the default internet route required by the subnet, creates the web server security group, and launches the EC2 instance with a public IP address.

A separate, manually created Ubuntu EC2 instance acts as the Ansible controller. The controller connects to the Terraform-managed web server over SSH, installs Nginx, creates `/var/www/html/index.html`, and ensures Nginx is enabled and running.

The deployed application is available at:

```text
http://52.15.97.214
```

The current deployment uses HTTP. A production deployment should use a domain name, a valid TLS certificate, and HTTPS.

# Architecture

The AWS environment includes:

1. The default VPC with CIDR range `172.31.0.0/16`
2. An existing public subnet with CIDR range `172.31.96.0/20`
3. An existing internet gateway attached to the default VPC
4. An existing route table associated with the public subnet
5. A Terraform-managed default route to the internet gateway
6. One Terraform-managed Ubuntu 22.04 `t3.micro` web server
7. One manually created Ubuntu EC2 Ansible controller
8. One Terraform-managed security group for the web server
9. One private, encrypted, versioned S3 bucket for Terraform state

The configuration flow is:

```text
Developer Mac
   |
   |-- Terraform --> AWS infrastructure
   |
   `-- Project files --> Ansible controller
                            |
                            `-- SSH/Ansible --> EC2 web server --> Nginx --> Hello, World!
```

# Repository Structure

```text
devops-code-challenge3/
|-- bootstrap/
|   |-- main.tf
|   |-- outputs.tf
|   |-- providers.tf
|   `-- variables.tf
|-- .gitignore
|-- inventory.ini
|-- main.tf
|-- outputs.tf
|-- playbook.yaml
|-- providers.tf
|-- variables.tf
`-- README.md
```

# Tools Needed

The following tools and resources are required:

1. Git
2. GitHub account
3. AWS account
4. AWS CLI v2
5. Terraform 1.5 or newer
6. Ansible on the Ansible controller
7. An EC2 key pair named `P3` in `us-east-2`
8. The matching `P3.pem` private key stored securely outside the repository
9. An existing public subnet with CIDR `172.31.96.0/20` in the default VPC

Verify the local tools:

```bash
git --version
aws --version
terraform --version
```

Verify Ansible on the controller:

```bash
ansible --version
ansible-playbook --version
```

# AWS CLI Setup

Configure the AWS CLI on the local computer:

```bash
aws configure
```

Enter the IAM access key, secret access key, default region, and output format when prompted. This project uses `us-east-2`.

Verify the AWS identity:

```bash
aws sts get-caller-identity
```

Verify that the `P3` key pair exists:

```bash
aws ec2 describe-key-pairs \
  --key-names P3 \
  --region us-east-2
```

# Terraform State Bootstrap

Terraform cannot use an S3 backend until the bucket already exists. The `bootstrap` directory is therefore applied first using local state.

Enter the bootstrap directory:

```bash
cd bootstrap
```

Initialize and validate the bootstrap configuration:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

Create the state bucket:

```bash
terraform apply
```

Enter `yes` when prompted.

The bootstrap configuration creates the bucket named:

```text
tech-challenge-3-506570851351-tfstate
```

The bucket has versioning, AES-256 server-side encryption, and S3 Block Public Access enabled. Its only purpose is to store the root Terraform state. The EC2 instances do not require access to this bucket.

Return to the project root:

```bash
cd ..
```

# Terraform Guide

Initialize the root configuration and connect it to the S3 backend:

```bash
terraform init -reconfigure
```

Format and validate the Terraform files:

```bash
terraform fmt -recursive
terraform validate
```

Preview the infrastructure:

```bash
terraform plan
```

Create the infrastructure:

```bash
terraform apply
```

Enter `yes` when prompted.

Display the Terraform outputs:

```bash
terraform output
```

Useful individual outputs include:

```bash
terraform output -raw instance_id
terraform output -raw public_ip
terraform output -raw public_dns
terraform output -raw website_url
```

# Terraform Code Explanation

The `providers.tf` file configures Terraform, the AWS provider, and the S3 backend. The backend stores the root state at `dev/terraform.tfstate` and uses S3 state locking.

The `variables.tf` file defines the AWS region, project name, and environment. Default values keep the example simple while allowing them to be overridden.

The `main.tf` file performs the following tasks:

1. Locates the most recent Canonical Ubuntu 22.04 amd64 AMI.
2. Locates the default VPC.
3. Locates the existing `172.31.96.0/20` public subnet.
4. Locates the VPC's existing internet gateway.
5. Locates the route table associated with the public subnet.
6. Adds the `0.0.0.0/0` route required for internet access.
7. Creates the web server security group.
8. Creates the Ubuntu `t3.micro` EC2 web server with a public IP address.

The `outputs.tf` file displays the instance ID, networking resource IDs, public IP address, public DNS name, website URL, and an example SSH command.

The web server does not call AWS APIs, so it does not need an EC2 IAM role or instance profile. AWS credentials must not be stored on either EC2 instance.

# Connect to the Web Server

Secure the private key on the local computer:

```bash
chmod 400 ~/Downloads/P3.pem
```

Connect to the Terraform-managed web server:

```bash
ssh -i ~/Downloads/P3.pem ubuntu@52.15.97.214
```

Exit after verifying the connection:

```bash
exit
```

# Ansible Controller Setup

This project uses a manually created Ubuntu EC2 instance as the Ansible controller. Its current public IP address is:

```text
3.144.30.78
```

Connect to the Ansible controller:

```bash
ssh -i ~/Downloads/P3.pem ubuntu@3.144.30.78
```

Install Ansible:

```bash
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y ansible
ansible --version
```

Exit back to the local computer:

```bash
exit
```

# Copy the Ansible Files

From the project root on the local computer, copy the inventory, playbook, and SSH key to the Ansible controller:

```bash
scp -i ~/Downloads/P3.pem \
  inventory.ini \
  playbook.yaml \
  ~/Downloads/P3.pem \
  ubuntu@3.144.30.78:/home/ubuntu/
```

Connect to the controller and secure the private key:

```bash
ssh -i ~/Downloads/P3.pem ubuntu@3.144.30.78
mkdir -p ~/.ssh
mv ~/P3.pem ~/.ssh/P3.pem
chmod 400 ~/.ssh/P3.pem
```

Private keys must never be committed to GitHub.

# Ansible Inventory

The `inventory.ini` file defines the Terraform-managed web server and its SSH settings:

```ini
[webservers]
52.15.97.214

[webservers:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/home/ubuntu/.ssh/P3.pem
```

When both instances are in the same VPC, the web server's private IP can be used instead of its public IP. This keeps Ansible traffic inside the VPC.

# Ansible Playbook

The `playbook.yaml` file performs the following configuration:

1. Refreshes the Ubuntu APT package cache.
2. Installs Nginx.
3. Writes an HTML page to `/var/www/html/index.html`.
4. Displays `Hello, World!` in the webpage.
5. Starts Nginx and enables it at boot.

The playbook uses privilege escalation because installing packages and writing to `/var/www/html` require root permissions.

# Test Ansible Connectivity

From the Ansible controller, establish the first trusted SSH connection to the web server:

```bash
ssh -i ~/.ssh/P3.pem ubuntu@52.15.97.214
```

Enter `yes` after verifying the host fingerprint, then exit:

```bash
exit
```

Test the Ansible connection:

```bash
ansible webservers -i ~/inventory.ini -m ping
```

A successful test returns:

```text
52.15.97.214 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

# Deploy the Webpage

Run the playbook from the Ansible controller:

```bash
ansible-playbook -i ~/inventory.ini ~/playbook.yaml
```

The play recap should report:

```text
failed=0
unreachable=0
```

Running the playbook again should produce few or no changes because the tasks are idempotent.

# Verify the Deployment

Verify the website from the Ansible controller:

```bash
curl http://52.15.97.214
```

The response should contain:

```html
<h1>Hello, World!</h1>
```

Verify the Nginx service through Ansible:

```bash
ansible webservers -i ~/inventory.ini \
  --become \
  --module-name service \
  --args "name=nginx state=started enabled=true"
```

Open the public website in a browser:

```text
http://52.15.97.214
```

# Troubleshooting

If Terraform cannot create the EC2 instance because no default subnet exists, verify that the subnet configured in `main.tf` exists:

```bash
aws ec2 describe-subnets \
  --filters Name=cidr-block,Values=172.31.96.0/20 \
  --region us-east-2
```

If the EC2 instance cannot reach the internet, verify that its route table contains a default route to the VPC internet gateway:

```bash
aws ec2 describe-route-tables \
  --route-table-ids "$(terraform output -raw route_table_id)" \
  --region us-east-2
```

If SSH times out, verify:

1. The instance is running and has a public IP address.
2. The subnet route table has a `0.0.0.0/0` route to the internet gateway.
3. The security group permits SSH from the administrator or Ansible controller.
4. The `P3.pem` key matches the `P3` EC2 key pair.

If Ansible reports `Host key verification failed`, connect manually once and approve the verified host fingerprint:

```bash
ssh -i ~/.ssh/P3.pem ubuntu@52.15.97.214
```

If Ansible reports `Permission denied`, verify the inventory username and key permissions:

```bash
chmod 400 ~/.ssh/P3.pem
cat ~/inventory.ini
```

If the webpage does not load, verify Nginx directly:

```bash
ansible webservers -i ~/inventory.ini \
  --become \
  --module-name shell \
  --args "systemctl status nginx --no-pager"
```

# Security Improvements

The following improvements are recommended for a production environment:

1. Restrict SSH access to a trusted administrator `/32` CIDR instead of `0.0.0.0/0`.
2. Allow web-server SSH access from the Ansible controller security group.
3. Use private IP addresses for communication between the Ansible controller and web server.
4. Store private keys in a secure secrets system instead of copying them between hosts.
5. Use AWS Systems Manager Session Manager to reduce direct SSH exposure.
6. Configure HTTPS with a valid certificate.
7. Add S3 bucket policies that require TLS for state access.
8. Use least-privilege AWS credentials for Terraform.
9. Place the web server behind an Application Load Balancer for a production workload.

# GitHub Submission

Before committing, verify that sensitive or generated files are ignored:

```bash
git status
```

The repository must not contain:

1. `P3.pem` or any other private key
2. Terraform state files
3. `.terraform` provider directories
4. Terraform variable files containing secrets
5. AWS credentials

Create a private GitHub repository, push the project, and invite the project mentor as a collaborator.

# Cleanup

Destroy the root Terraform-managed resources first:

```bash
terraform destroy
```

Enter `yes` when prompted.

The Ansible controller was created manually and must be terminated separately in the AWS EC2 console when it is no longer required.

The state bucket has `prevent_destroy` enabled because deleting it can remove the history needed to manage the infrastructure. Retain the bucket unless the project is permanently retired.

If the state bucket must be removed, first confirm that the root infrastructure is destroyed, preserve any required state backup, remove `prevent_destroy` from the bootstrap configuration, empty the bucket including object versions, and then destroy the bootstrap configuration.
