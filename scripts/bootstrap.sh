#!/usr/bin/env bash

# https://cloud.google.com/sdk/docs/install#deb

fail() { 
    exit 1
}

KUBE_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
HELM_FILE="helm-v3.6.0-linux-amd64.tar.gz"
HELM_SHA256="0a9c80b0f211791d6a9d36022abd0d6fd125139abe6d1dcf4c5bf3bc9dcec9c8  ${HELM_FILE}"

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get install -y apt-transport-https ca-certificates gnupg
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update -y && sudo apt-get install google-cloud-sdk -y
gcloud init

curl -LO "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/${KUBE_VERSION}/bin/linux/amd64/kubectl.sha256"
echo "$(<kubectl.sha256) kubectl" | sha256sum --check || fail
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt install terraform -y

curl -o ${HELM_FILE} https://get.helm.sh/${HELM_FILE}
echo "${HELM_SHA256}" | sha256sum --check || fail
tar xvfz ${HELM_FILE}
sudo cp ./linux-amd64/helm /usr/bin/

sudo apt-get -y install jq yq