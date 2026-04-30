# 🧭 RUNBOOK — GitOps Platform (AKS + ArgoCD)

## 📌 Purpose

This runbook documents **operational procedures, known failure modes, and recovery steps** for the GitOps platform deployed on Azure Kubernetes Service (AKS).

It is intended for:

* DevOps engineers operating the platform
* Incident responders troubleshooting production issues
* Future maintainers onboarding onto the system

---

## 🏗️ System Overview

```text
GitHub Actions → Azure Container Registry (ACR)
                 ↓
             ArgoCD (GitOps)
                 ↓
        Azure Kubernetes Service (AKS)
                 ↓
        NGINX Ingress Controller
                 ↓
             End Users
```

---

## 🚨 Incident Handling Workflow

1. **Identify Symptoms**
2. **Check System State**

   ```bash
   kubectl get pods -A
   kubectl get applications -n argocd
   ```
3. **Locate Root Cause**
4. **Apply Fix**
5. **Verify Resolution**
6. **Document if new**

---

# ⚙️ Known Issues & Resolutions

---

## 1. AKS OIDC — Cannot Be Disabled

### Symptoms

* Terraform apply fails:

  ```
  OIDCIssuerFeatureCannotBeDisabled
  ```

### Root Cause

AKS permanently enables OIDC once turned on. Terraform attempts to disable it if not explicitly set.

### Fix

```hcl
oidc_issuer_enabled       = true
workload_identity_enabled = true
```

### Verification

```bash
az aks show --name <cluster> --resource-group <rg> --query "oidcIssuerProfile.enabled"
```

---

## 2. ArgoCD CRD — Annotation Size Limit

### Symptoms

```
metadata.annotations: Too long
```

### Root Cause

Client-side apply stores large CRD schema in annotations (exceeds 256KB limit).

### Fix

```bash
kubectl apply --server-side --force-conflicts -k k8s/argocd/
```

### Verification

```bash
kubectl get crds | grep applicationset
```

---

## 3. Ingress Host Conflicts

### Symptoms

```
host "_" already defined
```

### Root Cause

NGINX validates ingress globally—duplicate host/path combinations are rejected.

### Fix

Use per-environment hostnames:

```yaml
dev.api.example.com
staging.api.example.com
prod.api.example.com
```

### Verification

```bash
kubectl get ingress -A
```

---

## 4. Wrong ACR Reference

### Symptoms

```
ErrImagePull / no such host
```

### Root Cause

Manifests reference outdated ACR registry.

### Fix

```bash
sed -i '' 's|old-acr|new-acr|g' k8s/base/*.yaml
```

### Verification

```bash
kubectl describe pod <pod> | grep Image
```

---

## 5. Node Capacity Exhaustion

### Symptoms

```
0/1 nodes available: Insufficient cpu
```

### Root Cause

Cluster resources insufficient for workloads.

### Fix

```bash
az aks nodepool scale --node-count 2
```

Reduce replicas:

```yaml
minReplicas: 1
```

### Verification

```bash
kubectl get pods -A
```

---

## 6. Missing VPA CRDs

### Symptoms

```
VerticalPodAutoscaler not found
```

### Root Cause

AKS does not include VPA CRDs.

### Fix

```bash
kubectl apply -f https://.../vpa-v1-crd-gen.yaml
```

### Verification

```bash
kubectl get crds | grep vertical
```

---

## 7. cert-manager Webhook TLS Error

### Symptoms

```
x509: certificate signed by unknown authority
```

### Root Cause

Webhook CA bundle out of sync.

### Fix

```bash
kubectl delete validatingwebhookconfiguration cert-manager-webhook
kubectl delete mutatingwebhookconfiguration cert-manager-webhook
```

### Verification

```bash
kubectl get clusterissuer
```

---

## 8. Terraform State Migration Prompt

### Symptoms

```
Do you want to copy existing state?
```

### Fix

```bash
terraform init -migrate-state -force-copy
```

---

## 9. k6 DNS Resolution Failure

### Symptoms

```
no such host
```

### Root Cause

Using non-resolvable example domains.

### Fix

```bash
k6 run \
  --env TARGET_URL=http://<INGRESS_IP> \
  --env HOST_HEADER=dev.api.example.com \
  tests/smoke.js
```

---

# 📊 Observability Validation

## Prometheus Targets

```bash
kubectl port-forward svc/prometheus 9090:9090 -n monitoring
```

→ Check `/targets` UI (must be UP)

## Grafana

```bash
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
```

## Alertmanager

```bash
kubectl get alertmanagerconfig -A
```

---

# 🔁 Rollback Procedure

## Git-based rollback

```bash
git checkout before-transformation
git push origin main
```

## ArgoCD sync

```bash
kubectl patch application <app> -n argocd \
  -p '{"operation":{"sync":{"revision":"HEAD"}}}'
```

---

# 💸 Cost Management

```bash
# Stop cluster
az aks stop --name devops-dev-aks --resource-group devops-dev-rg

# Start cluster
az aks start --name devops-dev-aks --resource-group devops-dev-rg
```

---

# 🛠️ Useful Commands

```bash
kubectl get applications -n argocd
kubectl get pods -A
kubectl get ingress -A
kubectl get svc -A
```

---

# 📌 Final Notes

* Always verify fixes using `kubectl get pods -A`
* Prefer **server-side apply** for large manifests
* Keep image references consistent across CI/CD and GitOps
* Monitor resource usage before scaling workloads

---

## 🏁 Status

✔ Fully operational multi-environment GitOps platform
✔ Validated via functional tests and observability stack
✔ Production-ready with known limitations documented
