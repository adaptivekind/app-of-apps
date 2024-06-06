# App of apps

## Create certificates and register hosts

Generate a local CA so we can create locally trusted certificates

```sh
mkdir -p ~/local/certs
openssl genrsa -out ~/local/certs/local-ca.key 2048
openssl req -new -x509 -subj "/CN=Local CA" \
  -key ~/local/certs/local-ca.key \
  -out ~/local/certs/local-ca.crt
```

And trust locally

```sh
sudo security add-trusted-cert -d -r trustRoot \
  -k "/Library/KeyChains/System.keychain" \
  ~/local/certs/local-ca.crt
```

Then create certificate for Argo CD and Grafana

```sh
openssl req -subj '/CN=argocd.local' \
  -new -newkey rsa:2048 -sha256 -noenc -x509 \
  -addext "subjectAltName = DNS:argocd.local" \
  -CA ~/local/certs/local-ca.crt \
  -CAkey ~/local/certs/local-ca.key \
  -keyout ~/local/certs/argocd-local.key \
  -out ~/local/certs/argocd-local.crt
openssl req -subj '/CN=grafana.local' \
  -new -newkey rsa:2048 -sha256 -noenc -x509 \
  -addext "subjectAltName = DNS:grafana.local" \
  -CA ~/local/certs/local-ca.crt \
  -CAkey ~/local/certs/local-ca.key \
  -keyout ~/local/certs/grafana-local.key \
  -out ~/local/certs/grafana-local.crt
```

Add the following to `/etc/hosts`

```sh
127.0.0.1 argocd.local
127.0.0.1 grafana.local
```

## Installation pre-requisites

```sh
helm repo add argo https://argoproj.github.io/argo-helm
brew install argocd
brew install direnv
```

In project directory:

```sh
direnv allow
```

Create `.envrc` file in current folder with the GitHub app details set.

```sh
export GITHUB_APP_ID=1234
export GITHUB_APP_INSTALLATION_ID=5678
export GITHUB_APP_PRIVATE_KEY_PATH=my-key.pem
```

## Bootstrap of cluster

Start up Docker and bootstrap with k3d cluster.

```sh
k3d cluster create my-cluster -p "443:443@loadbalancer"
helm repo update
helm install argocd argo/argo-cd --namespace argocd --create-namespace
```

Set up Argo CD route

```sh
kubectl apply -f app-of-apps/boot/argocd-route.yaml
```

Set Argo CD certificate

```sh
kubectl create -n argocd secret tls argocd-server-tls \
  --cert=$HOME/local/certs/argocd-local.crt \
  --key=$HOME/local/certs/argocd-local.key
```

Get Argo CD password

```sh
argocd admin initial-password -n argocd | head -n 1 | pbcopy
```

Log in to Argo CD with username admin and password from above.

```sh
argocd login --username admin argocd.local --grpc-web
```

Change admin password

```sh
argocd account update-password
```

And log in at <https://argocd.local>

## Set up repository

Register this private repository with Argo CD installation.

```sh
export GITHUB_APP_ID=1234
export GITHUB_APP_INSTALLATION_ID=5678
export GITHUB_APP_PRIVATE_KEY_PATH=my-key.pem
argocd repo add https://github.com/adaptivekind/app-of-apps.git \
  --github-app-id $GITHUB_APP_ID \
  --github-app-installation-id $GITHUB_APP_INSTALLATION_ID \
  --github-app-private-key-path $GITHUB_APP_PRIVATE_KEY_PATH
```

Apply the project

```sh
kubectl apply -f app-of-apps/projects/project-default.yaml
```

Check repo and projects set up

```sh
argocd repo list
argocd proj list
```

Install app of apps

```sh
argocd app create app-of-apps \
  --sync-policy automated --sync-option Prune=true \
  --repo https://github.com/adaptivekind/app-of-apps.git \
  --path app-of-apps/k3d \
  --dest-server https://kubernetes.default.svc
```

Set Grafana TLS secret

```sh
kubectl create -n lens secret tls grafana-server-tls \
  --cert=$HOME/local/certs/grafana-local.crt \
  --key=$HOME/local/certs/grafana-local.key
```

Get Grafana admin password

```sh
kubectl get secret grafana -n lens -o jsonpath="{.data.admin-password}" |
  base64 --decode | pbcopy
```

Grafana at <https://grafana.local/> and change password.

## Clean up

Delete the app

```sh
argocd app delete app-of-apps
helm uninstall argo-cd -n argocd
```
