
#Create a root certificate and private key to sign the certificates using following command
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=example Inc./CN=example.com' -keyout example.com.key -out example.com.crt
#Create a csr certificate and a private key for onlineboutique.example.com
openssl req -out onlineboutique.example.com.csr -newkey rsa:2048 -nodes -keyout onlineboutique.example.com.key -subj "/CN=onlineboutique.example.com/O=demo organization"
#Sign the csr using root ca and root key
openssl x509 -req -sha256 -days 365 -CA example.com.crt -CAkey example.com.key -set_serial 0 -in onlineboutique.example.com.csr -out onlineboutique.example.com.crt
#Create a kubernetes secrets object for the cert and key

kubectl create -n istio-system secret tls onlineboutique-credential --key=onlineboutique.example.com.key  --cert=onlineboutique.example.com.crt