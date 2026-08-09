# AWS 3-Tier Containerized Infrastructure with Terraform and GitLab CI/CD

## Project Overview

This project provisions a containerized three-tier AWS environment using Terraform and GitLab CI/CD.

The infrastructure is organized into reusable Terraform modules and separate environment directories. The development environment deploys networking, an Application Load Balancer, ECS services, Amazon ECR, Amazon RDS, AWS Secrets Manager, IAM, Route 53, and ACM.

GitLab CI/CD is used to validate and deploy the Terraform infrastructure. Authentication from GitLab to AWS uses OpenID Connect (OIDC), allowing the pipeline to assume an AWS IAM role without storing long-lived AWS access keys in GitLab.

---

## Table of Contents

- [Architecture](#architecture)
- [Infrastructure Design](#infrastructure-design)
- [AWS Services Used](#aws-services-used)
- [Tools and Technologies](#tools-and-technologies)
- [Project Goals](#project-goals)
- [Repository Structure](#repository-structure)
- [Terraform Module Overview](#terraform-module-overview)
- [Application Traffic Flow](#application-traffic-flow)
- [Secrets Management](#secrets-management)
- [GitLab CI/CD Pipeline](#gitlab-cicd-pipeline)
- [GitLab OIDC Authentication](#gitlab-oidc-authentication)
- [Deployment Evidence](#deployment-evidence)
- [Screenshots](#screenshots)
- [Skills Demonstrated](#skills-demonstrated)

---

## Architecture

The project follows a three-tier architecture:

1. **Presentation / Entry Layer** – Route 53, ACM, and an Application Load Balancer receive HTTPS traffic.
2. **Application Layer** – Containerized application workloads run on Amazon ECS in private subnets.
3. **Database Layer** – Amazon RDS runs in a separate private subnet tier.

The container image used by ECS is stored in Amazon ECR, while application and database configuration is stored in AWS Secrets Manager.

### Architecture Flow

```text
                         Internet
                            |
                            v
                        Route 53
                            |
                            v
                     Application Load
                        Balancer
                       HTTPS / ACM
                            |
                            v
                  +-------------------+
                  |    ECS Service    |
                  |   Private Subnets |
                  +-------------------+
                            |
                            v
                  +-------------------+
                  |        RDS        |
                  |   Private Subnets |
                  +-------------------+

ECR --------------------> ECS Tasks

Secrets Manager ---------> ECS Tasks
        |
        +----------------> Database configuration
```

---

## Infrastructure Design

The Terraform configuration creates a layered AWS environment with public and private networking.

- A VPC provides the network boundary for the environment.
- Public subnets host internet-facing resources such as the Application Load Balancer.
- A private subnet tier hosts ECS application tasks.
- A separate private subnet tier hosts the RDS database.
- Security groups control communication between the ALB, ECS tasks, and RDS.
- Route 53 provides DNS for the application.
- ACM provides the SSL/TLS certificate used by the HTTPS listener.
- Amazon ECR stores the application container image.
- Amazon ECS runs the containerized application.
- AWS Secrets Manager stores database connection information and the Flask application secret.
- IAM roles provide permissions required by ECS.
- Terraform state is configured through the environment backend.
- The repository includes development, staging, and production environment directories.

---

## AWS Services Used

This project uses the following AWS services and resources:

- Amazon VPC
- Public subnets
- Private application subnets
- Private database subnets
- Internet Gateway
- NAT networking
- Route tables
- Security Groups
- Application Load Balancer
- Target Group
- HTTP/HTTPS listeners
- AWS Certificate Manager (ACM)
- Amazon Route 53
- Amazon Elastic Container Registry (ECR)
- Amazon Elastic Container Service (ECS)
- ECS Cluster
- ECS Task Definition
- ECS Service
- AWS Identity and Access Management (IAM)
- AWS Secrets Manager
- Amazon RDS

---

## Tools and Technologies

- Terraform
- AWS
- Amazon ECS
- Docker containers
- Amazon ECR
- GitLab CI/CD
- GitLab OIDC
- TFLint
- Linux
- Git

---

## Project Goals

The main goals of this project were to:

- Build a three-tier AWS architecture using Terraform.
- Organize infrastructure into reusable Terraform modules.
- Separate application and database workloads into private subnet tiers.
- Run a containerized application with Amazon ECS.
- Store container images in Amazon ECR.
- Place an Application Load Balancer in front of the ECS service.
- Use Route 53 and ACM to provide DNS and HTTPS.
- Store application and database configuration in AWS Secrets Manager.
- Automate Terraform validation, planning, deployment, and destruction with GitLab CI/CD.
- Authenticate GitLab CI/CD to AWS using OIDC instead of long-lived AWS access keys.
- Add Terraform formatting and linting checks to the CI/CD workflow.
- Maintain separate environment directories for development, staging, and production.

---

## Repository Structure

```text
.
├── .gitignore
├── .gitlab-ci.yml
├── .tflint.hcl
├── README.md
│
├── environment
│   ├── dev
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   ├── terraform.tfvars
│   │   ├── variables.tf
│   │   └── versions.tf
│   │
│   ├── stage
│   └── prod
│
└── modules
    ├── acm
    ├── alb
    ├── ecr
    ├── ecs
    ├── iam
    ├── network
    │   ├── sg
    │   └── vpc
    ├── rds
    ├── route53
    └── sm
```

---

## Terraform Module Overview

The infrastructure is divided into reusable Terraform modules. The development environment in `environment/dev/main.tf` connects the modules together by passing outputs from one module into the inputs of another.

### Network Module

The network module creates the AWS networking layer.

It provides resources used by the rest of the architecture, including:

- VPC
- Public subnets
- Private application subnets
- Private database subnets
- Internet connectivity
- NAT networking
- Route tables
- Route table associations

The subnet outputs are consumed by the ALB, ECS, and RDS modules.

---

### Security Group Module

The security group module creates separate security boundaries for infrastructure components.

Security groups are used for:

- Application Load Balancer traffic
- ECS application traffic
- Database traffic

This creates a controlled traffic path between each layer of the application.

```text
Internet
   |
   v
ALB Security Group
   |
   v
ECS Security Group
   |
   v
RDS Security Group
```

---

### Application Load Balancer Module

The ALB module creates the public entry point for the application.

It receives:

- VPC ID
- Public subnet IDs
- Load balancer security group
- Target group configuration
- ACM certificate ARN

The load balancer forwards application traffic to the ECS service through its target group.

---

### ECS Module

The ECS module runs the containerized application.

The development environment passes the ECS module:

- ECS cluster configuration
- Task definition configuration
- IAM execution role
- ECR container image
- Container configuration
- ECS service configuration
- Private application subnet IDs
- ECS security group
- ALB target group ARN
- Secrets Manager secret ARN
- AWS region

The ECS service registers its running tasks with the ALB target group.

```text
ALB
 |
 v
Target Group
 |
 v
ECS Service
 |
 +---- ECS Task
 |
 +---- ECS Task
```

---

### ECR Module

The ECR module creates the container registry used to store the application image.

The repository URL is passed to the ECS module so that the ECS task definition can reference the application container image.

```text
Application Image
       |
       v
      ECR
       |
       v
ECS Task Definition
       |
       v
    ECS Tasks
```

---

### RDS Module

The RDS module creates the database tier.

The database is associated with:

- Database configuration
- Database credentials
- Database security group
- Private database subnets

The RDS endpoint and database name are passed to AWS Secrets Manager so the application can retrieve its database connection information.

---

### Secrets Manager Module

AWS Secrets Manager stores application configuration required by the ECS workload.

The Terraform configuration passes values including:

- Database username
- Database password
- RDS endpoint
- Database name
- Flask application secret key

The resulting secret ARN is passed to the ECS module.

```text
RDS
 |
 | endpoint / database information
 v
Secrets Manager
 |
 | secret ARN
 v
ECS Task Definition
 |
 v
Application Container
```

---

### IAM Module

The IAM module creates the IAM role used by the ECS workload.

The role ARN is passed into the ECS module as the task execution role.

This role allows ECS to perform the AWS actions required by the task definition and supporting services.

---

### ACM Module

The ACM module creates the SSL/TLS certificate for the application domain.

The certificate ARN is passed to the Application Load Balancer so the HTTPS listener can terminate TLS connections.

---

### Route 53 Module

The Route 53 module creates the DNS record for the application.

The module receives the ALB DNS name and ALB hosted zone ID and creates an alias pointing the application domain to the load balancer.

```text
Application Domain
       |
       v
    Route 53
       |
       v
      ALB
```

---

## Application Traffic Flow

A request to the application follows this path:

```text
1. User opens the application domain
              |
              v
2. Route 53 resolves the DNS record
              |
              v
3. HTTPS traffic reaches the ALB
              |
        ACM TLS Certificate
              |
              v
4. ALB forwards the request to its target group
              |
              v
5. Target group forwards traffic to a healthy ECS task
              |
              v
6. Containerized application processes the request
              |
              v
7. Application communicates with Amazon RDS
```

The application tier and database tier remain inside private subnets while the Application Load Balancer provides the public entry point.

---

## Secrets Management

Application secrets are handled through AWS Secrets Manager.

Terraform creates the secret using values supplied to the development environment and information generated by the RDS module.

The ECS module receives the Secrets Manager ARN so that the containerized application can access the configuration it requires.

This keeps runtime application configuration separate from the container image.

---

## GitLab CI/CD Pipeline

GitLab CI/CD automates Terraform validation and infrastructure deployment.

The pipeline contains four stages:

```text
validate
plan
apply
destroy
```

### Pipeline Workflow

```text
Git Push / Merge Request
          |
          v
+----------------------+
|      Validation      |
| terraform fmt -check |
| TFLint               |
| terraform validate   |
+----------------------+
          |
          v
+----------------------+
|    Terraform Plan    |
|      tfplan          |
+----------------------+
          |
          v
   GitLab Artifact
          |
          v
+----------------------+
|   Terraform Apply    |
|       manual         |
+----------------------+
          |
          v
         AWS
```

### Validate Stage

The validation stage includes:

```bash
terraform fmt -check -recursive -diff
```

TFLint is also executed recursively to check the Terraform configuration.

Terraform then runs:

```bash
terraform validate
```

The formatting and linting jobs run for non-default branches, while Terraform validation uses the shared AWS OIDC and Terraform initialization configuration.

---

### Plan Stage

The plan job initializes Terraform and creates a saved execution plan:

```bash
terraform plan -out=tfplan
```

Database credentials and the Flask application secret are supplied to Terraform through GitLab CI/CD variables.

The resulting `tfplan` file is stored as a GitLab artifact.

---

### Apply Stage

The apply job depends on the plan job and downloads the saved Terraform plan.

It executes:

```bash
terraform apply -input=false tfplan
```

The apply stage is manual and is limited to the default branch.

This means the exact Terraform plan generated by the pipeline is the plan that gets applied.

---

### Destroy Stage

The pipeline also provides a manual destroy job for the development environment.

Before destruction, GitLab displays a manual confirmation prompt.

Terraform then executes the destroy operation using the required environment variables.

---

## GitLab OIDC Authentication

GitLab authenticates to AWS using OpenID Connect.

The pipeline requests a GitLab OIDC ID token with AWS STS as the audience:

```text
GitLab CI Job
      |
      | OIDC ID Token
      v
AWS Security Token Service
      |
      | Assume IAM Role
      v
Temporary AWS Credentials
      |
      v
Terraform
```

The IAM role ARN is supplied through the GitLab `ROLE_ARN` CI/CD variable.

The pipeline sets:

- `AWS_ROLE_ARN`
- `AWS_ROLE_SESSION_NAME`
- `AWS_WEB_IDENTITY_TOKEN_FILE`

Terraform and the AWS provider can then use the temporary role credentials during the job.

No permanent AWS access key and secret access key are required by the Terraform jobs.

---

## Deployment Evidence

Screenshots can be stored under:

```text
docs/screenshots/
```

Recommended evidence for this project:

- Successful GitLab pipeline
- Terraform formatting / validation jobs
- TFLint job
- Terraform plan
- Terraform apply
- AWS VPC and subnet layout
- Application Load Balancer
- ALB target group with healthy ECS targets
- ECS cluster
- ECS service
- Running ECS tasks
- ECR repository and application image
- RDS database
- AWS Secrets Manager secret
- Route 53 record
- ACM certificate
- Running application in the browser

---

## Screenshots

Create the directory:

```bash
mkdir -p docs/screenshots
```

Then save the screenshots using clear names such as the examples below.

### GitLab CI/CD Pipeline

![GitLab CI/CD Pipeline](docs/screenshots/gitlab-pipeline.png)

### Terraform Validation

![Terraform Validation](docs/screenshots/terraform-validation.png)

### Terraform Plan

![Terraform Plan](docs/screenshots/terraform-plan.png)

### Terraform Apply

![Terraform Apply](docs/screenshots/terraform-apply.png)

### VPC and Subnets

![VPC and Subnets](docs/screenshots/vpc-subnets.png)

### Application Load Balancer

![Application Load Balancer](docs/screenshots/alb.png)

### ALB Target Group

![ALB Target Group](docs/screenshots/target-group.png)

### ECS Cluster

![ECS Cluster](docs/screenshots/ecs-cluster.png)

### ECS Service

![ECS Service](docs/screenshots/ecs-service.png)

### Running ECS Tasks

![Running ECS Tasks](docs/screenshots/ecs-tasks.png)

### ECR Repository

![ECR Repository](docs/screenshots/ecr.png)

### RDS Database

![RDS Database](docs/screenshots/rds.png)

### AWS Secrets Manager

![AWS Secrets Manager](docs/screenshots/secrets-manager.png)

### Route 53

![Route 53](docs/screenshots/route53.png)

### ACM Certificate

![ACM Certificate](docs/screenshots/acm.png)

### Running Application

![Running Application](docs/screenshots/application.png)

---

## Skills Demonstrated

This project demonstrates hands-on experience with:

- Infrastructure as Code using Terraform
- Reusable Terraform module design
- Multi-environment Terraform repository structure
- AWS VPC networking
- Public and private subnet architecture
- Three-tier application design
- Security group design
- Amazon ECS
- Containerized workloads
- Amazon ECR
- Application Load Balancers
- ALB target groups and health checks
- Amazon RDS
- AWS Secrets Manager
- IAM roles
- Route 53 DNS
- ACM HTTPS certificates
- GitLab CI/CD
- GitLab OIDC federation with AWS
- Terraform plan artifacts
- Manual infrastructure deployment controls
- Terraform formatting and validation
- TFLint
- DevOps infrastructure automation

---

## Summary

This project demonstrates the deployment of a containerized three-tier application infrastructure on AWS using Terraform and GitLab CI/CD.

Compared with a traditional EC2-based architecture, the application layer is deployed as containers through Amazon ECS, images are stored in Amazon ECR, and runtime application configuration is stored in AWS Secrets Manager.

The Terraform code is organized into reusable modules and environment-specific configurations, while GitLab CI/CD provides automated validation and planning with controlled manual apply and destroy stages. GitLab authenticates to AWS through OIDC and temporary IAM role credentials.

The result is a modular Infrastructure as Code project that demonstrates AWS networking, container orchestration, database architecture, security, secrets management, HTTPS/DNS configuration, and CI/CD automation.
