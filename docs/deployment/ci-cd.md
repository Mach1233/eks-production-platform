# CI/CD Pipelines

Our platform uses **GitHub Actions** for Continuous Integration (CI) and **ArgoCD** for Continuous Deployment (CD).

## Workflows

We have defined the following workflows in `.github/workflows/`:

### 1. Application CI (`ci-app.yaml`)
- **Trigger**: Pushes to `main` or Pull Requests affecting the `app/` directory.
- **Actions**:
    - Build: Compiles the Next.js application.
    - Test: Runs unit and integration tests.
    - Lint: Checks code quality.
    - Security Scan: Scans dependencies for vulnerabilities (Trivy).

### 2. GitOps CD (`cd-gitops.yaml`)
- **Trigger**: Push to `main` (after successful CI).
- **Actions**:
    - **Build Image**: Builds the Docker image.
    - **Push to ECR**: Pushes the tagged image to Amazon ECR.
    - **Update Manifests**: Updates the Helm chart version in the git repository to reference the new image tag.

### 3. Deploy (`deploy.yaml`)
- **Trigger**: Manual dispatch or specific events.
- **Actions**:
    - Automates complex deployment scenarios if needed (mostly replaced by GitOps flow).

## Pipeline Flow

1.  **Developer** pushes code to a feature branch.
2.  **GitHub Actions** runs `ci-app.yaml` to validatethe changes.
3.  **Developer** merges PR to `main`.
4.  **GitHub Actions** runs `cd-gitops.yaml`:
    - Builds and pushes new container image to ECR.
    - Updates `helm/charts/fintrack/values.yaml` with the new image tag.
    - Commits the change back to the repo.
5.  **ArgoCD** detects the change in the git repository and syncs the application state in the EKS cluster.
