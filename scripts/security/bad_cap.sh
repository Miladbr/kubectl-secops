#!/bin/bash
source "$(dirname "$0")/scripts/helper/load_helpers.sh"

# Function to list all pods with bad capabilities
list_bad_cap() {
    local namespace_option=""
    namespace_option=$(get_namespace_option "$1")
    
    {
        echo -e "NAMESPACE\tPOD\tCAPS"
        kubectl get pods $namespace_option -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\t"}{range .spec.containers[*]}{.securityContext.capabilities.add}{"\n"}{end}{range .spec.initContainers[*]}{.securityContext.capabilities.add}{"\n"}{end}{end}' | \
        grep --color=always -E 'SYS_ADMIN|NET_ADMIN|SYS_MODULE|SYS_PTRACE|MKNOD|SYS_TIME|CAP_SYS_BOOT|SYS_RESOURCE'
    } | column -t
}

bad_cap_help() {
  echo -e "${GREEN}Usage: kubectl secops --bad-cap [namespace | --all]"
  echo ""
  echo "Description:"
  echo "  List all pods with containers that have been granted potentially dangerous capabilities."
  echo ""
  echo "Options:"
  echo "  [namespace]        Specify a namespace to filter the pods."
  echo "  --all              List privileged pods across all namespaces."
  echo ""
  echo "Examples:"
  echo "  kubectl secops --bad-cap                    # Default, Lists pods with bad capabilities in the current namespace"
  echo "  kubectl secops --bad-cap my-namespace       # Lists pods with bad capabilities in 'my-namespace'"
  echo "  kubectl secops --bad-cap --all              # Lists pods with bad capabilities across all namespaces"
  echo -e "${NC}"
  exit 0
}

register_switch "--bad-cap" "list_bad_cap" "List all pods with bad capabilities" "bad_cap_help"
