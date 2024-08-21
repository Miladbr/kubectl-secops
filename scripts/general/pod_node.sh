#!/bin/bash
source "$(dirname "$0")/scripts/helper/colors.sh"

# Function to list pods based on nodes
list_pod_node() {
    local namespace_option="--all-namespaces"
    local node_filter=""
    local nodes=""
    local pod_results=""

    if [ -n "$1" ]; then
        if kubectl get node "$1" &> /dev/null; then
            node_filter="$1"
        else
            nodes=$(kubectl get nodes --selector "$1" -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
            if [ -z "$nodes" ]; then
                echo "No nodes found with label: $1"
                exit 1
            fi

            for node in $nodes; do
                local node_pods=$(kubectl get pods $namespace_option --field-selector spec.nodeName=$node -o custom-columns=NAMESPACE:.metadata.namespace,POD:.metadata.name,NODE:.spec.nodeName | tail -n +2)
                
                if [ -n "$node_pods" ]; then
                    pod_results+="$node_pods"$'\n'
                fi
            done

            if [ -n "$pod_results" ]; then
                echo -e "NAMESPACE\tPOD\tNODE\n$pod_results" | column -t
            else
                echo "No pods found on nodes with label: $1"
            fi

            return
        fi
    fi

    if [ -n "$node_filter" ]; then
        kubectl get pods $namespace_option --field-selector spec.nodeName=$node_filter -o custom-columns=NAMESPACE:.metadata.namespace,POD:.metadata.name,NODE:.spec.nodeName | column -t
    else
        kubectl get pods $namespace_option -o custom-columns=NAMESPACE:.metadata.namespace,POD:.metadata.name,NODE:.spec.nodeName | column -t
    fi
}

pod_node_help() {
  echo -e "${GREEN}Usage: kubectl secops --pod-node [node-name | node-label]"
  echo ""
  echo "Description:"
  echo "  List pods based on nodes"
  echo ""
  echo "Options:"
  echo "  [node-name]       List pods on a specific node by specified name."
  echo "  [node-label]      List pods on nodes matching a label."
  echo ""
  echo "If no node name or label is provided, all pods and their node placement will be listed."
  echo "Examples:"
  echo "  kubectl secops --pod-node c18-n2"
  echo "  kubectl secops --pod-node nodepool=gw"
  echo -e "${NC}"
  exit 0
}

register_switch "--pod-node" "list_pod_node" "List all pods along with their node placement" "pod_node_help"
