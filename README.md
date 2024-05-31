# App of apps

## Bootstrap of local

Generate a local CA so we can create locally trusted certificates

```sh
openssl genrsa -out ca.key 2048
openssl req -new -x509 -subj "/C=EN/CN=My CA" -key ca.key -out ca.cert.pem
```

And trust locally

```sh
sudo security add-trusted-cert -d -r trustRoot \
  -k "/Library/Keychains/System.keychain" ca.cert.pem
```

## Bootstrap of cluster

Bootstrap with k3d cluster.

```sh
k3d cluster create my-cluster -p "443:443@loadbalancer"
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd --namespace argocd --create-namespace
```

Create and set Argo CD certificate

```sh
openssl req -subj '/CN=argocd.dev' \
  -new -newkey rsa:2048 -sha256 -noenc -x509 \
  -addext "subjectAltName = DNS:argocd.dev" \
  -CA ca.cert.pem -CAkey ca.key \
  -keyout key.pem -out cert.pem
kubectl create -n argocd secret tls argocd-server-tls \
  --cert=./cert.pem \
  --key=./key.pem
```

Set up Argo CD route

```sh
kubectl apply -f app-of-apps/boot/argocd-route.yaml
```

Add the following to `/etc/local`

```sh
127.0.0.1 argocd.dev
```

Test the certificate on this route.

```sh
echo | openssl s_client -showcerts -connect argocd.local:443 2>/dev/null
curl -v https://argocd.local
```

Get Argo CD password

```sh
argocd admin initial-password -n argocd | head -n 1 | pbcopy
```

Log in to Argo CD with username admin and password from above.

```sh
argocd login argocd.local --grpc-web
```

Change admin password

```sh
argocd account update-password
```

Check Argo CD configuration at `~/.config/argocd/config`.

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
  --repo https://github.com/adaptivekind/app-of-apps.git \
  --path app-of-apps/k3d \
  --dest-server https://kubernetes.default.svc
```

## Clean up

Delete the app

```sh
argocd app delete app-of-apps-dev
helm uninstall argo-cd -n argocd
```
