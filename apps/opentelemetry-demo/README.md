# OpenTelemetry demo

Feature flags for demo <https://opentelemetry.io/docs/demo/feature-flags/>

```sh
kubectl port-forward -n opentelemetry-demo svc/opentelemetry-demo-flagd 8013:8013
```

Check feature flag

```sh
curl -X POST "http://localhost:8013/flagd.evaluation.v1.Service/ResolveString" \
  -d '{"flagKey":"loadgeneratorFloodHomepage","context":{}}' -H "Content-Type: application/json"
```
