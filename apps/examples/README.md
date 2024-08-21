# Examples app

```sh
kubectl port-forward -n examples svc/otel-instrumentation 3000:3000
curl http://localhost:3000/hello
```
