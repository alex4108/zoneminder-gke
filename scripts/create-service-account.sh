#!/usr/bin/env bash

# This assumes you've already authenticated with `gcloud init`

set -euo pipefail

export SERVICE_ACCOUNT_ID="zoneminder-$(date '+%s')"
export CREDENTIAL_FILE='gcloud.json'

gcloud iam service-accounts create "${SERVICE_ACCOUNT_ID}" \
    --description="CLI User for ZoneMinder on GKE Deployment" \
    --display-name="ZoneMinder-GKE-Deployer"

export IAM_ACCOUNT="${SERVICE_ACCOUNT_ID}@${TF_VAR_project_id}.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding ${TF_VAR_project_id} \
    --member="serviceAccount:${IAM_ACCOUNT}" \
    --role="roles/owner"

gcloud iam service-accounts keys create ${CREDENTIAL_FILE} \
    --iam-account=${IAM_ACCOUNT}

export TF_VAR_credential_file="${CREDENTIAL_FILE}"