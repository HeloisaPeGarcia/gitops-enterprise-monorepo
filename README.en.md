# 🚀 Enterprise GitOps & Infrastructure Monorepo Repository

<p align="center">
  <a href="README.md">Português</a> | <b>English</b>
</p>

***

[![GitOps CI & Security Validation](https://github.com/HeloisaPeGarcia/argo-cd/actions/workflows/gitops-ci.yml/badge.svg)](https://github.com/HeloisaPeGarcia/argo-cd/actions/workflows/gitops-ci.yml)
![Terragrunt](https://img.shields.io/badge/Terragrunt-v0.55%2B-blue?style=flat&logo=terraform)
![ArgoCD](https://img.shields.io/badge/ArgoCD-v2.10%2B-orange?style=flat&logo=argo)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.29%2B-326CE5?style=flat&logo=kubernetes)
![Helm](https://img.shields.io/badge/Helm-v3-0F1689?style=flat&logo=helm)
![License](https://img.shields.io/badge/License-MIT-green.svg)

This repository establishes an **Enterprise Monorepo Reference Architecture** for cloud infrastructure provisioning (**Terragrunt / Terraform**) and declarative application deployment (**Argo CD GitOps**).

The solution is designed with a focus on **layered decoupling**, **least privilege (RBAC)**, **workload resilience**, and **DevSecOps**.

---

## 📂 Reorganized Folder Structure

```
.
├── .github/
│   └── workflows/
│       └── gitops-ci.yml               # CI/CD: Linting, Kubeconform (Strict), Trivy and Gitleaks
├── iac/                                # Infrastructure as Code (Terragrunt + Terraform)
│   ├── terragrunt.hcl                  # Global remote state (S3 + DynamoDB) & AWS providers
│   ├── _envcommon/                     # Reusable (DRY) VPC & EKS configurations
│   └── environments/
│       ├── dev/ (env.hcl, vpc, eks)    # Dev environment infrastructure (Capacity: SPOT)
│       └── prod/ (env.hcl, vpc, eks)   # Prod environment infrastructure (Capacity: ON_DEMAND)
├── platform/                           # Platform Add-ons & Cluster Services
│   ├── argo-rollouts.yaml
│   ├── nginx-ingress.yaml
│   ├── prometheus.yaml
│   ├── sealed-secrets.yaml
│   └── notifications-config.yaml
├── applications/                       # Application Workload Manifests & ApplicationSets
│   └── sample-app-appset.yaml
├── argocd/                             # ArgoCD Bootstrap & RBAC Governance
│   ├── root-app.yaml                   # Entrypoint (App-of-Apps)
│   └── projects/
│       ├── system-project.yaml         # AppProject with platform team privileges
│       └── workloads-project.yaml      # AppProject restricted for tenant development teams
├── charts/                             # Reusable Helm Charts
│   └── sample-app/                     # Chart with PDB, Non-root securityContext & TopologySpread
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/ (rollout, pdb, ingress, service, sealed-secret, hpa, analysis)
├── environments/                       # Per-environment variable overrides
│   ├── dev/values.yaml
│   └── prod/values.yaml
├── scripts/
│   ├── bootstrap.bat                   # Windows automation script
│   └── bootstrap.sh                    # Linux/macOS/WSL automation script
├── Taskfile.yml                        # Cross-platform task runner (Makefile alternative)
└── README.md
```

---

## ⚡ Quickstart

```bash
# Start local Kind cluster and ArgoCD with Taskfile
task dev:up

# Run Helm chart linting
task lint

# Run Terragrunt plan for DEV environment
task iac:plan
```
