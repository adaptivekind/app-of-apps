# OpenTelemetry

Collector installed as operator.

Configuration documentation at
<https://opentelemetry.io/docs/collector/configuration/>

## Debugging

To switch on verbose collector logging

```sh
kubectl -n monitoring edit OpenTelemetryCollector opentelemetry-collector
```

and set

```yaml
debug:
  verbosity: detailed
```
