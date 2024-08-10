#!/usr/bin/env sh

CERTS_DIR=~/local/certs

if [ ! -d "${CERTS_DIR}" ] ; then
  echo "Creating directory ${CERTS_DIR}"
  mkdir -p ${CERTS_DIR}
fi

# Generate certificates for a local certificate authority

if [ ! -f "${CERTS_DIR}/local-ca.key" ] ; then
  echo "Creating local CA key : ${CERTS_DIR}/local-ca.key"
  openssl genrsa -out ${CERTS_DIR}/local-ca.key 2048
fi

if [ ! -f "${CERTS_DIR}/local-ca.crt" ] ; then
  echo "Creating local CA certificate : ${CERTS_DIR}/local-ca.crt"
  openssl req -new -x509 -subj "/CN=Local CA" \
    -key ${CERTS_DIR}/local-ca.key \
    -out ${CERTS_DIR}/local-ca.crt
fi

# Create certificate for Argo CD and Grafana

if [ ! -f "${CERTS_DIR}/argocd-local.key" ] ; then
  echo "Creating ArgoCD key and certificate"
  openssl req -subj '/CN=argocd.local' \
    -new -newkey rsa:2048 -sha256 -noenc -x509 \
    -addext "subjectAltName = DNS:argocd.local" \
    -CA ${CERTS_DIR}/local-ca.crt \
    -CAkey ${CERTS_DIR}/local-ca.key \
    -keyout ${CERTS_DIR}/argocd-local.key \
    -out ${CERTS_DIR}/argocd-local.crt
fi

if [ ! -f "${CERTS_DIR}/grafana-local.key" ] ; then
  openssl req -subj '/CN=grafana.local' \
    -new -newkey rsa:2048 -sha256 -noenc -x509 \
    -addext "subjectAltName = DNS:grafana.local" \
    -CA ${CERTS_DIR}/local-ca.crt \
    -CAkey ${CERTS_DIR}/local-ca.key \
    -keyout ${CERTS_DIR}/grafana-local.key \
    -out ${CERTS_DIR}/grafana-local.crt
fi

echo "Certificates and keys created in ${CERTS_DIR}"
ls -l ${CERTS_DIR}

