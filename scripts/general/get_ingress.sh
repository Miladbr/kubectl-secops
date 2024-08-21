#!/bin/bash
source "$(dirname "$0")/scripts/helper/common.sh"
source "$(dirname "$0")/scripts/helper/ns_helper.sh"
source "$(dirname "$0")/scripts/helper/colors.sh"

# Function to get ingress resources with aligned output and namespace option
get_ingress_resources() {
  local namespace_option

  namespace_option=$(get_namespace_option "$1")

  kubectl get ing $namespace_option -o='custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,HOSTS:.spec.rules[*].host,PATHS:.spec.rules[*].http.paths[*].path' | column -t -s $'\t'
}

get_ing_help() {
  echo -e "${GREEN}Usage: kubectl secops --get-ing [--all | <namespace>]"
  echo ""
  echo "Description:"
  echo "  Retrieves ingress resources from the specified namespace or all namespaces with aligned output."
  echo ""
  echo "Options:"
  echo "  --all              List ingress resources across all namespaces."
  echo "  <namespace>        Specify a namespace to filter the ingress resources."
  echo ""
  echo "Examples:"
  echo "  kubectl secops --get-ing --all            # Get ingress resources across all namespaces"
  echo "  kubectl secops --get-ing my-namespace     # Get ingress resources in 'my-namespace'"
  echo -e "${NC}"
  exit 0
}

register_switch "--get-ing" "get_ingress_resources" "Retrieve ingress resources with aligned output and namespace option" "get_ing_help"
