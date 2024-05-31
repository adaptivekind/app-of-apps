# App of apps

Bootstrap with k3d cluster.

```sh
k3d cluster create my-cluster -p "80:80@loadbalancer"
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd --namespace argocd --create-namespace \
  --set "configs.params.server\.insecure=true"
```

Set up Argo CD route

```sh
kubectl apply -f app-of-apps/boot/argocd-route.yaml
```

Add the following to `/etc/local`

```sh
127.0.0.1 argocd.local
```

Get Argo CD password

```sh
argocd admin initial-password -n argocd | head -n 1 | pbcopy
```

Log in to Argo CD with username admin and password from above.

```sh
argocd login argocd.local
```

Register private repository with Argo CD installation.

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
kubectl apply -f app-of-apps/projects/project-dev.yaml
```

Check repo and projects set up

```sh
argocd repo list
argocd proj list
```

Install app of apps

```sh
argocd app create app-of-apps-dev \
  --repo https://github.com/adaptivekind/app-of-apps.git \
  --path app-of-apps/dev \
  --dest-server https://kubernetes.default.svc
```

## Clean up

Delete the app

```sh
argocd app delete app-of-apps-dev
helm uninstall argo-cd -n argocd
```
