#!/bin/bash
source "$(dirname "$0")/scripts/helper/load_helpers.sh"

# Function to list pods with restartCount greater than a specified value in a column-based view
list_pods_with_restarts() {
    local namespace_option=""
    local count=0
    local min_restarts=1

    while [[ $# -gt 0 ]]; do
        case $1 in
            -c)
                count="$2"
                shift 2
                ;;
            -n)
                min_restarts="$2"
                shift 2
                ;;
            --all)
                namespace_option="--all-namespaces"
                shift
                ;;
            *)
                namespace_option=$(get_namespace_option "$1")
                shift
                ;;
        esac
    done

    {
        echo -e "NAMESPACE\tPOD\tCOUNT"
        kubectl get pods $namespace_option -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\t"}{.status.containerStatuses[0].restartCount}{"\n"}{end}' | \
        awk -v min_restarts="$min_restarts" '$3 > min_restarts' | \
        sort -k3,3nr | \
        {
            if [[ "$count" -gt 0 ]]; then
                head -n "$count"
            else
                cat
            fi
        }
    } | column -t -s $'\t'
}

ptoprst_help() {
  echo -e "${GREEN}Usage: kubectl secops --ptoprst [namespace | --all] [-c <count>] [-n <min_restarts>]"
  echo ""
  echo "Description:"
  echo "  List all pods sorted by restart count and optionally describe those with more than a specified restart count."
  echo ""
  echo "Options:"
  echo "  [namespace]        Specify a namespace to filter the pods."
  echo "  --all              List pods across all namespaces."
  echo "  -c <count>         Limit the output to the top <count> pods by restart count."
  echo "  -n <min_restarts>  Minimum restart count to include a pod in the list (default is 1)."
  echo ""
  echo "Examples:"
  echo "  kubectl secops --ptoprst                    # Default, Lists pods with restarts > 1 in the current namespace"
  echo "  kubectl secops --ptoprst my-namespace       # Lists pods with restarts > 1 in 'my-namespace'"
  echo "  kubectl secops --ptoprst --all -c 10        # Lists top 10 pods with restarts > 1 across all namespaces"
  echo "  kubectl secops --ptoprst --all -c 5         # Lists top 5 pods with restarts > 1 across all namespaces"
  echo "  kubectl secops --ptoprst --all -n 3         # Lists pods with restarts > 3 across all namespaces"
  echo -e "${NC}"
  exit 0
}

register_switch "--ptoprst" "list_pods_with_restarts" "List pods with more than a specified restart count" "ptoprst_help"
