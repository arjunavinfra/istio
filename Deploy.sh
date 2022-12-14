#!/bin/bash 


echo -e "\n 🔹Checking the cluster configuration"

count=`kubectl get nodes -o wide | wc -l` > /dev/null

if [ ! "${count}" -ge '5'  ]; then 

echo -e "\n 🔹Provisioning  a 4 node(1 master, 3 workers) kind cluster"

kind delete clusters istio

kind create cluster --config Deploy/0-kind-cluster-config.yaml --name istio
rm -rf /tmp/kube-plgins
git clone https://github.com/arjunavinfra/kubernetes.git /tmp/kube-plgins
cd /tmp/kube-plgins/networking/metalLB/
bash Deploy.sh 
cd - 
echo -e "\n 🔹 Completed the cluster installation"

else
    echo -e "\n 🔹Cluster is already exists"
fi 


echo -e "\n 🔹Installing online-boutique application"


kubectl apply -f Deploy/1-application.yaml

echo -e "\n 🔹Waiting to start application  "

kubectl wait --namespace default   --for=condition=ready pod   --selector=app  --timeout=200s

echo -e "\n"

echo -e "\n  🔹Installing Istio 1.16 on the cluster"

echo -e "\n"

which istioctl > /dev/null 

if [ $? != 0 ]; then 

curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.16.0 TARGET_ARCH=x86_64 sh -
cd istio-1.16.0

export PATH=$PWD/bin:$PATH

else 
  
 echo -e "\n  🔹Istioctl is already installed in cluster"

fi

istioctl operator init  
istioctl apply -f Deploy/0-profile.yaml -y
kubectl get iop -A

kubectl wait --namespace istio-system   --for=condition=ready pod   --selector=app=istiod  --timeout=200s 

echo -e "\n"
echo -e "\n  🔹Waiting the istiod status  to become 1/1 ⏰"

sleep 4

echo -e "\n  🔹The pod status must be  healthy now 🎉"
echo -e "\n"

kubectl get po -n istio-system

echo -e "\n 🔹Injecting label to default namespace 💉"
echo -e "\n"

kubectl label ns default istio-injection=enabled 
kubectl get ns -L istio-injection 


echo -e "\n 🔹Applying addone 🛒"

kubectl apply -f ./Deploy/addone > /dev/null

echo -e "\n 🔹Istio Installation completed 🎌"
echo -e "\n"

sleep 2

