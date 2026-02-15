# Contributing to FinTrack Platform

Thank you for considering contributing to this project! This guide will help you get started.

## Commit Convention

We use [Conventional Commits](https://www.conventionalcommits.org/). Every commit message must follow this format:

```
<type>(<scope>): <subject>

<body>
```

### Types
| Type       | Description                           |
|------------|---------------------------------------|
| `feat`     | A new feature                         |
| `fix`      | A bug fix                             |
| `docs`     | Documentation only changes            |
| `chore`    | Build process, tooling, dependencies  |
| `refactor` | Code change that neither fixes nor adds |
| `test`     | Adding or updating tests              |
| `ci`       | CI/CD configuration changes           |

### Scopes
Use the component name: `vpc`, `eks`, `helm`, `app`, `argocd`, `ci`, `monitoring`, `docs`.

### Examples
```
feat(vpc): add NAT instance with t4g.micro for cost savings
docs(decisions): add ADR-001 explaining eu-north-1 region choice
fix(helm): correct ingress annotations for ALB controller
chore: update .gitignore with Terraform state files
```

## Branch Naming

```
feature/<phase-or-topic>    # e.g., feature/terraform-v2
fix/<issue-description>     # e.g., fix/nat-routing
docs/<topic>                # e.g., docs/adrs
```

## Pull Request Process

1. Create a feature branch from `develop`.
2. Make small, focused commits (one logical change per commit).
3. Write a descriptive PR title using conventional commit format.
4. Fill out the PR template completely.
5. Ensure all checks pass (`pre-commit`, `terraform validate`, `helm lint`).
6. Request review and wait for approval before merging.

## Development Setup

```bash
# Clone and setup
git clone <repo-url>
cd cloud-native-eks-platform
git checkout develop

# Install pre-commit hooks
pip install pre-commit
pre-commit install

# Local app development
cd app && npm install
docker-compose up
```

## Code Standards

- **Terraform**: Run `terraform fmt` before committing. Use variables for all configurable values.
- **Helm**: Run `helm lint` on chart changes. Use `_helpers.tpl` for common labels.
- **YAML**: Valid YAML (checked by pre-commit hooks).
- **Docs**: Update relevant README, ADR, or how-to guide when making changes.
