#!/bin/bash
source "$(dirname "$0")/scripts/helper/colors.sh"


display_usage() {
  local DESCRIPTION="A Kubernetes security and operations utility tool."
  echo -e "${GREEN}SecOps: ${DESCRIPTION}"
  echo ""
  echo -e "Usage: kubectl secops [command]"
  echo ""
  echo "Available Commands:"
  for i in "${!SWITCH_NAMES[@]}"; do
    printf "  %-15s %s\n" "${SWITCH_NAMES[$i]}" "${SWITCH_DESCRIPTIONS[$i]}"
  done
  echo -e "${NC}"
  exit 0
}
