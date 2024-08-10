## Create certificates and register hosts

Generate a local CA so we can create locally trusted certificates

# Trust locally

## Installation pre-requisites

```sh
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
argocd repo add https://github.com/adaptivekind/app-of-apps.git \
  --github-app-id $GITHUB_APP_ID \
  --github-app-installation-id $GITHUB_APP_INSTALLATION_ID \
  --github-app-private-key-path $GITHUB_APP_PRIVATE_KEY_PATH
```

Apply the project

```sh
kubectl apply -f boot/project-default.yaml
```

Install app of apps

```sh
argocd app create app-of-apps \
  --sync-policy automated --sync-option Prune=true \
  --repo https://github.com/adaptivekind/app-of-apps.git \
  --path env/k3d \
  --dest-server https://kubernetes.default.svc
```

Set Grafana TLS secret

```sh
kubectl create -n monitoring secret tls grafana-server-tls \
  --cert=$HOME/local/certs/grafana-local.crt \
  --key=$HOME/local/certs/grafana-local.key
```

Set Grafana password

```sh
kubectl create -n monitoring secret generic grafana-password \
  --from-literal=admin-password=$GRAFANA_PASSWORD         \
  --from-literal=admin-user=admin
```

Grafana at <https://grafana.local/>.

Add Prometheus and Loki data source

- <http://prometheus-server.monitoring.svc.cluster.local>
- <http://loki.monitoring.svc.cluster.local:3100>


