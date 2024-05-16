#!/bin/bash

#     Purpose:  Configure Ingress (metalLB and emissary)
#        Date:  2024-05-16
#      Status:  Incomplete/In-Progress
# Assumptions:
#        Todo:
#  References:


# Install Emissary Ingress
helm repo add datawire https://app.getambassador.io
helm repo update

# Create Namespace and Install:
kubectl create namespace emissary && \
kubectl apply -f https://app.getambassador.io/yaml/emissary/3.9.1/emissary-crds.yaml

kubectl wait --timeout=90s --for=condition=available deployment emissary-apiext -n emissary-system

helm install emissary-ingress --namespace emissary datawire/emissary-ingress && \
kubectl -n emissary wait --for condition=available --timeout=90s deploy -lapp.kubernetes.io/instance=emissary-ingress

kubectl get svc  --namespace emissary emissary-ingress

# See what changes would occur
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl diff -f - -n kube-system
# Apply those changes
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system

mkdir ~/eksa/$CLUSTER_NAME/latest/metallb;
cd ~/eksa/$CLUSTER_NAME/latest/metallb

CIDR_POOL="10.10.13.1-10.10.13.255";;

# Test without this
cat << EOF2 | tee metallb-ns.yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: metallb-system
  labels:
    pod-security.kubernetes.io/enforce: privileged
    pod-security.kubernetes.io/audit: privileged
    pod-security.kubernetes.io/warn: privileged

EOF2
kubectl apply -f metallb-ns.yaml

kubectl config set-context --current --namespace=metallb-system

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml

cat << EOF1 | tee metallb-configmap.yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  namespace:  metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - $CIDR_POOL

EOF1
kubectl apply -f metallb-configmap.yaml

cat << EOF43 | tee L2Advertisement.yaml
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
EOF43
kubectl apply -f L2Advertisement.yaml

kubectl rollout restart deployment controller -n metallb-system

kubectl config set-context --current --namespace=default

exit 0

cleanup() {
kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml
}



