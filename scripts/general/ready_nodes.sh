#!/bin/bash
source "$(dirname "$0")/scripts/helper/common.sh"
source "$(dirname "$0")/scripts/helper/colors.sh"

# Function to list nodes that are in the Ready state
list_ready_nodes() {
  kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}' | \
  awk '$2=="True" {print $1}'
}

ready_nodes_help() {
  echo -e "${GREEN}Usage: kubectl secops --rd-nodes"
  echo ""
  echo "Description:"
  echo "  List all nodes that are currently in the Ready state."
  echo ""
  echo "Examples:"
  echo "  kubectl secops --rd-nodes                    # Lists all nodes in the Ready state"
  echo -e "${NC}"
  exit 0
}

register_switch "--rd-nodes" "list_ready_nodes" "List all nodes in the Ready state" "ready_nodes_help"
