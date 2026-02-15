# ADR-002: NAT Instance Instead of NAT Gateway

## Status
Accepted

## Context
EKS worker nodes in private subnets need outbound internet access (pull images, reach Atlas, etc.).
AWS provides two options:
1. **NAT Gateway** (managed): ~€30-45/month per AZ + data processing charges.
2. **NAT Instance** (self-managed EC2): As low as ~€3/month with `t4g.micro` spot.

For a portfolio/learning project targeting €0-15/month, NAT Gateway is cost-prohibitive.

## Decision
**Use a self-managed NAT instance** (`t4g.micro` ARM-based) in a public subnet.

## Rationale

| Factor         | NAT Gateway         | NAT Instance (t4g.micro)  |
|----------------|---------------------|---------------------------|
| Monthly Cost   | ~€30-45/AZ          | ~€3 (spot) or €7 (on-demand) |
| Availability   | 99.9% SLA           | Single instance (no SLA)  |
| Throughput     | Up to 100 Gbps      | ~5 Gbps                   |
| Maintenance    | Fully managed        | Self-managed (user_data)  |
| ARM Support    | N/A                  | ✅ t4g = Graviton ~20% cheaper |

- **Cost savings**: 10x cheaper. Critical for staying in €0-15/month budget.
- **ARM (Graviton)**: `t4g.micro` is ~20% cheaper than `t3.micro` and available in `eu-north-1`.
- **Simplicity**: `user_data` script auto-enables IP forwarding + iptables masquerade.
- **Learning value**: Demonstrates understanding of networking fundamentals (good for portfolio).
- **Trade-off accepted**: Single point of failure is acceptable for staging/learning.

## Implementation
```hcl
resource "aws_instance" "nat" {
  ami                         = data.aws_ami.amazon_linux_arm.id
  instance_type               = "t4g.micro"
  source_dest_check           = false  # Required for NAT
  associate_public_ip_address = true
  user_data = <<-EOF
    #!/bin/bash
    sysctl -w net.ipv4.ip_forward=1
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  EOF
}
```

## Consequences
- Must monitor NAT instance health (add CloudWatch alarm in Phase 8).
- If instance fails, private subnet loses outbound access — restart manually.
- For production: upgrade to NAT Gateway or add auto-recovery.

## References
- [AWS NAT Instance vs Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-comparison.html)
- [Graviton Pricing](https://aws.amazon.com/ec2/graviton/)
