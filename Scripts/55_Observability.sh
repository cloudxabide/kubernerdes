#!/bin/bash

#     Purpose: To install Prometheus/Grafana
#        Date: 2024-04-24
#      Status: Work-In-Progress - converting to OSS
# Assumptions:
#        Todo: Update this procedure to use OSS versions of Prometheus and Grafana.  (Create helm charts?)
#  References:

# https://github.com/prometheus-operator/prometheus-operator
# https://github.com/prometheus-operator/kube-prometheus

# Create the namespace and CRDs, and then wait for them to be available before creating the remaining resources
# Note that due to some CRD size we are using kubectl server-side apply feature which is generally available since kubernetes 1.22.
# If you are using previous kubernetes versions this feature may not be available and you would need to use kubectl create instead.

git clone https://github.com/prometheus-operator/kube-prometheus.git
cd kube-prometheus/
#
kubectl apply --server-side -f manifests/setup
kubectl wait \
	--for condition=Established \
	--all CustomResourceDefinition \
	--namespace=monitoring
kubectl apply -f manifests/
while sleep 2; do kubectl get all -n monitoring | egrep 'ContainerCreating|Init' || break; done
kubectl config set-context --current --namespace=default

## Install Grafana
GRAFANA_NAMESPACE=monitoring
kubectl create namespace $GRAFANA_NAMESPACE 
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install my-grafana grafana/grafana --namespace  $GRAFANA_NAMESPACE
kubectl get secret --namespace $GRAFANA_NAMESPACE my-grafana -o jsonpath="{.data.admin-password}" | base64 --decode > $GRAFANA_NAMESPACE-secret.txt

DEFAULT_STORAGE_CLASS=$(kubectl get sc| grep "(default)" | awk '{ print $1 }')
cat << EOF1 | tee my-grafana-storage.yaml
---
persistence:
  type: pvc
  enabled: true
  storageClassName:  $DEFAULT_STORAGE_CLASS 
EOF1
helm upgrade my-grafana grafana/grafana -f my-grafana-storage.yaml -n $GRAFANA_NAMESPACE 

clean_up() {
for n in $(kubectl get namespaces -o jsonpath={..metadata.name}); do
  kubectl delete --all --namespace=$n prometheus,servicemonitor,podmonitor,alertmanager
done
kubectl delete -f bundle.yaml
for n in $(kubectl get namespaces -o jsonpath={..metadata.name}); do
  kubectl delete --ignore-not-found --namespace=$n service prometheus-operated alertmanager-operated
done

kubectl delete --ignore-not-found customresourcedefinitions \
  prometheuses.monitoring.coreos.com \
  servicemonitors.monitoring.coreos.com \
  podmonitors.monitoring.coreos.com \
  alertmanagers.monitoring.coreos.com \
  prometheusrules.monitoring.coreos.com
}

exit 0

