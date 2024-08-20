apiVersion: v1
kind: Service
metadata:
  name: otel-instrumentation
  namespace: examples
spec:
  ports:
    - name: otel-instrumentation
      port: 3000
      targetPort: 3000
  selector:
    app: example-otel-instrumentation
  type: ClusterIP
