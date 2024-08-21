#!/bin/bash

source "$(dirname "$0")/scripts/helper/colors.sh"

# Function to create ServiceAccount and Secret
create_sa() {
  local namespace="$1"
  local service_account_name="$2"

  if [[ -z "$namespace" || -z "$service_account_name" ]]; then
    echo -e "${RED}Error: Namespace and ServiceAccount name are required.${NC}"
    create_sa_help
    exit 1
  fi

  local secret_name="${service_account_name}-token"

  kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${service_account_name}
  namespace: ${namespace}
secrets:
  - name: ${secret_name}
EOF

  kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${secret_name}
  namespace: ${namespace}
  annotations:
    kubernetes.io/service-account.name: ${service_account_name}
type: kubernetes.io/service-account-token
EOF

}

create_sa_help() {
  echo -e "${GREEN}Usage: kubectl secops --create-sa <namespace> <service-account-name>"
  echo ""
  echo "Description:"
  echo "  Create a ServiceAccount and a corresponding Secret in the specified namespace."
  echo ""
  echo "Options:"
  echo "  <namespace>              The namespace where the ServiceAccount and Secret will be created."
  echo "  <service-account-name>   The name of the ServiceAccount. The Secret name will be derived from this."
  echo ""
  echo "Examples:"
  echo "  kubectl secops --create-sa my-namespace devops-sa"
  echo -e "${NC}"
  exit 0
}

register_switch "--create-sa" "create_sa" "Create a ServiceAccount and Secret" "create_sa_help"
