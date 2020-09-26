#!/usr/bin/env bash

MY_PROJECT=gorgias-project

gcloud projects create $MY_PROJECT

gcloud container clusters create my-cluster \
    --zone us-central1-a \
    --node-locations us-central1-a,us-central1-b \
    --num-nodes 2 \
    --project $MY_PROJECT

gcloud container clusters get-credentials my-cluster --zone us-central1-a --project $MY_PROJECT

kubectl apply -R -f kube

kubectl wait deploy/flask --for condition=available
kubectl wait deploy/pgpool --for condition=available
kubectl wait job/flask-db-upgrade --for condition=complete --timeout=2m
kubectl rollout status statefulset/postgresql

# get load balancer
LOAD_BALANCER=$(kubectl get svc/flask -n default -o jsonpath="{.status.loadBalancer.ingress[*].ip}")

# open load balancer endpoint
open "http://$LOAD_BALANCER"
