#!/usr/bin/env bash

# This assumes you've already authenticated with `gcloud init`

set -euo pipefail

CREDENTIAL_FILE="terraform/gcloud.json"
SERVICE_ACCOUNT_ID=$(cat ${CREDENTIAL_FILE} | jq -r '.client_email')

gcloud iam service-accounts delete "${SERVICE_ACCOUNT_ID}"

rm -rf terraform/${CREDENTIAL_FILE}