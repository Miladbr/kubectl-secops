#!/bin/bash
source "$(dirname "$0")/scripts/helper/load_helpers.sh"

# Function to list all pods with hostPID enabled
list_host_pid_pods() {
    local namespace_option=""
    namespace_option=$(get_namespace_option "$1")

    {
        echo -e "NAMESPACE\tPOD\tCONTAINER"
        kubectl get pods $namespace_option -o jsonpath='{range .items[?(@.spec.hostPID==true)]}{.metadata.namespace}{"\t"}{.metadata.name}{"\t"}{range .spec.containers[*]}{.name}{"\n"}{end}{end}'
    } | column -t
}

host_pid_help() {
  echo -e "${GREEN}Usage: kubectl secops --host-pid [namespace | --all]"
  echo ""
  echo "Description:"
  echo "  List all pods that are using the host process ID namespace (hostPID)."
  echo ""
  echo "Options:"
  echo "  [namespace]        Specify a namespace to filter the pods."
  echo "  --all              List host PID pods across all namespaces."
  echo ""
  echo "Examples:"
  echo "  kubectl secops --host-pid                    # Default, Lists pods using host PID in the current namespace"
  echo "  kubectl secops --host-pid my-namespace       # Lists pods using host PID in 'my-namespace'"
  echo "  kubectl secops --host-pid --all              # Lists pods using host PID across all namespaces"
  echo -e "${NC}"
  exit 0
}

register_switch "--host-pid" "list_host_pid_pods" "List all pods using host PID namespace" "host_pid_help"
