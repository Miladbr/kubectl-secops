#!/bin/bash
source "$(dirname "$0")/scripts/helper/common.sh"
source "$(dirname "$0")/scripts/helper/ns_helper.sh"
source "$(dirname "$0")/scripts/helper/colors.sh"

# Function to get pending pods with detailed information and namespace option
# Source: https://gist.github.com/stewartshea/24af6a3c709a53a4e34be8ba5f8d18a7
get_pending_pods() {
  local namespace_option
  local namespace

  namespace_option=$(get_namespace_option "$1")

  if [ -z "$namespace_option" ]; then
    namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}')
    if [ -z "$namespace" ]; then
      namespace="default"
    fi
    namespace_option="-n $namespace"
  fi

  kubectl get pods $namespace_option --field-selector=status.phase=Pending --no-headers -o json | \
  jq -r '.items[] | "namespace: \(.metadata.namespace)\npod: \(.metadata.name)\nmessage: \(.status.conditions[].message // "N/A")\nreason: \(.status.conditions[].reason // "N/A")\ncontainerStatus: \((.status.containerStatuses // [{}])[].state // "N/A")\ncontainerMessage: \((.status.containerStatuses // [{}])[].state?.waiting?.message // "N/A")\ncontainerReason: \((.status.containerStatuses // [{}])[].state?.waiting?.reason // "N/A")\n---\n"' | column -t -s $'\t'
}

get_pending_pods_help() {
  echo -e "${GREEN}Usage: kubectl secops --pod-pending [--all | <namespace>]"
  echo ""
  echo "Description:"
  echo "  Retrieves pending pods from the specified namespace or all namespaces with detailed information."
  echo ""
  echo "Options:"
  echo "  --all              List pending pods across all namespaces."
  echo "  <namespace>        Specify a namespace to filter the pending pods."
  echo ""
  echo "Examples:"
  echo "  kubectl secops --pod-pending --all            # Get pending pods across all namespaces"
  echo "  kubectl secops --pod-pending my-namespace     # Get pending pods in 'my-namespace'"
  echo -e "${NC}"
  exit 0
}

register_switch "--pod-pending" "get_pending_pods" "Retrieve pending pods with detailed information and namespace option" "get_pending_pods_help"
