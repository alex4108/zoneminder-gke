# ZoneMinder on GKE

This will be a POC for GKE.

Deploys [ZoneMinder](https://zoneminder.com/), a software-based network video recorder for live streams, using [dlandon/zoneminder](https://hub.docker.com/r/dlandon/zoneminder) from DockerHub.

Uses [Terraform](https://www.terraform.io/) to deploy a [GKE Autopilot](https://cloud.google.com/blog/products/containers-kubernetes/introducing-gke-autopilot) cluster.

Uses [helm](https://helm.sh/) to deploy the ZoneMinder pod.

Developed on Ubuntu 18.04.

# Getting Started

## Bootstrap

First run `bash scripts/bootstrap.sh` to install the needed tools

* gcloud (latest)
* helm (3.6.0)
* kubectl (latest)
* terraform (latest)

## Create a GCP project

Now run `gcloud init` to authenticate & create a project.  Copy down the project ID you're deploying to.

_If you're using the GKE Free Tier, use the Project ID found in the console for the project that has the free tier credits_

## Set Environment Variables

Set the parameters on your environment

`TF_VAR_project_id` is the GCP Project ID

`TF_VAR_region` is the region you're deploying to

`ENV_NAME` is the environment name for this deployment.

```
export TF_VAR_project_id=xyz-abc-12345678
export TF_VAR_region="us-central1"
export TF_VAR_env_name="zoneminder"
```

Create a service account to deploy the template: `bash scripts/create-service-account.sh && mv gcloud.json terraform/`

## Deploy Terraform Template

The GKE Cluster should be available after about 5 minutes.

`cd terraform`

Check that the template will deploy:
```
terraform init
terraform plan
```

Deploy when ready:
```
bash deploy.sh
```

`cd ../`

## Deploy ZoneMinder app

This should take about 6 minutes.

### Deploy helm chart

You may need to increase the limits in `values.yaml` as needed.

Make sure the environment variables you exported earlier are still available.

```
export init_delay_seconds=$(yq -r '.initialDelaySeconds' zoneminder/values.yaml)
helm install ${TF_VAR_env_name} zoneminder/ --values zoneminder/values.yaml --wait --timeout ${init_delay_seconds}s
external_ip=$(kubectl --namespace default get svc ${TF_VAR_env_name} -o json | jq -r '.status.loadBalancer.ingress[].ip')
echo "ZoneMinder should now be available at https://${external_ip}:8443/zm/"
```

At this point, ZoneMinder should be available & ready to go.

The ZoneMinder logs will indicate there were some events - Go ahead and clear these, they're leftover from the startup.

## Cleaning up

Make sure the environment variables you exported earlier are still available.

### Uninstall the helm release

```
helm uninstall ${TF_VAR_env_name}
```

### Destroy the GKE cluster

```
cd terraform/
terraform destroy -auto-approve
cd ../
```

### Destroy the created service account

```
bash scripts/destroy-service-account.sh
```

# Pricing (USD)

The stack should cost about $33 USD per month, excluding traffic charges, with the default configuration.

### GKE Compute Charges

By default, we request 1GB of RAM and .25 vCPU.  The first GKE control plane is free, per the [GKE free tier](https://cloud.google.com/kubernetes-engine/pricing)

We assume the deployment exists in us-central1

#### Monthly

.25 vCPU @ 32.80/mo = 8.20/mo
1GB RAM @ 3.5934250/mo = 3.5934250/mo
1GB Ephemeral @ 0.0400040/mo = 0.0400040/mo

8.20 + 3.5934250 + 0.0400040 = 11.833429/mo

### GKE PersistentVolume Charges

By default, we request 100Mi for the configuration PVC, and 10Gi for the data PVC, of type SSD.  (Pricing Reference)[https://cloud.google.com/compute/disks-image-pricing#disk]

0.17/GB/Mo for SSD provisioned space

10.1 GB * 0.17/mo = 1.717/mo

### GCP VPC Load Balancer Charges

We have two forwarding rules, one for 9000/tcp and one for 8443/tcp

The first 5 forwarding rules are a static 0.025/hr.  This adds $18.25/month to the bill

### GCP VPC Egress charges

Egress should be minimal, unless you're reviewing or downloading footage.

0.12/GB/mo for the first TB.  I'll budget 10GB of data transfer per month.  Is $1.20/month

11.83 + 18.25 + 1.717 + 1.20 ~= $33