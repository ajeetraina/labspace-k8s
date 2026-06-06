# Creating Clusters with Kind

**Kind** (Kubernetes in Docker) is a tool for running local Kubernetes clusters using Docker containers as nodes. Each "node" is actually a Docker container running the Kubernetes components. This makes it perfect for local development and testing.

```mermaid
graph TD
    A[Docker Engine] --> B[kind-control-plane container]
    A --> C[kind-worker container]
    A --> D[kind-worker2 container]
    B --> E[K8s Control Plane + etcd]
    C --> F[kubelet + Pods]
    D --> G[kubelet + Pods]
```

## Install Kind

1. Download and install the Kind binary:

    ```bash
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64 && chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind
    ```

2. Verify the installation:

    ```bash
    kind version
    ```

## Create a single-node cluster

A single-node Kind cluster runs both the control plane and workloads on one container. This is the simplest setup.

1. Create a cluster named `single-node`:

    ```bash
    kind create cluster --name single-node --wait 60s
    ```

    Kind will pull the node image, create a Docker container, and configure Kubernetes inside it. This takes about a minute.

2. Check that the cluster is running:

    ```bash
    kubectl cluster-info --context kind-single-node
    ```

3. List the nodes — you should see exactly one:

    ```bash
    kubectl get nodes --context kind-single-node
    ```

4. Look at the Docker container backing this cluster:

    ```bash
    docker ps --filter "name=single-node"
    ```

    Notice that the Kubernetes "node" is actually a Docker container!

## Create a multi-node cluster

A multi-node cluster has separate control plane and worker nodes, just like a production environment. Kind uses a YAML configuration file to define the cluster topology.

1. Review the multi-node configuration file:

    Open :fileLink[kind-configs/multi-node.yaml]{path="kind-configs/multi-node.yaml"} in the editor.

    ```yaml no-run-button
    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4
    nodes:
      - role: control-plane
      - role: worker
      - role: worker
    ```

    This defines one control-plane node and two worker nodes.

2. Create the multi-node cluster using this config:

    ```bash
    kind create cluster --name multi-node --config kind-configs/multi-node.yaml --wait 120s
    ```

3. List the nodes in the new cluster:

    ```bash
    kubectl get nodes --context kind-multi-node
    ```

    You should see three nodes: one control-plane and two workers.

4. See all Kind clusters running on your machine:

    ```bash
    kind get clusters
    ```

5. Check the Docker containers — each node is its own container:

    ```bash
    docker ps --filter "label=io.x-k8s.kind.cluster"
    ```

## Switch between clusters

When you have multiple clusters, use `kubectl config` to switch between them:

1. List all available contexts:

    ```bash
    kubectl config get-contexts
    ```

2. Switch to the multi-node cluster:

    ```bash
    kubectl config use-context kind-multi-node
    ```

3. Verify you are targeting the right cluster:

    ```bash
    kubectl get nodes
    ```

> [!NOTE]
> For the rest of this lab, you will use the **multi-node** cluster. Make sure it is your active context before continuing.

## Clean up the single-node cluster

Since you will use the multi-node cluster going forward, delete the single-node one to free resources:

```bash
kind delete cluster --name single-node
```

You now have a multi-node Kubernetes cluster running entirely in Docker containers. In the next section, you will deploy your first workloads as Pods.
