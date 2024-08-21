#!/bin/bash

source "$(dirname "$0")/scripts/helper/colors.sh"

# Function to retrieve and display the internal IP addresses of nodes
get_nodes_internal_ips() {
    kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}' | tr ' ' '\n'
}

nodes_ip_help() {
    echo -e "${GREEN}Usage: kubectl secops --node-ip"
    echo ""
    echo "Description:"
    echo "  Retrieve and display the internal IP addresses of all nodes in the cluster."
    echo ""
    echo "Examples:"
    echo "  kubectl secops --node-ip   # Displays the internal IPs of all nodes"
    echo -e "${NC}"
    exit 0
}

register_switch "--nodes-ip" "get_nodes_internal_ips" "Retrieve and display the internal IP addresses of nodes" "nodes_ip_help"
