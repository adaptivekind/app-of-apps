# Examples app

```sh
kubectl port-forward -n examples svc/example-otel-instrumentation 3000:3000
curl http://localhost:3000/hello
```

To enable OTEL debug logging

```sh
kubectl -n examples edit deployments.apps example-otel-instrumentation
```

And set OTEL_LOG_LEVEL to debug

```yaml
        - name: OTEL_LOG_LEVEL
          value: debug
```
