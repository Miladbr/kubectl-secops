#!/bin/bash
source "$(dirname "$0")/scripts/helper/load_helpers.sh"

# Function to perform a curl request to the Kubernetes API using a service account
# Source: https://gist.github.com/stewartshea/07ad335637e5f71c5fdf37d88c0ae92d
test_service_account() {
  local namespace="${1:-$(kubectl config view --minify --output 'jsonpath={..namespace}')}"
  local serviceaccount="${2:-default}"
  local apiserver="https://kubernetes.default.svc/apis/authentication.k8s.io/v1/selfsubjectrulesreview"
  local resource=""
  
  if [ -z "$namespace" ]; then
    namespace="default"
  fi

  echo "Using namespace: $namespace"
  echo "Using service account: $serviceaccount"

  kubectl run curl-pod --image=curlimages/curl:latest --restart=Never --overrides="{ \"spec\": { \"serviceAccountName\": \"$serviceaccount\" } }" -n "$namespace" --command -- sleep infinity

  echo "Waiting for the curl-pod to be running..."
  kubectl wait --for=condition=Ready pod/curl-pod --timeout=20s -n "$namespace"

  TOKEN=$(kubectl exec curl-pod -n "$namespace" -- cat /var/run/secrets/kubernetes.io/serviceaccount/token)

  echo "Performing a curl request to the Kubernetes API..."
  kubectl exec curl-pod -n "$namespace" -- curl -s -k -H "Authorization: Bearer $TOKEN" "$apiserver$resource"

  echo "Cleaning up..."
  kubectl delete pod curl-pod -n "$namespace"
  echo "Done"
}

test_service_account_help() {
  echo -e "${GREEN}Usage: kubectl secops --test-sa <namespace> <service_account>"
  echo ""
  echo "Description:"
  echo "  Run a curl command to access the Kubernetes API using a specified service account and namespace."
  echo ""
  echo "Options:"
  echo "  <namespace>        Specify a namespace to run the curl pod. Uses the current namespace if not specified."
  echo "  <service_account>  Specify a service account to use. Defaults to 'default' if not specified."
  echo ""
  echo "Examples:"
  echo "  kubectl secops --test-sa my-namespace my-service-account  # Use my-namespace and my-service-account"
  echo "  kubectl secops --test-sa my-namespace                     # Use my-namespace and default service account"
  echo -e "  kubectl secops --test-sa                                  # Use current namespace and default service account${NC}"
  exit 0
}

register_switch "--test-sa" "test_service_account" "Perform a curl request to the Kubernetes API using a service account" "test_service_account_help"
