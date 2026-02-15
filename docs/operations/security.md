# Security

The Cloud Native EKS Platform employs a defense-in-depth security strategy.

## 1. Policy Enforcement (Kyverno)

We use **Kyverno** to enforce best practices and security standards on the cluster.

- **Policies Location**: `k8s/kyverno/policies/`
- **Active Policies**:
    - `disallow-privileged`: Prevents containers from running in privileged mode.
    - `require-labels`: Mandates standard labels (`app.kubernetes.io/name`, etc.) for all deployments.

## 2. Identity & Access (IRSA)

We use **IAM Roles for Service Accounts (IRSA)** to provide fine-grained permissions to pods.

- **Mechanism**: Pods are annotated with an IAM Role ARN. EKS injects a temporary OIDC token.
- **Benefits**:
    - Least privilege: Pods only get the permissions they need (e.g., S3 read, Secrets Manager access).
    - No long-term credentials stored in the cluster.

## 3. Network Security

- **VPC CNI**: Pods receive native VPC IP addresses.
- **Network Policies**: Restrict traffic between pods. Default deny all ingress/egress unless explicitly allowed.
- **Security Groups**: Control traffic at the EC2 instance (node) level.

## 4. Image Security

- **Trivy**: Scans container images for vulnerabilities during the CI process.
- **ECR Scanning**: AWS ECR automatically scans images on push.
