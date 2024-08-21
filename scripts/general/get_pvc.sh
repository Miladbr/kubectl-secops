#!/bin/bash
source "$(dirname "$0")/scripts/helper/common.sh"
source "$(dirname "$0")/scripts/helper/ns_helper.sh"
source "$(dirname "$0")/scripts/helper/colors.sh"

# Function to convert sizes to bytes for comparison
convert_to_bytes() {
  local size=$1
  local number=$(echo $size | grep -o -E '[0-9]+')
  local unit=$(echo $size | grep -o -E '[a-zA-Z]+')

  case $unit in
    m|M|mib|MIB|mb|MB)
      echo $(($number * 1024 * 1024))
      ;;
    g|G|gib|GIB|gb|GB)
      echo $(($number * 1024 * 1024 * 1024))
      ;;
    t|T|tib|TIB|tb|TB)
      echo $(($number * 1024 * 1024 * 1024 * 1024))
      ;;
    *)
      echo $number
      ;;
  esac
}

# Function to get and display PVCs with detailed and aligned output, optionally filtering by size
get_pvc_details() {
  local namespace_option=""
  local size_threshold_bytes=0

  if [[ "$1" == "--all" ]]; then
    namespace_option="--all-namespaces"
    shift
  elif [[ "$1" != "" && ! "$1" =~ ^[0-9]+[mMgGtT][iI]*$ ]]; then
    namespace_option=$(get_namespace_option "$1")
    shift
  else
    namespace_option=$(get_namespace_option "")
  fi

  if [[ -n "$1" ]]; then
    size_threshold_bytes=$(convert_to_bytes "$1")
  fi

  {
    echo -e "NAMESPACE\tNAME\tCLASS\tSIZE\tSTATUS\tVOLUME"
    kubectl get pvc $namespace_option -o=jsonpath="{range .items[*]}{.metadata.namespace}{'\t'}{.metadata.name}{'\t'}{.spec.storageClassName}{'\t'}{.status.capacity.storage}{'\t'}{.status.phase}{'\t'}{.spec.volumeName}{'\n'}{end}" | \
    awk -v threshold=$size_threshold_bytes '
    function convert_size_to_bytes(size) {
      if (size ~ /Gi/) {
        return substr(size, 1, length(size)-2) * 1024 * 1024 * 1024
      } else if (size ~ /Mi/) {
        return substr(size, 1, length(size)-2) * 1024 * 1024
      } else if (size ~ /Ti/) {
        return substr(size, 1, length(size)-2) * 1024 * 1024 * 1024 * 1024
      } else {
        return size
      }
    }
    {
      capacity_in_bytes = convert_size_to_bytes($4)
      if (capacity_in_bytes > threshold) print $0
    }'
  } | column -t
}

pvc_help() {
  echo -e "${GREEN}Usage: kubectl secops --get-pvc [--all | <namespace>] [size-threshold]"
  echo ""
  echo "Description:"
  echo "  Retrieves and displays detailed information about Persistent Volume Claims (PVCs) across all namespaces or within a specific namespace."
  echo "  If no arguments are provided, the command runs in the current namespace."
  echo "  Optionally filters PVCs to show only those with a size greater than the specified threshold."
  echo ""
  echo "Options:"
  echo "  --all              List PVCs across all namespaces."
  echo "  <namespace>        Specify a namespace to filter the PVCs."
  echo "  <size-threshold>   (Optional) Specify a size threshold (e.g., 500Mi, 5Gi). Only PVCs larger than this size will be displayed."
  echo ""
  echo "Examples:"
  echo "  kubectl secops --get-pvc                # Get PVCs in the current namespace"
  echo "  kubectl secops --get-pvc --all          # Get PVCs across all namespaces"
  echo "  kubectl secops --get-pvc my-namespace   # Get PVCs in 'my-namespace'"
  echo "  kubectl secops --get-pvc --all 1Gi      # Get PVCs across all namespaces larger than 1Gi"
  echo "  kubectl secops --get-pvc 20Gi           # Get PVCs in the current namespace larger than 20Gi"
  echo -e "${NC}"
  exit 0
}

register_switch "--get-pvc" "get_pvc_details" "Retrieve and display detailed information about PVCs with optional size filtering" "pvc_help"
