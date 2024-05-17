#!/bin/sh

#     Purpose:  Configure Ingress (metalLB and emissary)
#        Date:  2024-05-16
#      Status:  Incomplete/In-Progress
# Assumptions:
#        Todo:
#  References:

cd ${HOME}/eksa/$CLUSTER_NAME/latest

git clone https://github.com/cloudxabide/eks-workshop.git
git clone https://github.com/cloudxabide/ecsdemo-frontend.git
git clone https://github.com/cloudxabide/ecsdemo-nodejs.git
git clone https://github.com/cloudxabide/ecsdemo-crystal.git

cd ecsdemo-nodejs
kubectl create ns ecsdemo
kubectl config set-context --current --namespace=ecsdemo
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
