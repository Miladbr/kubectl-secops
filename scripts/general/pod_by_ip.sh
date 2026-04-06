#!/bin/bash
source "$(dirname "$0")/scripts/helper/colors.sh"

list_pod_by_ip() {
  local ip="$1"

  if [ -z "$ip" ]; then
    echo -e "${RED}Error: pod IP is required.${NC}"
    echo "Usage: kubectl secops --pod-by-ip <pod-ip>"
    exit 1
  fi

  local rows
  rows=$(kubectl get pods -A -o json | jq -r --arg ip "$ip" \
    '.items[] | select(.status.podIP == $ip) | "\(.metadata.namespace)\t\(.metadata.name)\t\(.spec.nodeName // "-")"')
  if [ -n "$rows" ]; then
    echo -e "NAMESPACE\tPOD\tNODE\n$rows" | column -t
  fi
}

pod_by_ip_help() {
  echo -e "${GREEN}Usage: kubectl secops --pod-by-ip <pod-ip>"
  echo ""
  echo "Description:"
  echo "  Find pod by cluster Pod IP, prints NAMESPACE, POD, and NODE."
  echo ""
  echo "Examples:"
  echo "  kubectl secops --pod-by-ip 10.0.2.3"
  echo -e "${NC}"
  exit 0
}

register_switch "--pod-by-ip" "list_pod_by_ip" "Find pod by Pod IP" "pod_by_ip_help"
