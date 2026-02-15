# FinTrack Platform Implementation Guide

This guide provides a step-by-step walkthrough to deploy the FinTrack platform from scratch. It covers infrastructure provisioning with Terraform, GitOps setup with ArgoCD, and application deployment via GitHub Actions.

## 📋 Prerequisites

Before you begin, ensure you have the following tools installed:

-   [AWS CLI](https://aws.amazon.com/cli/) (v2+)
-   [Terraform](https://www.terraform.io/) (v1.6+)
-   [kubectl](https://kubernetes.io/docs/tasks/tools/) (v1.29+)
-   [Helm](https://helm.sh/) (v3+)
-   [ArgoCD CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/) (Optional, for managing ArgoCD)

You also need:
-   An AWS Account with Administrator permissions.
-   A GitHub repository (fork of this repo).

---

## 🏗️ Phase 1: Infrastructure Provisioning (Terraform)

We use Terraform to provision the VPC, EKS cluster, ECR repository, and IAM roles.

**0. Professional State Setup (S3 + DynamoDB)**:
    We use a remote S3 backend with DynamoDB locking for production-grade state management.
    ```bash
    # Run the setup script to create the bucket and table
    chmod +x ../../terraform/backend-setup/setup.sh
    ../../terraform/backend-setup/setup.sh
    
    # Update terraform/environments/staging/backend.tf with the output values
    # content of the file should look like:
    # terraform {
    #   backend "s3" {
    #     bucket         = "YOUR_BUCKET_NAME"
    #     key            = "staging/terraform.tfstate"
    #     region         = "eu-north-1"
    #     dynamodb_table = "fintrack-terraform-locks"
    #     encrypt        = true
    #   }
    # }
    ```


1.  **Configure AWS Credentials**:
    ```bash
    aws configure
    # Region: eu-north-1
    ```

2.  **Navigate to the Staging Environment**:
    ```bash
    cd terraform/environments/staging
    ```

3.  **Initialize Terraform**:
    ```bash
    terraform init
    ```

4.  **Review the Plan**:
    ```bash
    terraform plan -out=tfplan
    ```
    *Verify that it plans to create the VPC, EKS cluster (fintrack-staging), ECR (fintrack), and related IAM roles.*

5.  **Apply the Infrastructure**:
    ```bash
    terraform apply tfplan
    ```
    *This process takes approximately 15-20 minutes.*

---

## ☸️ Phase 2: Cluster Configuration

Once Terraform completes, configure `kubectl` to interact with your new EKS cluster.

1.  **Update Kubeconfig**:
    ```bash
    aws eks update-kubeconfig --region eu-north-1 --name fintrack-staging
    ```

2.  **Verify Connection**:
    ```bash
    kubectl get nodes
    ```
    *You should see the worker nodes in `Ready` status.*

---

## 🐙 Phase 3: GitOps Setup (ArgoCD)

We use ArgoCD to manage Kubernetes resources.

1.  **Install ArgoCD**:
    ```bash
    # Add Argo Helm repo
    helm repo add argo https://argoproj.github.io/argo-helm
    helm repo update

    # Install ArgoCD into the argocd namespace
    helm install argocd argo/argo-cd \
      -n argocd --create-namespace \
      -f ../../../argocd/bootstrap/values.yaml
    ```

2.  **Retrieve Admin Password**:
    ```bash
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
    ```

3.  **Access ArgoCD UI**:
    ```bash
    kubectl port-forward svc/argocd-server -n argocd 8080:443
    ```
    Open [https://localhost:8080](https://localhost:8080) and login with `admin` and the password from the previous step.

4.  **Configure the Project and Application**:
    ```bash
    # Apply AppProject (permissions)
    kubectl apply -f ../../../argocd/projects/default.yaml

    # Apply Application (points to this repo)
    kubectl apply -f ../../../argocd/applications/fintrack.yaml
    ```

---

## 🚀 Phase 4: CI/CD Pipeline (GitHub Actions)

The pipeline builds the Docker image, scans it, pushes to ECR, and updates the Helm chart version.

1.  **Configure GitHub Secrets**:
    Go to your GitHub Repo -> Settings -> Secrets and variables -> Actions -> New repository secret.

    -   `AWS_ROLE_ARN`: The ARN of the IAM role created by Terraform for GitHub Actions (Output: `github_actions_role_arn` from Terraform).

2.  **Trigger the Pipeline**:
    -   Push a change to the `app/` directory or `develop` branch.
    -   Or ensure the workflow runs on push to `develop`.

3.  **Watch the Magic**:
    -   **GitHub Actions**: Builds -> Scans -> Pushes to ECR -> Updates `helm/charts/fintrack/values.yaml` with the new image tag.
    -   **ArgoCD**: Detects the change in Git and syncs the new image to the EKS cluster.

---

## 🔍 Phase 5: Verification

1.  **Check Pods**:
    ```bash
    kubectl get pods -n fintrack
    ```

2.  **Access the Application**:
    -   Get the Ingress endpoint (ALB URL):
        ```bash
        kubectl get ingress -n fintrack
        ```
    -   Open the URL in your browser.

3.  **Verify Security Hardening**:
    -   **NetworkPolicy**: Verify outbound access is restricted.
        ```bash
        # Should timeout/fail
        kubectl exec -n fintrack -it <pod-name> -- curl http://malicious-site.com
        # Should succeed
        kubectl exec -n fintrack -it <pod-name> -- curl https://kubernetes.default
        ```
    -   **ReadOnly Filesystem**:
        ```bash
        # Should fail
        kubectl exec -n fintrack -it <pod-name> -- touch /root/test
        ```


## 🧹 Cleanup (Optional)

To destroy all resources and avoid costs:

1.  **Uninstall ArgoCD**:
    ```bash
    helm uninstall argocd -n argocd
    kubectl delete namespace argocd
    ```

2.  **Destroy Infrastructure**:
    ```bash
    cd terraform/environments/staging
    terraform destroy -auto-approve
    ```
