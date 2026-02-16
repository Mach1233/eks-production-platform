# 🏗 EKS Production Platform
### End-to-End Cloud-Native Deployment using Terraform, AWS EKS & GitHub Actions

---

## 📌 Project Overview

This project demonstrates a production-oriented cloud-native platform built on AWS EKS using Infrastructure as Code (Terraform) and a fully automated CI/CD pipeline with GitHub Actions.

It simulates a real-world DevOps workflow including:

- Custom VPC networking
- Private Kubernetes worker nodes
- IAM Roles for Service Accounts (IRSA)
- Remote Terraform state management
- Container image build & push to ECR
- Automated Kubernetes deployment
- Horizontal Pod Autoscaling (HPA)
- ALB Ingress for external access

This project was designed and implemented independently to demonstrate cloud architecture, automation, and security best practices.

---

## 🎯 Objectives

- Design scalable AWS infrastructure using Terraform
- Deploy a containerized Next.js application to EKS
- Implement secure IAM configuration
- Automate build & deployment with GitHub Actions
- Apply production-grade DevOps principles

---

## 🏛 Architecture Overview
<img width="1953" height="1564" alt="image" src="https://github.com/user-attachments/assets/d3b46d82-1392-4e91-8d54-c85e638388ea" />

### Infrastructure Components

- Custom VPC
- Public & Private Subnets
- Internet Gateway & NAT Gateway
- Amazon EKS Cluster
- Managed Node Groups (private)
- IAM Roles & Policies
- IAM Roles for Service Accounts (IRSA)
- Amazon ECR
- Application Load Balancer (ALB Ingress)
- Horizontal Pod Autoscaler (HPA)
- S3 + DynamoDB (Terraform Remote State)

---

## 📐 Architecture Diagram

_Add architecture diagram here (architecture.png)_

---

## 🛠 Infrastructure as Code (Terraform)

### Remote State Configuration

Terraform state is stored securely in:

- Amazon S3 (state storage)
- DynamoDB (state locking)

This prevents:
- State corruption
- Concurrent modification issues
- Local state risks

### Directory Structure

terraform/
├── backend.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── vpc.tf
├── eks.tf
├── iam.tf
├── nodegroup.tf


### Key Design Decisions

- Modular structure for maintainability
- Private worker nodes for security
- Least privilege IAM policies
- Isolated networking configuration

---

## ☸ Kubernetes Configuration

The application deployment includes:

- Deployment.yaml
- Service.yaml
- ALB Ingress configuration
- ConfigMaps
- Secrets
- Horizontal Pod Autoscaler (HPA)

### High Availability Strategy

- Multiple replicas
- Rolling updates
- Self-healing pods
- CPU-based autoscaling using HPA

---

## 🚀 CI/CD Pipeline (GitHub Actions)

Fully automated pipeline:

1. Build Docker image
2. Push image to Amazon ECR
3. Authenticate to EKS
4. Apply Kubernetes manifests

### Security Practices

- GitHub Secrets for AWS credentials
- No hardcoded secrets
- IAM-based authentication
- Controlled deployment workflow
