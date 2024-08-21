#!/bin/bash
source "$(dirname "$0")/scripts/helper/common.sh"
source "$(dirname "$0")/scripts/helper/colors.sh"

# Function to decode and display the content of secrets
decode_secret() {
  local secrets=()
  local decode_all=false

  while [[ $# -gt 0 ]]; do
    case $1 in
      --all)
        decode_all=true
        shift
        ;;
      *)
        secrets+=("$1")
        shift
        ;;
    esac
  done

  if [[ "$decode_all" == true ]]; then
    echo -e "${GREEN}Decoding all secrets in the current namespace...${NC}"
    kubectl get secrets -o name | sed 's/^secret\///' | while read -r secret; do
      echo -e "${YELLOW}$secret${NC}"
      kubectl get secret "$secret" -o go-template='{{range $k,$v := .data}}{{$k}}{{": "}}{{$v | base64decode}}{{"\n\n"}}{{end}}'
      echo ""
    done
  else
    if [[ ${#secrets[@]} -eq 0 ]]; then
      echo -e "${RED}Error: At least one secret name must be provided if --all is not specified.${NC}"
      dec_sect_help
      exit 1
    fi

    for secret_name in "${secrets[@]}"; do
      echo -e "${YELLOW}$secret_name${NC}"
      kubectl get secret "$secret_name" -o go-template='{{range $k,$v := .data}}{{$k}}{{": "}}{{$v | base64decode}}{{"\n\n"}}{{end}}'
      echo ""
    done
  fi
}

dec_sect_help() {
  echo -e "${GREEN}Usage: kubectl secops --dec-sect [--all | <secretname> [<secretname> ...]]"
  echo ""
  echo "Description:"
  echo "  Decodes and displays the contents of the specified Kubernetes secrets or all secrets in the current namespace."
  echo ""
  echo "Options:"
  echo "  --all              Decode and display all secrets in the current namespace."
  echo "  <secretname>       One or more secret names to decode and display."
  echo ""
  echo "Examples:"
  echo "  kubectl secops --dec-sect my-secret           # Decodes and displays 'my-secret'"
  echo "  kubectl secops --dec-sect secret1 secret2     # Decodes and displays 'secret1' and 'secret2'"
  echo "  kubectl secops --dec-sect --all               # Decodes and displays all secrets in the current namespace"
  echo -e "${NC}"
  exit 0
}

register_switch "--dec-sect" "decode_secret" "Decode and display Kubernetes secrets" "dec_sect_help"
