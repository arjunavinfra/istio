**Setup**

- Provision a 4 node(1 master, 3 workers) kind cluster.
- Fork the repository https://github.com/hr1sh1kesh/online-boutique and deploy the application on your cluster.
- Setup a loadbalancer locally on kind (check instructions for installing metallb)
- Install Istio 1.10 on the cluster (Do not do this step before you deploy the application.)
- Inject the Istio sidecar in your application.




  Run the script Deploy.sh to setup the cluster with above specification 
  
  ```
  Deploy.sh
  ``` 

**#Task 1**

Gateways:
Expose the frontend service of the application using the Istio-ingress gateway.
The host to be used is "onlineboutique.example.com" for the Ingress gateway. Any other host's requests should be rejected by the gateway.

Deploy 

  ```
  kubectl apply -f Task-1[Gateways]/
  
  ```
  
For testing 

```
kubectl get gw

ip=`kubectl get svc -n istio-system | grep istio-ingressgateway | awk '{print $4}'`

curl -H  "host: onlineboutique.example.com" -fSsl $ip

```

**#Task 2**

Traffic routing:
Split the traffic between the frontend and frontend-v2 service by 50%.
The way to verify that this works is when 50% of the requests would show the landing page banner as "Free shipping with $100 purchase!" vs "Free shipping with $75 purchase!"

Deploy

  ```
  kubectl apply -f Task-2[Traffic-routing]/
  ```
  
For testing 

```
ip=`kubectl get svc -n istio-system | grep istio-ingressgateway | awk '{print $4}'`
curl -H  "host: onlineboutique.example.com" -fSsl $ip | grep "<b>Pod:"
curl -H  "host: onlineboutique.example.com" -fSsl $ip | grep "<b>Pod:"

```

**#Task 3**

Traffic Routing:
Route traffic to the based on the browser being used.
When you use Firefox the Gateway routes to the frontend service whereas it routes to the frontend-v2 pods if it is accessed via Chrome.
Hint: use the user-agent HTTP header added by the browser.

  ```
  kubectl apply -f Task-3[Traffic-Routing-user-agent]/
  
  ```
For testing

```
ip=`kubectl get svc -n istio-system | grep istio-ingressgateway | awk '{print $4}'`
#firefix Useragent
curl -H "host: onlineboutique.example.com" -H  "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:107.0) Gecko/20100101 Firefox/107.0" -fSsl $ip 
#chrome user agent 
curl -H "host: onlineboutique.example.com" -H  "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36" -fSsl $ip 

```

**#Task 4**

Timeout:
This is a slightly different lab. You need to tighten the boundaries of acceptable latency in this lab.
Delete the productcatalogservice. There is a lot of latency between the frontend and the productcatalogv2 service. add a timeout of 3s. (You need to produce a 504 Gateway timeout error).

Deploy

  ```
  kubectl apply -f Task-4[Timeout]
  
  
  ```
  
  Testing 
  ```
  ip=`kubectl get svc -n istio-system | grep istio-ingressgateway | awk '{print $4}'`
  kubectl delete pods -l app=productcatalogservice
  curl -H "host: onlineboutique.example.com"  -fSsl $ip 
  
  ```
  
**#Task 5**

TLS:
Setup a TLS ingress gateway for the frontend service. Generate self signed certificates and add them to the Ingress Gateway for TLS communication.

Deploy 

  step 1: Generate self signed certificate using script 1-CertGenerator.sh
  
```
  cd Task-5[tlsIngress]
  bash 1-CertGenerator.sh
```
step 2: Modify the gateway with ssl details 

```
  kubectl apply -f 2-gateway-tls.yaml
  
```

Testing 

```
 curl --insecure https://onlineboutique.example.com -s -o /dev/null -v
 
```
