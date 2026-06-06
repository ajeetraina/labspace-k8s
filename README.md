# Kubernetes on Docker Desktop

An interactive labspace that teaches Kubernetes fundamentals using Docker Desktop's built-in Kubernetes support.

## What you will learn

- Enable Kubernetes on Docker Desktop (Kubeadm single-node and Kind multi-node)
- Create and manage Pods, Deployments, and Services
- Scale applications and perform rolling updates
- Convert Docker Compose files to Kubernetes manifests using Compose Bridge

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (4.51+) with Kubernetes enabled
- [ttyd](https://github.com/tsl0922/ttyd) installed (`brew install ttyd` on macOS)

## Quick start

```bash
git clone https://github.com/ajeetraina/labspace-k8s
cd labspace-k8s
bash start-labspace.sh
```

Open [http://localhost:3030](http://localhost:3030) to access the lab. Instructions appear on the left panel and the terminal (powered by ttyd) on the right.

## Lab sections

| # | Section | Topics |
|---|---------|--------|
| 1 | Enable Kubernetes on Docker Desktop | GUI/CLI setup, verify kubectl, first deployment |
| 2 | Multi-Node Clusters with Kind | Kind via Docker Desktop, node inspection, context switching |
| 3 | Working with Pods | Imperative and declarative Pods, labels, selectors |
| 4 | Deployments and Scaling | Replicas, rolling updates, rollbacks |
| 5 | Services and Networking | ClusterIP, NodePort, DNS, endpoints |
| 6 | Compose Bridge to Kubernetes | Convert Compose files, deploy with Kustomize |

## Project files

- `bb.yaml` — Sample Deployment + Service manifest (Docker docs pattern)
- `k8s/` — Kubernetes manifests (Pod, Deployment, ClusterIP and NodePort Services)
- `sample-compose/` — Docker Compose file for the Compose Bridge exercise

## Local development

To develop and preview content changes:

```bash
bash start-labspace.sh
```

Edit the markdown files in `labspace/` — changes are reflected in the browser without restart.

## Setting up the deployment pipeline

1. Add GitHub Action Secrets in your repo:
   - `DOCKERHUB_USERNAME` — Docker Hub username
   - `DOCKERHUB_TOKEN` — Docker Hub personal access token
2. Update `DOCKERHUB_REPO` in `.github/workflows/publish-labspace.yaml.temp`
3. Rename the workflow file:
   ```bash
   mv .github/workflows/publish-labspace.yaml.temp .github/workflows/publish-labspace.yaml
   ```
