#!/bin/bash
source "$(dirname "$0")/scripts/helper/ns_helper.sh"
source "$(dirname "$0")/scripts/helper/common.sh"
source "$(dirname "$0")/scripts/helper/colors.sh"


# Function to get all images name and tag
get_image_version() {
  local namespace_option=""
  namespace_option=$(get_namespace_option "$1")
  
  {
    echo -e "NAMESPACE\tPOD\tIMAGE"
    kubectl get pods $namespace_option -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\t"}{range .spec.containers[*]}{.image}{"\n"}{end}{end}'
  } | column -t
}

image_version_help() {
  echo -e "${GREEN}Usage: kubectl secops --image-version [namespace | --all]"
  echo ""
  echo "Description:"
  echo "  List all images (name and tag) used by containers in the specified namespace or across all namespaces."
  echo ""
  echo "Options:"
  echo "  [namespace]        Specify a namespace to filter the pods."
  echo "  --all              List images across all namespaces."
  echo ""
  echo "Examples:"
  echo "  kubectl secops --image-version                    # Default, Lists images in the current namespace"
  echo "  kubectl secops --image-version my-namespace       # Lists images in 'my-namespace'"
  echo "  kubectl secops --image-version --all              # Lists images across all namespaces"
  echo -e "${NC}"
  exit 0
}

register_switch "--image-version" "get_image_version" "List all images name and tag" "image_version_help"
