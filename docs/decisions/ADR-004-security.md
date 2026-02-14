# ADR-004: Security Strategy

## Status
Accepted

## Context
The platform needs defense-in-depth security for a portfolio-grade Kubernetes deployment.

## Decision
Implement layered security:

1. **IRSA** (IAM Roles for Service Accounts) — least-privilege IAM per pod
2. **External Secrets Operator** — no secrets in Git; sync from AWS Secrets Manager
3. **NetworkPolicies** — restrict pod-to-pod and egress traffic
4. **Kyverno** — enforce pod security standards (no privileged containers, require labels)
5. **Trivy** — scan images in CI before ECR push

## Rationale
- IRSA avoids sharing node-level IAM roles (blast radius reduction)
- ESO + Secrets Manager keeps credentials out of Git entirely
- NetworkPolicies implement zero-trust networking at pod level
- Kyverno is simpler than OPA/Gatekeeper for policy enforcement
- Trivy catches known vulnerabilities before deployment

## Consequences
- Kyverno adds ~100MB memory overhead to cluster
- NetworkPolicies require a CNI that supports them (VPC-CNI does)
- ESO needs IRSA role with Secrets Manager read access
