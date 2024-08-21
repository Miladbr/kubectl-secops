#!/bin/bash
source "$(dirname "$0")/scripts/helper/ns_helper.sh"
source "$(dirname "$0")/scripts/helper/colors.sh"


# Function to list all privileged pods
list_privileged_pods() {
    local namespace_option=""
    namespace_option=$(get_namespace_option "$1")

    {
        echo -e "NAMESPACE\tPOD\tCONTAINER"
        kubectl get pods $namespace_option -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\t"}{range .spec.containers[*]}{.name}{"\t"}{.securityContext.privileged}{"\n"}{end}{end}' | awk '$4 == "true" {print $1 "\t" $2 "\t" $3}'
    } | column -t
}

priv_pods_help() {
    echo -e "${GREEN}Usage: kubectl secops --priv-pods [namespace | --all]"
    echo ""
    echo "Description:"
    echo "  List all pods with containers that have been granted privileged access."
    echo ""
    echo "Options:"
    echo "  [namespace]        Specify a namespace to filter the pods."
    echo "  --all              List privileged pods across all namespaces."
    echo ""
    echo "Examples:"
    echo "  kubectl secops --priv-pods                    # Default, Lists privileged pods in the current namespace"
    echo "  kubectl secops --priv-pods my-namespace       # Lists privileged pods in 'my-namespace'"
    echo "  kubectl secops --priv-pods --all              # Lists privileged pods across all namespaces"
    echo -e "${NC}"
    exit 0
}

register_switch "--priv-pods" "list_privileged_pods" "List all pods with privileged containers" "priv_pods_help"
