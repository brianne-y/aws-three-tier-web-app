# Cloud Migration — Three-Tier Web App Stack on AWS

## Scenario — What Problem Are We Solving?

A small business is running WordPress on an aging on-premise server.
The server has no redundancy, no automated backups, and cannot handle
traffic spikes. A single hardware failure takes the entire site offline.

This project migrates that WordPress site to AWS using a three-tier
architecture: a load balancer tier, an application tier, and a
database tier. This architecture is defined entirely as Infrastructure as Code using
Terraform. The result is a scalable, secure, and reproducible
environment that eliminates single points of failure and removes
manual infrastructure management.

---

## Architecture


*Three-tier architecture consisting of: internet traffic enters through the ALB,
routes to EC2 running WordPress, which connects to a private RDS
MySQL database unreachable from the internet*

---

## AWS Services Used

- **Terraform** — Infrastructure as Code, entire stack defined and
deployed from code
- **Amazon VPC** — isolated network with public and private subnets
- **Amazon EC2** — application server running WordPress
- **Amazon RDS (MySQL)** — managed database in private subnet,
no internet access
- **Application Load Balancer** — distributes traffic and serves
as the only public entry point to the application
- **Amazon S3** — remote Terraform state storage with versioning
- **Amazon CloudWatch** — EC2 CPU and RDS connection monitoring
- **Amazon SNS** — email alerting for CloudWatch alarms

---

## Obstacles — Constraints and Security Requirements

**The database must never be publicly accessible.**
A common mistake is placing RDS in a public subnet or enabling
publicly_accessible = true. This exposes the database directly
to the internet. The correct approach is placing RDS in private
subnets with no route to an internet gateway, accessible only
from the EC2 application layer.

**Security groups must be chained, not open.**
Rather than allowing broad inbound access, security groups are
chained so that the ALB only accepts traffic from the internet
on port 80, EC2 only accepts traffic from the ALB on port 80
and SSH from a specific IP, and RDS only accepts traffic from
EC2 on port 3306. Nothing reaches RDS from the internet,
even indirectly.

**Terraform state must never live on a local machine.**
Local state files can be lost if the machine fails and create
conflicts when multiple engineers work on the same infrastructure.
Remote state is stored in a private S3 bucket with versioning
enabled, allowing state recovery if a file is ever corrupted.

**Sensitive values must never be committed to GitHub.**
Database passwords and IP addresses live in terraform.tfvars
which is excluded from version control via .gitignore. This is
enforced before the first commit, not after.

---

## Actions — What Was Built and Why

### Step 1 — Environment Setup

Installed Homebrew and Terraform on a local Mac. Verified
installation with terraform --version. All Terraform commands
run locally: Terraform communicates with AWS through configured
CLI credentials, no SSH required for infrastructure deployment.

---

### Step 2 — Create Remote State S3 Bucket

Created a private S3 bucket to store Terraform state remotely.
Enabled versioning so previous state versions can be recovered
if needed. This bucket must exist before Terraform initializes
because it cannot create the bucket it uses to store its own state.


---

### Step 3 — Project Structure and Terraform Files

Created the project folder and all Terraform configuration files.
Opened the project in VS Code with the HashiCorp Terraform extension
for syntax validation and highlighting.

**providers.tf** — defines the AWS provider, required Terraform
version, and the S3 backend for remote state storage

**variables.tf** — defines input variables including database
credentials marked as sensitive so they never print in terminal output

**terraform.tfvars** — supplies actual values for all variables.
This file is excluded from GitHub via .gitignore

**outputs.tf** — prints the ALB DNS name, EC2 public IP, and RDS
endpoint after apply completes

---

### Step 4 — Build main.tf

Built the core infrastructure across five sections:

**VPC and Networking** — created a VPC with CIDR 10.0.0.0/16,
two public subnets across availability zones us-east-1a and
us-east-1b for the ALB and EC2, two private subnets for RDS,
an internet gateway, and a public route table.

**Security Groups** — implemented three chained security groups.
The ALB security group accepts port 80 from the internet. The EC2
security group accepts port 80 only from the ALB security group
and SSH only from a specific IP. The RDS security group accepts
port 3306 only from the EC2 security group.


**EC2 and ALB** — deployed an EC2 instance using the latest
Amazon Linux 2023 AMI with a user_data script that automatically
installs Apache, PHP, and WordPress on first boot. Created an
Application Load Balancer across both public subnets with a
target group and health check.

**RDS** — deployed a MySQL 8.0 database instance on db.t3.micro
in a private DB subnet group spanning both private subnets.
publicly_accessible is set to false. The database has no route
to the internet gateway.

**CloudWatch and SNS** — created two alarms: EC2 CPU above 80%
and RDS database connections above 50. Both alarms trigger an
SNS email notification.

---

## Let's Connect!

Brianne Young | Cloud Engineer | [LinkedIn](https://www.linkedin.com/in/brianne-young0/) | [GitHub](https://github.com/brianne-y)
