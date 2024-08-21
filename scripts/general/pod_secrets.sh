#!/bin/bash
source "$(dirname "$0")/scripts/helper/ns_helper.sh"
source "$(dirname "$0")/scripts/helper/colors.sh"


# Function to get all secret names from environment variables in a pod
get_pod_secrets() {
  local pod_name="$1"
  local namespace_option=""
  namespace_option=$(get_namespace_option "$2")

  if [[ -z "$pod_name" ]]; then
    echo -e "${RED}Error: POD_NAME is required.${NC}"
    pod_secrets_help
    exit 1
  fi

  {
    kubectl get pod "$pod_name" $namespace_option -o json | \
    jq -r '.spec.containers[].env[]?.valueFrom.secretKeyRef.name' | \
    grep -v null | sort | uniq 
  } | column -t
}

pod_secrets_help() {
  echo -e "${GREEN}Usage: kubectl secops --pod-secrets <POD_NAME> [namespace | --all]"
  echo ""
  echo "Description:"
  echo "  List all unique secret names referenced in environment variables by containers in the specified pod."
  echo ""
  echo "Options:"
  echo "  <POD_NAME>         Specify the pod name to retrieve the secrets."
  echo "  [namespace]        Specify a namespace to filter the pods."
  echo ""
  echo "Examples:"
  echo "  kubectl secops --pod-secrets my-pod                     # Default, Lists secrets in 'my-pod' in the current namespace"
  echo "  kubectl secops --pod-secrets my-pod my-namespace        # Lists secrets in 'my-pod' in 'my-namespace'"
  echo -e "${NC}"
  exit 0
}

register_switch "--pod-secrets" "get_pod_secrets" "List all unique secret names used in environment variables" "pod_secrets_help"
