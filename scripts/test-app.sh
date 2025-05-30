#!/bin/bash

# WARNING: Do not edit this file

SCRIPT=$(realpath $0)
SCRIPTPATH=$(dirname "$SCRIPT")

. "${SCRIPTPATH}/../settings.sh"
. "${SCRIPTPATH}/_library.sh"

set -eu

test_metric_value_for_image_above() {
    # this helper traverses through the output of the exporter and checks if a metric with specific labels is
    # above a minimal value submitted

    resp="${1}"
    metric="${2}"
    label1="${3}"
    label2="${4}"
    min_value="${5}"

    log_test "Checking the pull count for the image ${label1}, ${label2} is above ${min_value}"

    # regex matcher to grab the metric value
    regex="${metric}\{.*(${label2},.*${label1}|${label1},.*${label2}).*\}\s*(.+)"
    found_match="false"
    found_value=""

    # iterate over the response line by line
    while read line; do
        [[ "$line" =~ $regex ]] || true  # used to populate BASH_REMATCH variable, direct check result is uninteresting
        set +u
        if [[ ! -z "${BASH_REMATCH[1]}" ]]; then
          # regex match found
          found_match="true"
          found_value=$(echo "${BASH_REMATCH[2]}" | sed "s/[,.]/$(locale decimal_point)/g" | POSIXLY_CORRECT=true awk '{printf("%d\n", $1)}')  # convert from the scientific notation
        fi
        set -u
    done <<< "$resp"

    if [[ -z $found_value  ]]; then
        log_fail "Did not find a metric ${metric} value with labels ${label1}, ${label2}"
    elif [[ $found_value -lt $min_value ]]; then
        log_fail "Metric ${metric} with labels ${label1}, ${label2} is ${found_value} which is below ${min_value}"
    else
        log_pass "Metric ${metric} with labels ${label1}, ${label2} is ${found_value} which is above ${min_value}"
    fi
}


APP_PORT="2113"
URL=""
RESPONSE=""

setup_kubernetes_mode() {
    switch_k8s_context
    log_test "Querying the API response from the exporter in k8s"
    URL="http://camunda-app:${APP_PORT}/metrics/"
    RESPONSE="$(kubectl exec deployment/curl -- curl -sf $URL)"
    EXIT_CODE=$?
    [ "${EXIT_CODE}" == "0" ] && log_pass "Successfully fetched the response from the app" || log_fail "Failed to fetch the API response from the app"
}

setup_local_mode() {
    log_test "Querying the API response from the non-dockerized exporter"
    URL="http://localhost:${APP_PORT}/metrics/"
    RESPONSE="$(curl -sf $URL)"
    EXIT_CODE=$?
    [ "${EXIT_CODE}" == "0" ] && log_pass "Successfully fetched the response from the app" || log_fail "Failed to fetch the API response from the app"
}

sleep 5  # waiting for the app to get ready (e.g. fetch first data for metrics)

if [[ "${1}" == "in-k8s" ]]; then
    setup_kubernetes_mode
else
    setup_local_mode
fi

log_info "Here's the response from the exporter app:"
echo "$RESPONSE"

log_test "Checking the response has the helper string for the docker_image_pulls metric type"
set +e
IS_METRIC_TYPE_PRESENT="$(echo "$RESPONSE" | grep 'TYPE docker_image_pulls gauge')"
EXIT_CODE=$?
set -e
[ "${EXIT_CODE}" == "0" ] && \
    log_pass "The response has the metric type gauge for docker_image_pulls metric" \
    || log_fail "The response does not have the metric type gauge for docker_image_pulls metric"

test_metric_value_for_image_above "$RESPONSE" docker_image_pulls organization=\"camunda\" image=\"camunda-bpm-platform\" 50000000

test_metric_value_for_image_above "$RESPONSE" docker_image_pulls organization=\"camunda\" image=\"zeebe\" 5000000

log_separator
