#!/usr/bin/env bash

# This assumes you've already authenticated with `gcloud init`

set -euo pipefail

gcloud iam service-accounts delete "${SERVICE_ACCOUNT_ID}"

rm -rf terraform/${CREDENTIAL_FILE}