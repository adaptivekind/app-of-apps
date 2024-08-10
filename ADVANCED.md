# Registering a private git repository with ArgoCD

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

Register this private repository with Argo CD installation.

```sh
argocd repo add https://github.com/adaptivekind/app-of-apps.git \
  --github-app-id $GITHUB_APP_ID \
  --github-app-installation-id $GITHUB_APP_INSTALLATION_ID \
  --github-app-private-key-path $GITHUB_APP_PRIVATE_KEY_PATH
```

