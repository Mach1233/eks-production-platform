# ADR-001: AWS Region Selection

## Status
Accepted

## Context
We need to choose an AWS region for deploying the FinTrack EKS platform. Key factors:
- **Cost**: Free-tier eligibility and per-hour pricing vary by region.
- **Proximity**: Mohamed is based in Tunis, so EU regions offer lower latency.
- **Service Availability**: EKS, ECR, Secrets Manager must all be available.
- **Sustainability**: Some regions run on renewable energy.

## Decision
**Use `eu-north-1` (Stockholm)** for all AWS resources.

## Rationale
| Factor          | eu-north-1         | eu-west-1 (Ireland) | us-east-1 (Virginia) |
|-----------------|--------------------|-----------------------|----------------------|
| Latency (Tunis) | ~50ms              | ~40ms                 | ~120ms               |
| EC2 Pricing     | Competitive        | Standard              | Cheapest             |
| Free Tier       | ✅ Full             | ✅ Full                | ✅ Full               |
| Sustainability  | 🌿 100% renewable  | Partial               | Partial              |
| EKS Available   | ✅                  | ✅                     | ✅                    |

- `eu-north-1` offers competitive pricing with full free-tier support.
- Powered by 100% renewable energy (good for portfolio storytelling).
- Reasonable latency from Tunis (~50ms to Stockholm vs ~40ms to Ireland).
- Less congested than `us-east-1`, fewer "noisy neighbor" issues.

## Consequences
- Some newer AWS services may launch in `us-east-1` first (minor risk).
- Must verify AMI availability for ARM-based instances in `eu-north-1`.
- All team members/contributors should configure AWS CLI for `eu-north-1`.

## References
- [AWS Regional Services](https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/)
- [AWS Sustainability](https://sustainability.aboutamazon.com/environment/the-cloud)
