#!/bin/bash

### create service account to allow spinnaker to upload to cloud storage...

gcloud iam service-accounts create  spinnaker-account \
    --display-name spinnaker-account
export SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:spinnaker-account" \
    --format='value(email)')
export PROJECT=$(gcloud info --format='value(config.project)')

gcloud projects add-iam-policy-binding \
    $PROJECT --role roles/storage.admin --member serviceAccount:$SA_EMAIL

gcloud iam service-accounts keys create spinnaker-sa.json --iam-account $SA_EMAIL

kubectl.sh create clusterrolebinding --clusterrole=cluster-admin --serviceaccount=default:default spinnaker-admin


echo "Create a bucket for Spinnaker to store its pipeline configuration:"

export PROJECT=$(gcloud info \
    --format='value(config.project)')
export BUCKET=$PROJECT-spinnaker-config
gsutil mb -c regional -l us-central1 gs://$BUCKET


echo "Now we're going to reference the spinnaker.config so make sure it exists and its contects are copied from"
echo "https://cloud.google.com/solutions/continuous-delivery-spinnaker-kubernetes-engine"

sleep 5

echo "Deploying Spinnaer through Helm chart"
export SA_JSON=$(cat spinnaker-sa.json)
export PROJECT=$(gcloud info --format='value(config.project)')
export BUCKET=$PROJECT-spinnaker-config

helm install -n cd stable/spinnaker -f spinnaker-config.yaml --timeout 600 \
    --version 1.1.6 --wait
