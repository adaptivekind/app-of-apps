# App of apps

ArgoCD GitOps managed app of apps for Kubernetes lab environments for
experimentation and learning. This app of apps provide git source of desired
resources to for deployment into a Kubernetes cluster of your choosing. The
README below covers how to spin this up quickly on a local machine.

ArgoCD automatically applies updates to the resources in the git repository to
the Kubernetes cluster.

## Local k3d cluster

## Install Docker, k3d, Helm and ArgoCD

Get started with a local Kubernetes cluster using k3d. First install and startup
[Docker](https://docs.docker.com/engine/install/). Then install k3d as described
in the [k3d documentation](https://k3d.io/). For example with
[Homebrew](https://brew.sh/):

```sh
brew install k3d
```

Create the cluster with the load balancer listening on port 433 for https
access to the services.

```sh
k3d cluster create my-cluster -p "443:443@loadbalancer"
```

We'll use [Helm](https://helm.sh/) to install ArgoCD in our cluster and use the
[argocd](https://argo-cd.readthedocs.io/en/stable/getting_started/#2-download-argo-cd-cli)
command line interface for convenience. For example, with Homebrew install with:

```sh
brew install helm argocd
```

Add the Helm repository for ArgoCD which hosts the Helm charts we need.

```sh
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

Install ArgoCD

```sh
helm install argocd argo/argo-cd --namespace argocd --create-namespace \
  --values boot/argocd-values.yaml
```

Apply an application from the env folder, for example:

```sh
kubectl apply -f env/base.yaml
```

Get the CA certificate

```sh
kubectl get secret -n cert-manager root-secret -o jsonpath="{.data.ca\.crt}" |
  base64 -d > /tmp/lab-cluster-ca.crt

And trust it

```sh
sudo security add-trusted-cert -d -r trustRoot \
  -k "/Library/KeyChains/System.keychain"      \
  /tmp/lab-cluster-ca.crt
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

Log in to Argo CD CLI with username admin and password from above.

```sh
argocd login --username admin argocd.local
```

Change this initial admin password to something secret.

```sh
argocd account update-password
```

You can log in to the ArgoCD console at <https://argocd.local>

### Prepare the configuration for the app of apps

Install `direnv`

```sh
brew install direnv
```

Set `GRAFANA_ADMIN_PASSWORD` in `.envrc` file 

```txt
export GRAFANA_ADMIN_PASSWORD=super-secret
```

Set the Grafana secret

```sh
kubectl create -n monitoring secret generic grafana-password \
  --from-literal=admin-password=$GRAFANA_ADMIN_PASSWORD      \
  --from-literal=admin-user=admin
```

### Install the app of apps

And install app of apps

```sh
argocd app create app-of-apps                            \
  --sync-policy automated --sync-option Prune=true       \
  --repo https://github.com/adaptivekind/app-of-apps.git \
  --path env/k3d                                         \
  --dest-server https://kubernetes.default.svc
```

All the apps should now spin up in the Kubernetes cluster. View the status and
troubleshoot in the [ArgoCD dashboard](https://argocd.local).

### Accessing deployed services

Log in to Grafana at <https://grafana.local/>.

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
