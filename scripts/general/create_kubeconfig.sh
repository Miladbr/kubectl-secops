#!/bin/bash
source "$(dirname "$0")/scripts/helper/common.sh"
source "$(dirname "$0")/scripts/helper/colors.sh"

# Function to create a kubeconfig file for a given service account
create_kubeconfig() {
  local clusterName=""
  local server=""
  local namespace=""
  local serviceAccount=""

  if [[ $# -eq 2 ]]; then
    namespace=$1
    serviceAccount=$2
  elif [[ $# -eq 4 ]]; then
    clusterName=$1
    server=$2
    namespace=$3
    serviceAccount=$4
  else
    echo -e "${RED}Error: Invalid number of arguments.${NC}"
    create_config_help
    exit 1
  fi

  if [[ -z "$clusterName" ]]; then
    clusterName=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
    echo -e "${YELLOW}Cluster name not provided, using current cluster: ${clusterName}${NC}"
  fi

  if [[ -z "$server" ]]; then
    server=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
    echo -e "${YELLOW}Server not provided, using current server: ${server}${NC}"
  fi

  if [[ -z "$namespace" || -z "$serviceAccount" ]]; then
    echo -e "${RED}Error: Namespace and ServiceAccount must be provided.${NC}"
    create_config_help
    exit 1
  fi

  set -o errexit

  secretName=$(kubectl --namespace "$namespace" get serviceaccount "$serviceAccount" -o jsonpath='{.secrets[0].name}')
  token=$(kubectl --namespace "$namespace" get secret/"$secretName" -o jsonpath='{.data.token}' | base64 --decode)

  echo -e "${GREEN}Creating kubeconfig for service account: $serviceAccount${NC}"

  echo "
---
apiVersion: v1
kind: Config
clusters:
  - name: ${clusterName}
    cluster:
      insecure-skip-tls-verify: true
      server: ${server}
contexts:
  - name: ${serviceAccount}@${clusterName}
    context:
      cluster: ${clusterName}
      namespace: ${namespace}
      user: ${serviceAccount}
users:
  - name: ${serviceAccount}
    user:
      token: ${token}
current-context: ${serviceAccount}@${clusterName}
" > "${clusterName}.yaml"

  echo -e "${GREEN}Kubeconfig created: ${clusterName}.yaml${NC}"
}

create_config_help() {
  echo -e "${GREEN}Usage: kubectl secops --create-config [clusterName] [server] <namespace> <serviceAccount>"
  echo ""
  echo "Description:"
  echo "  Creates a kubeconfig file for a specified service account in a given namespace."
  echo ""
  echo "Options:"
  echo "  clusterName       (Optional) The name of the cluster. If not provided, the current cluster will be used."
  echo "  server            (Optional) The server URL. If not provided, the current server URL will be used."
  echo "  <namespace>       The namespace where the service account is located."
  echo "  <serviceAccount>  The name of the service account."
  echo ""
  echo "Examples:"
  echo "  kubectl secops --create-config my-cluster https://my-server.com my-namespace my-service-account  # Creates kubeconfig with provided clusterName and server"
  echo "  kubectl secops --create-config my-namespace my-service-account                                    # Creates kubeconfig using current cluster and server"
  echo -e "${NC}"
  exit 0
}

register_switch "--create-config" "create_kubeconfig" "Create a kubeconfig file for a service account" "create_config_help"
