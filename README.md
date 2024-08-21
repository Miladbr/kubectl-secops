# SecOps: A Kubernetes Security and Operations Utility Tool

SecOps is a kubectl plugin that makes it easy to run essential one-liners for security checks and operational tasks in Kubernetes clusters. It’s built with modular scripts, each designed for specific tasks.

## Installation

### Prerequisites

- kubectl
- jq

### Quick

```
git clone https://github.com/miladbr/kubectl-secops.git && cd kubectl-secops && chmod +x kubectl-secops && echo 'export PATH=$PATH:'"$(pwd)" >> ~/.zshrc && source ~/.zshrc && kubectl secops --help
```

### Steps

1. **Clone the repository**:
```
$ git clone https://github.com/miladbr/kubectl-secops.git
$ cd kubectl-secops
```

2. **Make the plugin executable**:

```
$ chmod +x kubectl-secops
```

3. **Add the plugin to your PATH**:

- Bash
```
$ echo 'export PATH=$PATH:'"$(pwd)" >> ~/.bashrc
$ source ~/.bashrc

```
- Zsh
```
$ echo 'export PATH=$PATH:'"$(pwd)" >> ~/.zshrc
$ source ~/.zshrc
```
This allows you to run the plugin with kubectl secops.

### Usage

You can run the plugin using the following command:
    
```
$ kubectl secops [command]
```

### Available Commands:

```
  --help          Display this help message
  --create-config Create a kubeconfig file for a service account
  --create-sa     Create a ServiceAccount and Secret
  --get-ing       Retrieve ingress resources with aligned output and namespace option
  --get-pvc       Retrieve and display detailed information about PVCs with optional size filtering
  --image-version List all images name and tag
  --nodes-ip      Retrieve and display the internal IP addresses of nodes
  --pod-node      List all pods along with their node placement
  --pod-pending   Retrieve pending pods with detailed information and namespace option
  --pod-resources List all pods with their containers and resource requests and limits
  --ptoprst       List pods with more than a specified restart count
  --pod-secrets   List all unique secret names used in environment variables
  --top-pods      Displays the top resource-consuming pods on a specified node.
  --rd-nodes      List all nodes in the Ready state
  --test-sa       Perform a curl request to the Kubernetes API using a service account
  --unavail-deploy List deployments with unavailable replicas
  --tara          Approve tara
  --bad-cap       List all pods with bad capabilities
  --dec-sect      Decode and display Kubernetes secrets
  --host-net      List all pods using host network
  --host-path     List all pods using hostPath volumes
  --host-pid      List all pods using host PID namespace
  --priv-pods     List all pods with privileged containers
```

### Example Commands:
- Each command have specific help:
```
$ kubectl secops --get-pvc --help
Usage: kubectl secops --get-pvc [--all | <namespace>] [size-threshold]

Description:
  Retrieves and displays detailed information about Persistent Volume Claims (PVCs) across all namespaces or within a specific namespace.
  If no arguments are provided, the command runs in the current namespace.
  Optionally filters PVCs to show only those with a size greater than the specified threshold.

Options:
  --all              List PVCs across all namespaces.
  <namespace>        Specify a namespace to filter the PVCs.
  <size-threshold>   (Optional) Specify a size threshold (e.g., 500Mi, 5Gi). Only PVCs larger than this size will be displayed.

Examples:
  kubectl secops --get-pvc                # Get PVCs in the current namespace
  kubectl secops --get-pvc --all          # Get PVCs across all namespaces
  kubectl secops --get-pvc my-namespace   # Get PVCs in 'my-namespace'
  kubectl secops --get-pvc --all 1Gi      # Get PVCs across all namespaces larger than 1Gi
  kubectl secops --get-pvc 20Gi           # Get PVCs in the current namespace larger than 20Gi
```

- Find pvc in kube-system namespace that are more than 20Gi
```
$ kubectl secops --get-pvc kube-system 20g
```

- Find all image version in security-system namespace.
```
$ kubectl secops --image-version security-system
```
- Find all pods that scheduled on nodes with label nodepool=gw
```
$ kubectl secops --pod-node nodepool=gw
```
- Find all pods that scheduled on node c18-s10
```
$ kubectl secops --pod-node c18-s10
```
- Find all ingresses (Host and Path) in security-system namespace
```
$ kubectl secops --get-ing security-system 
```
- Create a kubeconfig for service account k8s-access in the platform namespace
```
$ kubectl secops --create-config security-system manage-k8s-access
```