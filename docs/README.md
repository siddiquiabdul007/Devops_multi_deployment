# DevOps Multicloud Platform

## Overview
A production-grade microservices system demonstrating Kubernetes deployment, Terraform automation, CI/CD, and Observability. 

Currently deployed on Azure (AKS) with preparations for cross-cloud capabilities.

## Architecture

*Note: For the official Draw.io diagram, please see `architecture.drawio` (stubbed) in this folder or use the mermaid diagram below for quick reference.*

```mermaid
flowchart TD
    User([User]) --> Ingress

    subgraph AKS Cluster
      Ingress --> USvc[User Service / ClusterIP]
      Ingress --> OSvc[Order Service / ClusterIP]
      
      OSvc -->|Internal HTTP| USvc
    end

    subgraph Monitoring
      Prom[Prometheus]
      Grafana[Grafana]
      Prom -.->|Scrapes| USvc
      Prom -.->|Scrapes| OSvc
      Grafana -.-> Prom
    end

    subgraph CI/CD
      GitHubActions[GitHub Actions]
      ACR[Azure Container Registry]
      GitHubActions -->|Pushes Images| ACR
      GitHubActions -->|Applies Manifests| AKS Cluster
      ACR -.->|Pulled by| AKS Cluster
    end
```

### Components:
- **user-service**: NodeJS app serving dummy users.
- **order-service**: NodeJS app serving dummy orders, internally calling `user-service`.
- **Infrastructure**: Terraform scripts located in `infra/terraform/` provision the AKS Cluster, ACR, and Resource Groups.
- **CI/CD**: GitHub Actions workflow (`cicd/github-actions-pipeline.yml`) builds, tags (with Git SHA), pushes to ACR, and deploys to AKS.
- **Monitoring**: Kube-Prometheus stack via Helm configured in `monitoring/`.

## How to Run

### 1. Provision Infrastructure
```bash
cd infra/terraform/envs/dev
terraform init
terraform plan
terraform apply
```

### 2. Configure Local Kubectl
Use the terraform output or Azure CLI:
```bash
az aks get-credentials --resource-group multicloud-dev-rg --name multicloud-dev-aks
```

### 3. Deploy Kubernetes Resources Manually (if not using CI/CD)
```bash
kubectl apply -f k8s/base/
```

### 4. Install Monitoring
```bash
cd monitoring
chmod +x install-monitoring.sh
./install-monitoring.sh
```

## Scaling Strategy
- **Horizontal Pod Autoscaling (HPA)**: Both `user-service` and `order-service` include HPA definitions to scale between 2 and 5 replicas automatically based on CPU utilization crossing the 70% threshold.
- **Node Scaling**: The Terraform AKS cluster currently specifies a `node_count` of 2. For production, this can be changed to an `azurerm_kubernetes_cluster_node_pool` with `enable_auto_scaling = true`.

## CI/CD Flow
1. Developer pushes to the `main` branch.
2. The pipeline checks out the code, sets up Node.js, and installs dependencies.
3. Tests (if any) are run.
4. Docker images are built and pushed to the Azure Container Registry, tagged with the commit SHA and `latest`.
5. The pipeline injects the commit SHA tag directly into the Kubernetes manifest and applies it to the cluster.
6. The pipeline waits for a successful rollout. If it fails, it triggers an undo to rollback.
