#!/bin/bash

get_namespace_option() {
  local namespace_option=""
  
  if [ -z "$1" ]; then
    current_namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}')
    if [ -z "$current_namespace" ]; then
      namespace_option="-n default"
    else
      namespace_option="-n $current_namespace"
    fi
  elif [ "$1" == "--all" ]; then
    namespace_option="--all-namespaces"
  else
    namespace_option="-n $1"
  fi

  echo "$namespace_option"
}
