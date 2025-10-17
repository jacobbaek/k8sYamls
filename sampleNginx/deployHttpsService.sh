#!/bin/bash
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout tls.key \
  -out tls.crt \
  -subj "/CN=nginx-https-svc.default.svc.cluster.local/O=Local"

kubectl create secret tls nginx-https-tls \
  --cert=tls.crt --key=tls.key

kubectl apply -f httpsService.yaml
