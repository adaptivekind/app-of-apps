# Homepage

This homepage app requires configuration from a `configmap` named
`homepage-configmap` in the namespace `homepage`. This sets the domain for the
bookmarks and is set via a `configmap` because it is environment dependent.
Homepage uses this environment variable to parameterise the place holders in the
configuration values. For example:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: homepage-configmap
  namespace: homepage
data:
  HOMEPAGE_VAR_LAB_DOMAIN: test.com
```

This can be deployed from an external process, for example Ansible playbook,
e.g.
[https://github.com/adaptivekind/lab/blob/main/roles/homepage/tasks/main.yaml](homepage
role), or it can be deployed from an git resource deployed by ArgoCD outside of
this app.
