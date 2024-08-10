# App of apps

App of apps for Kubernetes lab environments for experimentation and learning.

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

Log in to Argo CD with username admin and password from above.

```sh
argocd login --username admin argocd.local --grpc-web
```




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
