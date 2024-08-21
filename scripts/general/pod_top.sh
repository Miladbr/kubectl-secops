#!/bin/bash
source "$(dirname "$0")/scripts/helper/ns_helper.sh"
source "$(dirname "$0")/scripts/helper/common.sh"
source "$(dirname "$0")/scripts/helper/colors.sh"

# Function to get top resource-consuming pods on a specific node
get_top_pods() {
  local node_name=""
  local sort_by="memory"
  local top_n=10
  local sort_row=5

  if [[ $# -ge 1 ]]; then
    node_name="$1"
  else
    echo -e "${RED}Error: Node name argument is required.${NC}"
    top_pods_help
  fi

  if [[ $# -ge 2 ]]; then
    sort_by="$2"
  fi

  if [[ $# -ge 3 ]]; then
    top_n="$3"
  fi

  if [[ "$sort_by" != "memory" && "$sort_by" != "cpu" ]]; then
    echo -e "${RED}Error: Sorting argument must be either 'memory' or 'cpu'.${NC}"
    top_pods_help
  fi

  local sort_option="--sort-by=memory"
  if [[ "$sort_by" == "cpu" ]]; then
    sort_option="--sort-by=cpu"
    sort_row=4
  fi

  {
    echo -e "NAMESPACE\tPOD\tCONTAINER\tCPU\tMEMORY"
    kubectl get pods --all-namespaces --field-selector spec.nodeName="$node_name" -o custom-columns="NAMESPACE:.metadata.namespace,POD:.metadata.name" --no-headers | \
    while read -r NAMESPACE POD; do 
      kubectl top pod "$POD" --containers $sort_option -n "$NAMESPACE" --no-headers 2>/dev/null | \
      awk -v namespace="$NAMESPACE" '{print namespace "\t" $1 "\t" $2 "\t" $3 "\t" $4}'
    done | sort -k $sort_row -rh | head -n "$top_n"
  } | column -t
}

top_pods_help() {
  echo -e "${GREEN}Usage: kubectl secops --top-pods <node-name> [<memory|cpu>] [<number-of-pods>]"
  echo ""
  echo "Description:"
  echo "  Displays the top resource-consuming pods on a specified node, sorted by memory or CPU usage."
  echo ""
  echo "Options:"
  echo "  <node-name>               Specify the node to filter the pods."
  echo "  <memory|cpu>              (Optional) Sort by memory or CPU usage (default is memory)."
  echo "  <number-of-pods>          (Optional) Number of top pods to display (default is 10)."
  echo ""
  echo "Examples:"
  echo "  kubectl secops --top-pods c18-n2                  # Displays top 10 memory-consuming pods on 'c18-n2'."
  echo "  kubectl secops --top-pods c18-n2 cpu              # Displays top 10 CPU-consuming pods on 'c18-n2'."
  echo "  kubectl secops --top-pods c18-n2 memory 5         # Displays top 5 memory-consuming pods on 'c18-n2'."
  echo "  kubectl secops --top-pods c18-n2 cpu 10           # Displays top 10 CPU-consuming pods on 'c18-n2'."
  echo -e "${NC}"
  exit 0
}

register_switch "--top-pods" "get_top_pods" "Displays the top resource-consuming pods on a specified node." "top_pods_help"
