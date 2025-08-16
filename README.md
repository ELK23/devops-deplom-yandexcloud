# devops-deplom-yandexcloud
---

```markdown
# Kubernetes Addons Deployment with Makefile

This repository provides a **Makefile** that automates the deployment of:

- **Monitoring stack** (Prometheus, Grafana, Alertmanager)
- **Atlantis** (for Terraform pull request automation)

Both are deployed on the same Kubernetes cluster via Terraform and Helm, with ingress routing configured through `iptables` on the master node.

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.6
- [kubectl](https://kubernetes.io/docs/tasks/tools/) configured for your cluster
- [make](https://www.gnu.org/software/make/)
- OpenSSL (`openssl rand`) for token generation
- SSH access to the Kubernetes master node as `ubuntu` user
- Kubernetes cluster already deployed (via Terraform in `../`)

---

## Makefile Targets

### 🔹 Monitoring

1. **Generate ingress manifest**
   ```bash
   make monitoring-ingress
   ```
   Creates `../monitoring/monitoring-ingress.yaml` with your cluster’s master public IP.

2. **Generate Terraform variables**
   ```bash
   make monitoring-tfvars
   ```
   Creates `../monitoring/terraform.tfvars` with `k8s_master_public_ip`.

3. **Deploy monitoring stack**
   ```bash
   make monitoring-tf
   ```
   Runs `terraform init && terraform apply` inside `../monitoring`.

---

### 🔹 Atlantis

1. **Generate Terraform variables**
   ```bash
   make atlantis-tfvars
   ```
   Creates `../atlantis/terraform.tfvars` with:
   - Master IP
   - Placeholder for `github_user` and `github_repo`
   - Auto-generated placeholders for `github_token` and `webhook_secret`
   - `domain` set as `<MASTER_IP>.nip.io`

   > ⚠️ After generation, edit the file and replace:
   > - `github_user` → your GitHub username or org
   > - `github_repo` → repo in `org/repo` format
   > - `github_token` → your real GitHub PAT
   > - `webhook_secret` → a secret string (or keep auto-generated)

2. **Deploy Atlantis**
   ```bash
   make atlantis-tf
   ```
   Runs `terraform init && terraform apply` inside `../atlantis`.

---

### 🔹 Ingress Rules (shared for both monitoring and Atlantis)

Configure **iptables** on the Kubernetes master node to redirect ports 80/443 → ingress controller NodePorts:

```bash
make ingress-rules
```

This will:
- SSH into master node
- Add iptables rules if missing
- Install `iptables-persistent`
- Save rules permanently

---

## Access

- **Monitoring:**  
  - Grafana: `http://<MASTER_IP>.nip.io`
  - Prometheus/Alertmanager: via Ingress rules (check manifests)

- **Atlantis:**  
  - Web UI: `http://atlantis.<MASTER_IP>.nip.io`

---

## Notes

- Run `make monitoring-*` and `make atlantis-*` only **after the base Kubernetes cluster is deployed**.
- Ingress rules only need to be set up **once per cluster** (`make ingress-rules`).
- `terraform.tfvars` files are **auto-generated** but require **manual edits** for GitHub credentials.

---
```

---