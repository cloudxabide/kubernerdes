#!/bin/bash

#     Purpose:  Expose a few services with "external IPs" using LoadBalancer
#        Date:  2024-05-16
#      Status:  WIP
# Assumptions:  Services referenced here were deployed using this steps in this repo
#                 i.e. service name, namespace, port - have to align with values in "ServiceMap" (below)
#        Todo:
#  References:

# Status:  Need to work on this and figure out how to assign pre-determined addresses to service
#            Likely do an NSLOOKUP to get the IP from DNS, then assign

cd ~/eksa/$CLUSTER_NAME/latest/
mkdir service_exposure; cd $_

SERVICEMAPFILE=./SERVICEMAP.csv
cat << EOF2 | tee $SERVICEMAPFILE
#APPNAME|NAMESPACE|PORT
prometheus-k8s|monitoring|9090
my-grafana|monitoring|80
hubble-ui|kube-system|80
EOF2

grep -v \# $SERVICEMAPFILE | awk -F"|" '{ print $1" "$2 }' | while read -r APPNAME NAMESPACE PORT
do
  #echo "$APPNAME $NAMESPACE $PORT"
  echo "kubectl patch svc $APPNAME -n $NAMESPACE -p '{\"spec\": {\"type\": \"LoadBalancer\"}}'"
  kubectl patch svc $APPNAME -n $NAMESPACE -p '{"spec": {"type": "LoadBalancer"}}'
  echo
done

kubectl get svc -A | grep LoadBalancer
cd -

exit 0

# I will Add these Grafana dashboards 315 1860 18283
# The URL for the prometheus endpoint (to add as a Datasource for Grafana) 
# http://prometheus-k8s.monitoring:9090
