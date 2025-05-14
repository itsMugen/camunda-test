#!/bin/bash

# WARNING: Do no need to edit this file

BOLD='\033[1m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

function yes_no() {
  PROMPT="$1"
  read -p "$1 (y/n) " RESP

  while [[ "$RESP" != "y" ]] && [[ "$RESP" != "n" ]]; do
    echo "Wrong input!"
    read -p "$1 (y/n)" RESP
  done

  echo "${RESP}"
}

function log_normal() {
  line="[$(date)] ${1}"
  echo -e "$line"
  if [[ -n "${CAMUNDA_CHALLENGE_LOG_FILE:-}" ]]; then
    echo "$line" >>"${CAMUNDA_CHALLENGE_LOG_FILE}"
  fi
}

function log_separator() {
  log_normal "--------------------------------------------------"
}

function log_test() {
  log_separator
  log_normal "${CYAN}[TEST]${NC} ${BOLD}${1}${NC}"
  log_separator
}

function log_info() {
  log_normal "${WHITE}[INFO]${NC} ${BOLD}${1}${NC}"
}

function log_error() {
  log_normal "${YELLOW}[ERROR]${NC} ${BOLD}${1}${NC}"
}

function log_warn() {
  log_normal "${YELLOW}[WARN]${NC} ${BOLD}${1}${NC}"
}

function log_pass() {
  log_normal "${GREEN}[PASS]${NC} ${BOLD}${1}${NC}"
}

function log_fail() {
  log_normal "${RED}[FAIL]${NC} ${BOLD}${1}${NC}"
}

function wait_for_app() {
  log_info "Waiting for the app to be ready"
  kubectl rollout status deployment/camunda-app --timeout=120s
  kubectl wait --for=condition=available --timeout=60s deployment/camunda-app
}

function wait_for_curl() {
  log_info "Waiting for the curl to be ready"
  kubectl rollout status deployment/curl --timeout=120s
  kubectl wait --for=condition=available --timeout=60s deployment/curl
}

function switch_k8s_context() {
  TARGET_CONTEXT="kind-$CLUSTER_NAME"
  CURRENT_CONTEXT=$(kubectl config current-context)

  if [[ "$TARGET_CONTEXT" != "$CURRENT_CONTEXT" ]]; then
    log_info "Switching to the context of the kind cluster ($TARGET_CONTEXT)"
    kubectl config use-context "$TARGET_CONTEXT"
  fi

  kubectl config set-context --current --namespace=default
}

function restart_rollout() {
  kubectl rollout restart "deployment/${1}" || log_warn "Could not restart rollout of deployment/${1}"
}

function apply_manifests() {
  SCRIPT=$(realpath "${0}")
  SCRIPTPATH=$(dirname "${SCRIPT}")
  RESOURCES_DIR="${SCRIPTPATH}/../k8s-resources"
  log_info "${2}"
  kubectl apply -f "${RESOURCES_DIR}/${1}"
  sleep 2
}

