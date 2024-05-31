# App of apps

Bootstrap

```sh
helm install argo-cd argo/argo-cd --namespace argocd --create-namespace
```

Tunnel through to Argo CD

```sh
kubectl port-forward service/argo-cd-argocd-server -n argocd 8080:443 &
```

Get Argo CD password

```sh
argocd admin initial-password -n argocd | head -n 1 | pbcopy
```

Log in to Argo CD with username admin and password from above.

```sh
argocd login localhost:8080
```

Add private repository

```sh
argocd repo add https://github.com/adaptivekind/app-of-apps.git \
  --username x
  --password y
```

Install app of apps

```sh
argocd app create dev \
  --repo https://github.com/adaptivekind/app-of-apps.git \
  --path app-of-apps/dev \
  --dest-server https://kubernetes.default.svc
```
