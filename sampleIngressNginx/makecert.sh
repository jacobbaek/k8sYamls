#!/bin/bash
## https://kubernetes.github.io/ingress-nginx/user-guide/tls/

HOST="jacobcerttest.kr"
KEY_FILE="jacobcerttest.key"
CERT_FILE="jacobcerttest.crt"

CERT_NAME="ingress-cert"
NAMESPACE="ingresstest"

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${KEY_FILE} -out ${CERT_FILE} -subj "/CN=${HOST}/O=${HOST}" -addext "subjectAltName = DNS:${HOST}"
kubectl create ns $NAMESPACE
kubectl create secret tls ${CERT_NAME} --key ${KEY_FILE} --cert ${CERT_FILE}
