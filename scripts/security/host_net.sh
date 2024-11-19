#!/bin/bash
source "$(dirname "$0")/scripts/helper/load_helpers.sh"

# Function to list all pods with hostNetwork enabled
list_host_network_pods() {
    local namespace_option=""
    namespace_option=$(get_namespace_option "$1")

    {
        echo -e "NAMESPACE\tPOD\tCONTAINER"
        kubectl get pods $namespace_option -o jsonpath='{range .items[?(@.spec.hostNetwork==true)]}{.metadata.namespace}{"\t"}{.metadata.name}{"\t"}{range .spec.containers[*]}{.name}{"\n"}{end}{end}'
    } | column -t
}

host_network_help() {
  echo -e "${GREEN}Usage: kubectl secops --host-net [namespace | --all]"
  echo ""
  echo "Description:"
  echo "  List all pods that are using the host network."
  echo ""
  echo "Options:"
  echo "  [namespace]        Specify a namespace to filter the pods."
  echo "  --all              List host network pods across all namespaces."
  echo ""
  echo "Examples:"
  echo "  kubectl secops --host-net                    # Default, Lists pods using host network in the current namespace"
  echo "  kubectl secops --host-net my-namespace       # Lists pods using host network in 'my-namespace'"
  echo "  kubectl secops --host-net --all              # Lists pods using host network across all namespaces"
  echo -e "${NC}"
  exit 0
}

register_switch "--host-net" "list_host_network_pods" "List all pods using host network" "host_network_help"
