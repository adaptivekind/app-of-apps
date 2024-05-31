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
argocd app create dev \
  --repo https://github.com/adaptivekind/app-of-apps.git \
  --path app-of-apps/dev \
  --dest-server https://kubernetes.default.svc
```

## Clean up

Delete the app

```sh
argocd app delete dev
helm uninstall argo-cd -n argocd
```
