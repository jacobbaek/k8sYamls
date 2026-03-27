#!/bin/bash

DOMAIN="demo.example.com"
NS="nginx-sample"

mkdir -p certs && cd certs

### Generates client's certificate
echo "[INFO] client certificates"

# CA private key
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out ca.key

# CA cert (10 years)
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 \
  -subj "/CN=Demo-Root-CA" \
  -out ca.crt

cat > client-openssl.cnf << EOF
[ req ]
default_bits       = 2048
prompt             = no
default_md         = sha256
distinguished_name = dn
req_extensions     = req_ext

[ dn ]
CN = demo-client

[ req_ext ]
extendedKeyUsage = clientAuth
EOF

### Generates server's key and cert
echo "[INFO] Generates server's certificate"

cat > server-openssl.cnf << EOF
[ req ]
default_bits       = 2048
prompt             = no
default_md         = sha256
distinguished_name = dn
req_extensions     = req_ext

[ dn ]
CN = ${DOMAIN}

[ req_ext ]
subjectAltName = @alt_names
extendedKeyUsage = serverAuth

[ alt_names ]
DNS.1 = ${DOMAIN}
EOF

# server key
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out server.key

# CSR
openssl req -new -key server.key -out server.csr -config server-openssl.cnf

# sign by CA
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out server.crt -days 365 -sha256 -extensions req_ext -extfile server-openssl.cnf

openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out client.key
openssl req -new -key client.key -out client.csr -config client-openssl.cnf

openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out client.crt -days 365 -sha256 -extensions req_ext -extfile client-openssl.cnf

### Generates tls secrets
echo "[INFO] tls secrets"
kubectl create ns $NS
kubectl -n $NS create secret tls demo-server-tls \
  --cert=server.crt \
  --key=server.key

kubectl -n $NS create secret generic demo-client-ca \
  --from-file=ca.crt=ca.crt

### Generates real service
echo "[INFO] deploy real service"

cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  namespace: $NS
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.27-alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc
  namespace: $NS
spec:
  selector:
    app: nginx
  ports:
  - name: http
    port: 80
    targetPort: 80
EOF

### Generates ingress
echo "[INFO] deploy ingress"

cat << EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-mtls
  namespace: $NS
  annotations:
    nginx.ingress.kubernetes.io/auth-tls-secret: "$NS/demo-client-ca"
    nginx.ingress.kubernetes.io/auth-tls-verify-client: "on"
    nginx.ingress.kubernetes.io/auth-tls-verify-depth: "2"
    nginx.ingress.kubernetes.io/auth-tls-pass-certificate-to-upstream: "true"
spec:
  #ingressClassName: webapprouting.kubernetes.azure.com
  ingressClassName: nginx
  tls:
  - hosts:
    - ${DOMAIN}
    secretName: demo-server-tls
  rules:
  - host: ${DOMAIN}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-svc
            port:
              number: 80
EOF
