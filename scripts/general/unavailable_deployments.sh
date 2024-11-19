#!/bin/bash
source "$(dirname "$0")/scripts/helper/load_helpers.sh"

# Function to get deployments with unavailable replicas
get_unavail_deploy() {
  local namespace_option=""
  namespace_option=$(get_namespace_option "$1")

  {
    echo -e "NAMESPACE\tNAME\tAGE\tREADY"
    kubectl get deployments $namespace_option -o json | jq -r '
      .items[] | 
      select(.status.unavailableReplicas > 0) | 
      .metadata.namespace + "\t" + 
      .metadata.name + "\t" + 
      (.metadata.creationTimestamp | fromdate | strftime("%Y-%m-%d-%H:%M:%S")) + "\t" + 
      (if .status.readyReplicas == null then "0" else (.status.readyReplicas | tostring) end) + "/" + 
      (.status.replicas | tostring)
    '
  } | column -t
}

unavail_deploy_help() {
  echo -e "${GREEN}Usage: kubectl secops --unavail-deploy [namespace | --all]"
  echo ""
  echo "Description:"
  echo "  List all deployments with unavailable replicas in the specified namespace or across all namespaces."
  echo ""
  echo "Options:"
  echo "  [namespace]        Specify a namespace to filter the deployments."
  echo "  --all              List deployments across all namespaces."
  echo ""
  echo "Examples:"
  echo "  kubectl secops --unavail-deploy                    # Default, lists deployments with unavailable replicas in the current namespace"
  echo "  kubectl secops --unavail-deploy my-namespace       # Lists deployments with unavailable replicas in 'my-namespace'"
  echo "  kubectl secops --unavail-deploy --all              # Lists deployments with unavailable replicas across all namespaces"
  echo -e "${NC}"
  exit 0
}

register_switch "--unavail-deploy" "get_unavail_deploy" "List deployments with unavailable replicas" "unavail_deploy_help"
