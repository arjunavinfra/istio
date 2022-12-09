Setup
Provision a 4 node(1 master, 3 workers) kind cluster.
Fork the repository https://github.com/hr1sh1kesh/online-boutique and deploy the application on your cluster.
Setup a loadbalancer locally on kind (check instructions for installing metallb)
Install Istio 1.10 on the cluster (Do not do this step before you deploy the application.)
Inject the Istio sidecar in your application.

  Run the script ```Deploy.sh``` to setup the cluster with above specification 

Gateways:
Expose the frontend service of the application using the Istio-ingress gateway.
The host to be used is "onlineboutique.example.com" for the Ingress gateway. Any other host's requests should be rejected by the gateway.

  ```kubectl apply -f Task-1[Gateways]/```

Traffic routing:
Split the traffic between the frontend and frontend-v2 service by 50%.
The way to verify that this works is when 50% of the requests would show the landing page banner as "Free shipping with $100 purchase!" vs "Free shipping with $75 purchase!"

  ```kubectl apply -f Task-2[Traffic-routing]/```

Traffic Routing:
Route traffic to the based on the browser being used.
When you use Firefox the Gateway routes to the frontend service whereas it routes to the frontend-v2 pods if it is accessed via Chrome.
Hint: use the user-agent HTTP header added by the browser.

  ```kubectl apply -f Task-3[Traffic-Routing-user-agent]/```

Timeout:
This is a slightly different lab. You need to tighten the boundaries of acceptable latency in this lab.
Delete the productcatalogservice. There is a lot of latency between the frontend and the productcatalogv2 service. add a timeout of 3s. (You need to produce a 504 Gateway timeout error).

  ```kubectl apply -f Task-4[Timeout]```

TLS:
Setup a TLS ingress gateway for the frontend service. Generate self signed certificates and add them to the Ingress Gateway for TLS communication.
```
  step 1: Generate self signed certificate using script 1-CertGenerator.sh
  cd Task-5[tlsIngress]
  bash 1-CertGenerator.sh
```
```
  step 2: Modify the gateway with ssl details 
  kubectl apply -f 2-gateway-tls.yaml
```
