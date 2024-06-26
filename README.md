# My Kubernetes Lab - kubernerdes.lab 

This is the chronicles of deploying Kubernetes (Amazon EKS Anywhere) in a HomeLab: The Kubernerdes lab.
This opinionated installation utilzes Amazon EKS Anywhere and Open Source Software.

| Project Homepage | Description |
|:-----------------|:-------------|
| [EKS-Anywhere](https://anywhere.eks.amazonaws.com/) | Amazon EKS Anywhere is container management software built by AWS that makes it easier to run and manage Kubernetes on-premises and at the edge. |
| [Emissary](https://www.getambassador.io/docs/emissary/latest/tutorials/getting-started) | Emissary-Ingress is the most popular API Gateway Kubernetes-native - open-source, that delivers the scalability, flexibility, and simplicity for some of the world's largest Kubernetes installations. Emissary-Ingress is an open source CNCF incubating project, and it uses the ubiquitous Envoy Proxy at its core. |
| [MetalLB](https://metallb.universe.tf/) | MetalLB is a load-balancer implementation for bare metal Kubernetes clusters, using standard routing protocols. |
| [Cilium (OSS)](https://cilium.io/) | Cilium is a networking, observability, and security solution with an eBPF-based dataplane. <BR> (from [Isovalent - a Cisco Company)](https://isovalent.com/) | 
| [Hubble](https://github.com/cilium/hubble) | Hubble is a fully distributed networking and security observability platform for cloud native workloads. |
| [Prometheus](https://prometheus.io/) | From metrics to insight Power your metrics and alerting with the leading open-source monitoring solution. |
| [Grafana](https://github.com/grafana/grafana) | The open and composable observability and data visualization platform. |


**Goal:**  
Deploy EKS Anywhere environment using bare metal (Intel NUCs) starting with a USB stick with install media (Ubuntu Server 22.04 + Desktop Software). This environment will be completely independent of everything else in my lab. 

**Status:**  
Work in Progress.  But, if something is missig, everything you need is in the [AWS Docs](https://anywhere.eks.amazonaws.com/docs/) - dedicate an afternoon and you'll be far enough along to roll out a K8s cluster.  
There will be some refactoring occurring - mostly regarding where different steps/tasks are, and the filenames where the tasks are documented.  
**Prologue:**  
Note:  Any code found in my "scripts" that is encapsulated in a bash routine - ie. my_route(){ code; } generally means it is some optional code that I won't generally use. (like installing the Desktop UI)

The ["Scripts"](./Scripts) directory is where all the scripts live (obviously?). Eventually they will be "runable" using (sh ./10_script.sh) - but at this point, the scripts are primarily used as cut-and-paste.

This project has been created to be a [network enclave](https://en.wikipedia.org/wiki/Network_enclave) - meaning, it should be able to "stand alone" and function.  That carries some assumptions:

* DNS - I have created a standalone domain "kubernerdes.lab". 
* DHCP - The installer will handle DHCP during the install via the "boots container" hosted on the "admin host".  The boots container then gets migrated to the running cluster (and continues to handle DHCP for this network).  I will be exploring how to have both the "boots DHCP" and my own "subnet DHCP" coexist.
* Cluster Access - and this is where things potentially get tricky, if you let it.  If I simply create the enclave with **everything** in that enclave, things are relatively straight-forward.  Therefore, I am creating this repo with that in mind - everything is in the 10.10.12.0/22 subnet.
* Lab User:  "My Ansible" (mansible)
* File Naming:  I will be including a numeric representation which signifies how many Control-Plane and Workers (3_0 = 3 CP, 0 workers).  Also there will be occassions where I also include the Kubernetes version in the file name.

It is worth noting that a portion of this repo is likely not applicable in most situations.  I am essentially start at the point where I am plumbing up a new interface on my Firewall, creating a new /22 CIDR off that interface, and starting from scratch - things you would not (or could not) need to do if you were in an enterprise situation.

![Kubernerdes Lab](Images/KubernerdesLab-3_0.png)
![Kubernerdes Lab](Images/NodeLayout-KubernetesNode.png)

## Steps
* Build the Admin Host (thekubernerd.kubernerdes.lab)
* Kickoff the EKS Install process
* Power On the NUCs (and select Network Boot (f12))
* Do some Post Install tasks
* Install some Apps and Ingress, etc..

## Build THEKUBERNERD Host
You will need to install Ubuntu on "TheKubernerd" (the "Admin Host" referenced in the docs).  

Then apply the [Post Install Script - THEKUBERNERD](Scripts/00_Post_Install_THEKUBERNERD.sh)

The EKS Anywhere build process will create all the PXE bits, etc..  EKS Anywhere is incredible.  
It will deploy a KIND Cluster using Docker to build a "bootstrap Cluster" - this will include all the necessary plumbing, etc.. to bootstrap the base OS on the Cluster Nodes.

The only "customization" I am going to pursue is hosting the OS Image and Hooks on my own webeserver, and my own DNS server for my Lab.    
* [Ansible](Scripts/10_Install_Ansible.sh)
* [EKS Tools](Scripts/11_Install_EKS_Tools.sh)
* [BIND](Scripts/15_Install_BIND9.sh)

While not necessary, I include the WebServer so that the artifacts can be provided (such as: osImage, hookImages)
* [WWW Server](Scripts/Install_HTTP_Server.sh) - add WebServer to listen on 8080

Uneeded (this is all handled by the "tinkerbell boots" container):  
* [DHCP Server](Scripts/Install_DHCP_Server.sh)

## Configurations for this Deployment (3 x NUC)
My "inventory" or "hardware.csv" files do not include BMC info - primarily because my NUC(s) have no ILO/BMC.

| Control-Plane | Worker Nodes | GPU Nodes | Inventory File |
|:-------------:|:------------:|:---------:|:---------------|
| 3 | 0 | 0 | [Hardware 3_0](Files/hardware-3_0.csv) |

## Deploy EKS Anywhere Cluster
**ProTip:**
I only use labels of "node=cp-machine" in the hardware.csv inventory file, and remove the WorkerNodeGroup from the clusterConfig, as a result Control-Plane nodes will not be tainted and workloads can run there.  

Start with the following to deploy the cluster  
[Install EKS Anywhere](Scripts/50_Deploy_BareMetal_EKS-A_Cluster.sh)

## Utilization
The following is my 3 x NUC cluster utilization with basic infrastructure components running (Prometheus/Grafana, openEBS, Cilium OSS/HubbleUI)  
![Kubernerdes Lab - Utilization](Images/KubernerdesLab-Utilization.png)

## References
[EKS Anywhere - Landing Page](https://anywhere.eks.amazonaws.com/)  
[EKS Anywhere - Docs](https://anywhere.eks.amazonaws.com/docs/)  
[Ubuntu Server - Download](https://ubuntu.com/download/server)  

[Containers from the Couch - Search String: EKS Anywhere (YouTube)](https://www.youtube.com/@ContainersfromtheCouch/search?query=eks%20anywhere)

