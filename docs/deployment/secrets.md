# Secrets Management

We use **External Secrets Operator (ESO)** to synchronize secrets from AWS Secrets Manager into Kubernetes Secrets. This ensures no sensitive data is stored in the git repository.

## Workflow

1.  **Create Secret in AWS Secrets Manager**:
    - Navigate to the AWS Console -> Secrets Manager.
    - Create a new secret (e.g., `prod/fintrack/db-credentials`).
    - Add key-value pairs (e.g., `username`, `password`).

2.  **Define ExternalSecret in Kubernetes**:
    -Create a YAML manifest in `k8s/secrets/` creating an `ExternalSecret` resource.
    - Reference the AWS Secret Key.

    ```yaml
    apiVersion: external-secrets.io/v1beta1
    kind: ExternalSecret
    metadata:
      name: db-credentials
    spec:
      refreshInterval: 1h
      secretStoreRef:
        name: aws-secrets-manager
        kind: ClusterSecretStore
      target:
        name: db-credentials-secret # Name of the K8s Secret to create
      data:
        - secretKey: username
          remoteRef:
            key: prod/fintrack/db-credentials
            property: username
        - secretKey: password
          remoteRef:
            key: prod/fintrack/db-credentials
            property: password
    ```

3.  **Apply Manifest**:
    - Commit the file to git.
    - ArgoCD will sync the change and ESO will fetch the secret value.

4.  **Use Secret in Application**:
    - Reference the created K8s Secret (`db-credentials-secret`) in your deployment environment variables.
