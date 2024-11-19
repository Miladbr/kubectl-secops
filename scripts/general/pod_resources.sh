#!/bin/bash
source "$(dirname "$0")/scripts/helper/load_helpers.sh"

# Function to list pods with resource requests and limits (memory and CPU)
list_pod_resources() {
    local namespace_option=""
    namespace_option=$(get_namespace_option "$1")

    {
        echo -e "NAMESPACE\tPOD\tCONTAINER\tMEM_REQ\tCPU_REQ\tMEM_LIMIT\tCPU_LIMIT"
        kubectl get pods $namespace_option -o json | \
        jq -r '.items[] | 
               .spec.containers[] as $container | 
               {namespace: .metadata.namespace, 
                pod_name: .metadata.name, 
                container_name: $container.name, 
                memory_requested: ($container.resources.requests.memory // "none"), 
                cpu_requested: ($container.resources.requests.cpu // "none"), 
                memory_limit: ($container.resources.limits.memory // "none"), 
                cpu_limit: ($container.resources.limits.cpu // "none")} | 
               [.namespace, .pod_name, .container_name, .memory_requested, .cpu_requested, .memory_limit, .cpu_limit] | 
               @tsv'
    } | column -t
}

pod_resources_help() {
    echo -e "${GREEN}Usage: kubectl secops --pod-resources [namespace | --all]"
    echo ""
    echo "Description:"
    echo "  List all pods with their containers and resource requests and limits (memory and CPU)."
    echo ""
    echo "Options:"
    echo "  [namespace]        Specify a namespace to filter the pods."
    echo "  --all              List pods and their resources across all namespaces."
    echo ""
    echo "Examples:"
    echo "  kubectl secops --pod-resources                    # Default, Lists pod resources in the current namespace"
    echo "  kubectl secops --pod-resources my-namespace       # Lists pod resources in 'my-namespace'"
    echo "  kubectl secops --pod-resources --all              # Lists pod resources across all namespaces"
    echo -e "${NC}"
    exit 0
}

register_switch "--pod-resources" "list_pod_resources" "List all pods with their containers and resource requests and limits" "pod_resources_help"
