#!/bin/bash

source "$(dirname "$0")/scripts/helper/load_helpers.sh"

# Function to find RoleBindings and ClusterRoleBindings referencing a user or group
find_access() {
  local identifier=""
  local namespace_option=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --all)
        namespace_option=$(get_namespace_option "--all")
        shift
        ;;
      -*)
        echo -e "${RED}Error: Unknown option '$1'.${NC}"
        find_access_help
        exit 1
        ;;
      *)
        if [ -z "$identifier" ]; then
          identifier="$1"
        else
          namespace_option=$(get_namespace_option "$1")
        fi
        shift
        ;;
    esac
  done

  if [ -z "$identifier" ]; then
    echo -e "${RED}Error: No identifier provided.${NC}"
    find_access_help
    exit 1
  fi

  local bindings_json
  bindings_json=$(kubectl get rolebindings,clusterrolebindings $namespace_option -o json 2>/dev/null)

  if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to retrieve RoleBindings or ClusterRoleBindings. Please ensure you are connected to a Kubernetes cluster and have the necessary permissions.${NC}"
    exit 1
  fi

  local escaped_identifier
  escaped_identifier=$(printf '%s' "$identifier" | sed 's/\\/\\\\/g; s/"/\\"/g')

  if ! echo "" | jq --arg regex "$escaped_identifier" 'test($regex)' > /dev/null 2>&1; then
    echo -e "${RED}Error: Invalid regex pattern '${identifier}'.${NC}"
    exit 1
  fi

  local matching_bindings
  matching_bindings=$(echo "$bindings_json" | jq -r --arg IDENTIFIER "$escaped_identifier" '
    .items[] |
    select(
      [.subjects[]? | select((.kind == "User" or .kind == "Group") and (.name | test($IDENTIFIER)))] | length > 0
    ) |
    {
      name: .metadata.name,
      role: .roleRef.name,
      namespace_display: (if .kind == "ClusterRoleBinding" then "cluster-wide" else (.metadata.namespace // "default") end),
      targets: [.subjects[]? | select((.kind == "User" or .kind == "Group") and (.name | test($IDENTIFIER))) | .name] | join(", ")
    } |
    "\(.name)\t\(.role)\t\(.namespace_display)\t\(.targets)"
  ')

  if [ -z "$matching_bindings" ]; then
    echo -e "${YELLOW}No RoleBindings or ClusterRoleBindings found referencing user or group matching regex '${identifier}' in the specified namespace(s).${NC}"
    exit 0
  fi

  {
    echo -e "BINDING\tREFRENCE\tNAMESPACE\tTARGET"
    echo "$matching_bindings"
  } | column -t

  exit 0
}

find_access_help() {
  echo -e "${GREEN}Usage: kubectl secops --find-access <identifier> [--all | <namespace>]"
  echo ""
  echo "Description:"
  echo "  Searches for both RoleBindings and ClusterRoleBindings that reference a specified user or group in the current or specified namespace."
  echo "  Uses regex-based matching by default."
  echo ""
  echo "Options:"
  echo "  --all              Search across all namespaces."
  echo "  [namespace]        Specify a namespace to filter the RoleBindings."
  echo "  [identifier]      The regex pattern to search for in user or group names within RoleBindings and ClusterRoleBindings."
  echo ""
  echo "Examples:"
  echo "  kubectl secops --find-access miladbr                     # Find RoleBindings or ClusterRoleBindings referencing user or group matching regex 'miladbr' in the current namespace"
  echo "  kubectl secops --find-access '^dev-.*' --all          # Find RoleBindings or ClusterRoleBindings referencing users or groups matching regex '^dev-.*' across all namespaces"
  echo "  kubectl secops --find-access miladbr kube-system       # Find RoleBindings or ClusterRoleBindings referencing user or group matching regex 'miladbr' in 'kube-system'"
  echo "  kubectl secops --find-access '.*admin' security-system    # Find RoleBindings or ClusterRoleBindings referencing users or groups matching regex '.*admin' in 'security-system'"
  echo -e "${NC}"
  exit 0
}

# Register the new switch
register_switch "--find-access" "find_access" "Find RoleBindings and ClusterRoleBindings referencing a user or group using regex matching" "find_access_help"
