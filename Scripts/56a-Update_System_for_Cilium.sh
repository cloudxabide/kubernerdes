# https://ambar-thecloudgarage.medium.com/eks-anywhere-jiving-with-cilium-oss-and-bgp-load-balancer-12af1d10099c

kubectl -n kube-system annotate serviceaccount cilium meta.helm.sh/release-name=cilium
kubectl -n kube-system annotate serviceaccount cilium meta.helm.sh/release-namespace=kube-system
kubectl -n kube-system label serviceaccount cilium app.kubernetes.io/managed-by=Helm
kubectl -n kube-system annotate serviceaccount cilium-operator meta.helm.sh/release-name=cilium
kubectl -n kube-system annotate serviceaccount cilium-operator meta.helm.sh/release-namespace=kube-system
kubectl -n kube-system label serviceaccount cilium-operator app.kubernetes.io/managed-by=Helm
kubectl -n kube-system annotate secret hubble-ca-secret meta.helm.sh/release-name=cilium
kubectl -n kube-system annotate secret hubble-ca-secret meta.helm.sh/release-namespace=kube-system
kubectl -n kube-system label secret hubble-ca-secret app.kubernetes.io/managed-by=Helm
kubectl -n kube-system annotate secret hubble-server-certs meta.helm.sh/release-name=cilium
kubectl -n kube-system annotate secret hubble-server-certs meta.helm.sh/release-namespace=kube-system
kubectl -n kube-system label secret hubble-server-certs app.kubernetes.io/managed-by=Helm
kubectl -n kube-system annotate configmap cilium-config meta.helm.sh/release-name=cilium
kubectl -n kube-system annotate configmap cilium-config meta.helm.sh/release-namespace=kube-system
kubectl -n kube-system label configmap cilium-config app.kubernetes.io/managed-by=Helm
kubectl -n kube-system annotate secret cilium-ca meta.helm.sh/release-name=cilium
kubectl -n kube-system annotate secret cilium-ca meta.helm.sh/release-namespace=kube-system
kubectl -n kube-system label secret cilium-ca app.kubernetes.io/managed-by=Helm
kubectl -n kube-system annotate service hubble-peer meta.helm.sh/release-name=cilium
kubectl -n kube-system annotate service hubble-peer meta.helm.sh/release-namespace=kube-system
kubectl -n kube-system label service hubble-peer app.kubernetes.io/managed-by=Helm
kubectl -n kube-system annotate daemonset cilium meta.helm.sh/release-name=cilium
kubectl -n kube-system annotate daemonset cilium meta.helm.sh/release-namespace=kube-system
kubectl -n kube-system label daemonset cilium app.kubernetes.io/managed-by=Helm
kubectl -n kube-system annotate deployment cilium-operator meta.helm.sh/release-name=cilium
kubectl -n kube-system annotate deployment cilium-operator meta.helm.sh/release-namespace=kube-system
kubectl -n kube-system label deployment cilium-operator app.kubernetes.io/managed-by=Helm
kubectl annotate clusterrole cilium meta.helm.sh/release-name=cilium
kubectl annotate clusterrole cilium meta.helm.sh/release-namespace=kube-system
kubectl label clusterrole cilium app.kubernetes.io/managed-by=Helm
kubectl annotate clusterrole cilium-operator meta.helm.sh/release-name=cilium
kubectl annotate clusterrole cilium-operator meta.helm.sh/release-namespace=kube-system
kubectl label clusterrole cilium-operator app.kubernetes.io/managed-by=Helm
kubectl annotate clusterrolebinding cilium meta.helm.sh/release-name=cilium
kubectl annotate clusterrolebinding cilium meta.helm.sh/release-namespace=kube-system
kubectl label clusterrolebinding cilium app.kubernetes.io/managed-by=Helm
kubectl annotate clusterrolebinding cilium-operator meta.helm.sh/release-name=cilium
kubectl annotate clusterrolebinding cilium-operator meta.helm.sh/release-namespace=kube-system
kubectl label clusterrolebinding cilium-operator app.kubernetes.io/managed-by=Helm
kubectl annotate role cilium-config-agent -n kube-system meta.helm.sh/release-name=cilium
kubectl annotate role cilium-config-agent -n kube-system meta.helm.sh/release-namespace=kube-system
kubectl label role cilium-config-agent -n kube-system app.kubernetes.io/managed-by=Helm
kubectl annotate rolebinding cilium-config-agent -n kube-system meta.helm.sh/release-name=cilium
kubectl annotate rolebinding cilium-config-agent -n kube-system meta.helm.sh/release-namespace=kube-system
kubectl label rolebinding cilium-config-agent -n kube-system app.kubernetes.io/managed-by=Helm

kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.0.0/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.0.0/config/crd/standard/gateway.networking.k8s.io_gateways.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.0.0/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.0.0/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.0.0/config/crd/experimental/gateway.networking.k8s.io_grpcroutes.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.0.0/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml


