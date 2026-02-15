# Local Development Setup

This guide covers the prerequisites and steps to set up your local environment for contributing to the Cloud Native EKS Platform.

## Prerequisites

Ensure you have the following tools installed:

1.  **Homebrew** (Linux/macOS): Package manager for installing other tools.
    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```

2.  **Docker Desktop** or **Docker Engine**: Required for containerization.
    - [Install Docker](https://docs.docker.com/get-docker/)

3.  **Basic CLI Tools**:
    ```bash
    brew install git make jq yq
    ```

4.  **Cloud & Infrastructure Tools**:
    ```bash
    brew install awscli terraform kubectl helm argocd
    ```

5.  **Language Runtimes**:
    - **Node.js** (v18+):
      ```bash
      brew install node
      ```
    - **Go** (Optional, for advanced tooling):
      ```bash
      brew install go
      ```

6.  **Pre-commit Hooks**:
    ```bash
    brew install pre-commit
    ```

## Repository Setup

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/your-org/cloud-native-eks-platform.git
    cd cloud-native-eks-platform
    ```

2.  **Install Dependencies**:
    ```bash
    npm install
    ```

3.  **Install Pre-commit Hooks**:
    ```bash
    pre-commit install
    ```

4.  **Configure Environment Variables**:
    Copy the example `.env` file:
    ```bash
    cp app/.env.example app/.env
    ```
    Update `app/.env` with your local configuration if needed.

## Verification

Run the following command to verify all tools are installed correctly:

```bash
make check-tools
```
*(Note: If `make check-tools` is not available, verify manually by running `docker --version`, `terraform --version`, etc.)*
