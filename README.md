# App of apps

ArgoCD GitOps managed app of apps for Kubernetes lab environments for
experimentation and learning. The app of apps provide git source of desired
resources to for deployment in a Kubernetes cluster. ArgoCD automatically
applies updates to the resources in the git repository to the Kubernetes
cluster.

## Local k3d cluster

## Install Docker, k3d, Helm and ArgoCD

Get started with a local Kubernetes cluster using k3d. First install and startup
[Docker](https://docs.docker.com/engine/install/). Then install k3d as described
in the [https://k3d.io/](k3d documentation). For example with
[Homebrew](https://brew.sh/):

```sh
brew install k3d
```

Create the cluster with the load balancer listening on port 433 for https
access to the services.

```sh
k3d cluster create my-cluster -p "443:443@loadbalancer"
```

We'll use [Helm](https://helm.sh/) to install ArgoCD in our cluster and use the [argocd](https://argo-cd.readthedocs.io/en/stable/getting_started/#2-download-argo-cd-cli) command
line interface for convenience. For example, with Homebrew install with:

```sh
brew install helm argocd
```

Add the Helm repository for ArgoCD which hosts the Helm charts we need.

```sh
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

### Set up routes to ArgoCD and log in

Set up an Argo CD route for us to access the ArgoCD API and the console.

```sh
kubectl apply -f boot/argocd-route.yaml
```

Generate certificates and keys for the https connections.

```sh
./generate-local-certificates.sh
```

You'll need to trust the local CA certificate to remove the warnings in the
browser when you access services. On a mac you can do it with the `security`
command as below.

```sh
sudo security add-trusted-cert -d -r trustRoot \
  -k "/Library/KeyChains/System.keychain"      \
  ~/local/certs/local-ca.crt
```

Register the Argo CD certificate in the cluster for Argo CD to use for the https
traffic.

```sh
kubectl create -n argocd secret tls argocd-server-tls \
  --cert=$HOME/local/certs/argocd-local.crt           \
  --key=$HOME/local/certs/argocd-local.key
```

Install ArgoCD

```sh
helm install argocd argo/argo-cd --namespace argocd --create-namespace
```

For this local stack, we'll use local domain names for simplicity. Register these in `/etc/hosts`

```sh
127.0.0.1 argocd.local
127.0.0.1 grafana.local
```

Now we're ready to log in to Argo CD. Get the password with,

```sh
argocd admin initial-password -n argocd
```

On a mac you get load this straight in the clipboard with

```sh
argocd admin initial-password -n argocd | head -n 1 | pbcopy
```

Log in to Argo CD CLI with username admin and password from above.

```sh
argocd login --username admin argocd.local --grpc-web
```

Change this initial admin password to something secret.

```sh
argocd account update-password
```

You can log in to the ArgoCD console at <https://argocd.local>

### Prepare the configuration for the app of apps

Register this app of app repository

```sh
argocd repo add https://github.com/adaptivekind/app-of-apps.git \
```

Apply the project configuration

```sh
kubectl apply -f boot/project-default.yaml
```

Set Grafana TLS secret for https flows to the Grafana dashboard

```sh
kubectl create -n monitoring secret tls grafana-server-tls \
  --cert=$HOME/local/certs/grafana-local.crt \
  --key=$HOME/local/certs/grafana-local.key
```

Set Grafana password to secret of your choosing

```sh
kubectl create -n monitoring secret generic grafana-password \
  --from-literal=admin-password=$GRAFANA_PASSWORD         \
  --from-literal=admin-user=admin
```

### Install the app of apps

And install app of apps

```sh
argocd app create app-of-apps \
  --sync-policy automated --sync-option Prune=true \
  --repo https://github.com/adaptivekind/app-of-apps.git \
  --path env/k3d \
  --dest-server https://kubernetes.default.svc
```

### Accessing other services

Log in to Grafana at <https://grafana.local/> and register Prometheus and Loki data source

- <http://prometheus-server.monitoring.svc.cluster.local>
- <http://loki.monitoring.svc.cluster.local:3100>

### Clean up

Delete the app

```sh
argocd app delete app-of-apps
helm uninstall argo-cd -n argocd
```

or just delete the cluster

```sh
k3d cluster delete my-cluster
```
