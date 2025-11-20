# Todo API Assessment

This repository contains a **Todo API** project implemented on **AWS**. All infrastructure resources are provisioned using **Terraform**, and the application is deployed using **AWS Lambda** and **API Gateway**. The database backend is a private **RDS** instance, with credentials securely stored in **AWS Secrets Manager**.

---

## Table of Contents

1. [Project Overview](#project-overview)  
2. [Repository Structure](#repository-structure)  
3. [Features](#features)  
4. [Setup and Deployment](#setup-and-deployment)  
5. [Technologies Used](#technologies-used)  
6. [Author](#author)  

---

## Project Overview

The **Todo API** allows users to create, read, update, and delete (CRUD) todo tasks. The API is fully serverless with **AWS Lambda** functions and **API Gateway** endpoints. All resources are defined using **Terraform**, making it easy to deploy in a repeatable and consistent way.

---

## Repository Structure

- **Terraform/** – Contains all Terraform configuration files to provision AWS resources.
  - `main.tf` – Main Terraform configuration for resources.  
  - `variables.tf` – Terraform variables.  
  - `outputs.tf` – Terraform outputs.  
  And all required resources .tf files  

- **Lambda/** – Contains Lambda function code for the Todo API.
  - `app.py` – Main Lambda function implementation.  
  - `requirements.txt` – Python dependencies for Lambda functions.


---

## Features

- CRUD operations for Todo tasks.  
- AWS Lambda backend.  
- API Gateway fronted API.  
- Private RDS database.  
- Secure secrets management using **AWS Secrets Manager**.  
- Infrastructure as Code using **Terraform**.

---

## Setup and Deployment

1. **Deploy Terraform resources:**

```bash
cd Terraform
terraform init
terraform plan
terraform apply
