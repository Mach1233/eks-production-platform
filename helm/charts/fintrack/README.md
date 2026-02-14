# FinTrack Helm Chart

Deploys the FinTrack Next.js application on Kubernetes with full production features.

## Features
- Deployment with health probes and resource limits
- ClusterIP Service + ALB Ingress
- HPA for CPU-based auto-scaling
- NetworkPolicy (ingress/egress rules)
- ExternalSecret for AWS Secrets Manager integration
- ServiceAccount with IRSA annotation support

## Install
```bash
helm install fintrack ./helm/charts/fintrack \
  --set image.repository=<ECR_URL>/fintrack \
  --set image.tag=v0.1.0
```

## Values
| Key | Default | Description |
|-----|---------|-------------|
| `image.repository` | `""` | ECR repository URL |
| `image.tag` | `latest` | Image tag |
| `replicaCount` | `2` | Number of replicas |
| `hpa.enabled` | `true` | Enable HPA |
| `hpa.maxReplicas` | `5` | Max pods |
| `ingress.enabled` | `true` | Enable ALB ingress |
| `networkPolicy.enabled` | `true` | Enable network policy |
| `externalSecret.enabled` | `true` | Enable ESO secrets |

## Lint
```bash
helm lint ./helm/charts/fintrack
helm template fintrack ./helm/charts/fintrack
```
