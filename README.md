# FinTrack Platform: Cloud-Native Finance Tracker on AWS EKS

[![Terraform Version](https://img.shields.io/badge/Terraform-1.6-blueviolet)](https://www.terraform.io/) [![Kubernetes](https://img.shields.io/badge/Kubernetes-1.29-blue)](https://kubernetes.io/) [![ArgoCD](https://img.shields.io/badge/ArgoCD-GitOps-orange)](https://argoproj.github.io/cd/) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Project Description
FinTrack is a lightweight financial tracking app built with Next.js + Node.js, deployed on AWS EKS using Terraform IaC, ArgoCD GitOps, and Helm. It's stateless, connects to MongoDB Atlas, and is designed for learning cloud-native architecture.

This repo is my portfolio project to demonstrate:
- Infrastructure as Code (Terraform modules for VPC, EKS, IAM)
- GitOps deployments (ArgoCD auto-sync from Git)
- CI/CD (GitHub Actions with scans)
- Security (IRSA, External Secrets, NetworkPolicies)
- Monitoring (Prometheus/Grafana)
- Cost optimization (Free-tier AWS in eu-west-1, NAT instance)

## Tech Stack
- App: Next.js, Node.js, Docker
- Infra: AWS (VPC, EKS, ECR, Secrets Manager) in eu-west-1
- IaC: Terraform (modular, environments)
- GitOps: ArgoCD + Helm
- DB: MongoDB Atlas (free M0)
- CI/CD: GitHub Actions
- Monitoring: Prometheus, Grafana, Fluent Bit

## Architecture Diagram
```mermaid
graph TD
    A[User Browser] --> B[ALB Ingress]
    B --> C[EKS Pods: Next.js App]
    C --> D[MongoDB Atlas via NAT Instance]
    E[GitHub Repo] --> F[GitHub Actions CI: Build/Push ECR]
    F --> E[Update Helm Tag in Git]
    E --> G[ArgoCD Sync]
    G --> C
    H[AWS Secrets Manager] --> I[External Secrets Operator] --> C
```

## Quick Start (Local Dev)

```bash
docker-compose up
```
Open http://localhost:3000

## AWS Setup Guide
See `docs/how-to/aws-setup.md` for full steps. (We'll add this file later.)

## Learning Journey
See commit history for progression: Started with Next.js app, switched to Atlas, now building infra/GitOps.

## Contributing
Use conventional commits. See `CONTRIBUTING.md`. (We'll add this later.)

## Built by
Mohamed Mechraoui for portfolio/learning.
