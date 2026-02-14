# ADR-003: MongoDB Atlas (M0 Free Tier) Over Self-Hosted

## Status
Accepted

## Context
FinTrack needs a database for financial transactions. Options considered:
1. **Self-hosted MongoDB** on EKS (StatefulSet + PVC).
2. **Amazon RDS PostgreSQL** (provisioned in Terraform, disabled by default).
3. **MongoDB Atlas M0** (free managed cluster).

## Decision
**Use MongoDB Atlas M0 free tier** as the primary database.

## Rationale

| Factor          | Atlas M0 (Free)     | Self-Hosted MongoDB | RDS PostgreSQL       |
|-----------------|---------------------|---------------------|----------------------|
| Monthly Cost    | €0                  | ~€5-10 (EBS + compute) | ~€15+ (db.t3.micro) |
| Maintenance     | Fully managed        | Manual backups/upgrades | AWS managed          |
| HA/Backups      | ✅ Built-in          | ❌ Manual             | ✅ Multi-AZ optional  |
| Schema Fit      | ✅ NoSQL = flexible   | ✅ Same               | ⚠️ Requires migration |
| Free Tier       | ✅ 512MB, shared     | ❌ Pays for compute   | ⚠️ 12-month only     |

- **Zero cost**: M0 gives 512MB storage, shared RAM — enough for portfolio app.
- **No infra overhead**: No StatefulSets, PVCs, or backup scripts to manage.
- **Already integrated**: App already uses `MONGODB_URI` via `mongodb` Node.js driver.
- **Stateless app design**: App connects via connection string — clean architecture.
- **RDS kept as option**: Terraform RDS module exists but disabled (`enabled = false`) for future use.

## Consequences
- 512MB storage limit — sufficient for demo data, not production scale.
- Shared cluster = variable performance (acceptable for learning).
- Must whitelist NAT instance EIP in Atlas Network Access.
- Connection string stored in AWS Secrets Manager, injected via External Secrets Operator.

## References
- [MongoDB Atlas Free Tier](https://www.mongodb.com/atlas/database)
- [Atlas Network Access](https://www.mongodb.com/docs/atlas/security/ip-access-list/)
