#!/bin/bash
source "$(dirname "$0")/scripts/helper/load_helpers.sh"

# Function to list all pods with hostPath volumes
list_host_path_pods() {
    local namespace_option=""
    namespace_option=$(get_namespace_option "$1")

    {
        echo -e "NAMESPACE\tPOD\tPATHS"
        kubectl get pods $namespace_option -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\t"}{range .spec.volumes[?(@.hostPath)]}{.hostPath.path}{" "}{end}{"\n"}{end}'
    } | column -t | sed 's/ \+/ /g'
}

host_path_help() {
  echo -e "${GREEN}Usage: kubectl secops --host-path [namespace | --all]"
  echo ""
  echo "Description:"
  echo "  List all pods that are using hostPath volumes."
  echo ""
  echo "Options:"
  echo "  [namespace]        Specify a namespace to filter the pods."
  echo "  --all              List hostPath pods across all namespaces."
  echo ""
  echo "Examples:"
  echo "  kubectl secops --host-path                    # Default, Lists pods using hostPath in the current namespace"
  echo "  kubectl secops --host-path my-namespace       # Lists pods using hostPath in 'my-namespace'"
  echo "  kubectl secops --host-path --all              # Lists pods using hostPath across all namespaces"
  echo -e "${NC}"
  exit 0
}

register_switch "--host-path" "list_host_path_pods" "List all pods using hostPath volumes" "host_path_help"
