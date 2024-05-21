#!/bin/bash

#     Purpose: To install Prometheus/Grafana
#        Date: 2024-04-24
#      Status: Work-In-Progress - converting to OSS
# Assumptions:
#        Todo: Update this procedure to use OSS versions of Prometheus and Grafana.  (Create helm charts?)
#  References:

# https://github.com/prometheus-operator/prometheus-operator
# https://github.com/prometheus-operator/kube-prometheus

kubectl config set-context --current --namespace=default

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
cd -

## Install Grafana
GRAFANA_NAMESPACE=monitoring
kubectl config set-context --current --namespace=$GRAFANA_NAMESPACE || { kubectl create ns $GRAFANA_NAMESPACE; kubectl config set-context --current --namespace=$GRAFANA_NAMESPACE; }
mkdir $GRAFANA_NAMESPACE; cd $GRAFANA_NAMESPACE
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

## Kubernetes Dashbaord (WIP)
# https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
kubectl -n kubernetes-dashboard patch svc kubernetes-dashboard-kong-proxy -p='{"spec": {"type": "LoadBalancer"}}'

# https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
cat << EOF3 | tee kubernetes-dashboard-sa.yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF3
kubectl apply -f kubernetes-dashboard-sa.yaml

cat << EOF5 | tee kubernetes-dashboard-clusterrolebinding.yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF5
kubectl apply -f kubernetes-dashboard-clusterrolebinding.yaml

# kubectl -n kubernetes-dashboard create token admin-user

cat << EOF6 | tee kubernetes-dashboard-sa-token.yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/service-account.name: "admin-user"   
type: kubernetes.io/service-account-token  
EOF6
kubectl apply -f kubernetes-dashboard-sa-token.yaml
kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d > kubernetes-dashboard-token.out
K8s_DASHBOARD=$(kubectl get svc kubernetes-dashboard-kong-proxy -o jsonpath='{.status.loadBalancer.ingress[].ip}')
echo -e j"Access Kubernetes Dashboard at: \nhttps://$K8s_DASHBOARD"


exit 0


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


