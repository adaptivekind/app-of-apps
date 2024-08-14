# Alternative setups

## ArgoCD private repository

Install direnv for local environment variable handling

```sh
brew install direnv
```

Create a GitHub app with access to your repository. Create an `.envrc` file in
current folder and set GitHub app details.

```sh
export GITHUB_APP_ID=1234
export GITHUB_APP_INSTALLATION_ID=5678
export GITHUB_APP_PRIVATE_KEY_PATH=my-key.pem
```

In project directory:

```sh
direnv allow
```

Register this private repository with Argo CD installation.

```sh
argocd repo add https://github.com/adaptivekind/app-of-apps.git \
  --github-app-id $GITHUB_APP_ID \
  --github-app-installation-id $GITHUB_APP_INSTALLATION_ID \
  --github-app-private-key-path $GITHUB_APP_PRIVATE_KEY_PATH
```

Register credentials for ghcr repository

```sh
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: ghcr
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  name: ghcr
  type: helm
  enableOCI: "true"
  url: ghcr.io/grafana/helm-charts/grafana-operator
  password: $GITHUB_PAT
  username: $GITHUB_USERNAME
  ForceHttpBasicAuth: "true"
EOF
```

## Verify Certificate

Verify ArgoCD cert against CA

```sh
openssl verify -CAfile \
<(kubectl -n certificate-authority get secret root-secret -o jsonpath='{.data.ca\.crt}' | base64 -d) \
<(kubectl -n argocd get secret argocd-server-tls -o jsonpath='{.data.tls\.crt}' | base64 -d)
```

