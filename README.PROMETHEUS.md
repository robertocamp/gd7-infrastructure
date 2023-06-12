
# Prometheus and EKS
This topic explains how to deploy Prometheus and some of the ways that you can use it to view and analyze what your cluster is doing.

## control plane metrics with Prometheus
- The Kubernetes API server exposes a number of metrics that are useful for monitoring and analysis
- These metrics are exposed internally through a metrics endpoint that refers to the /metrics HTTP API
- Like other endpoints, this endpoint is exposed on the Amazon EKS control plane

## viewing raw eks metrics
- `kubectl get --raw /metrics`
- This raw output returns verbatim what the API server exposes
- These metrics are represented in a Prometheus format
- This format allows the API server to expose different metrics broken down by line
- Each line includes a metric name, tags, and a value: `metric_name{"tag"="value"[,...]} value`

## what is Prometheus?
- While the Kubernetes API server */metrics* endpoint endpoint is useful if you are looking for a specific metric
- you typically want to analyze these metrics over time
- To do this, you can deploy **Prometheus** into your cluster. Prometheus is a monitoring and time series database that scrapes exposed endpoints and aggregates data, allowing you to filter, graph, and query the results.

> Prometheus is a monitoring and time series database that scrapes exposed endpoints and aggregates data, allowing you to filter, graph, and query the results

## Prometheus Deployment
1. `cd prometheus-operator`
2. `k apply -f namespace.yml`

## links
- https://docs.aws.amazon.com/eks/latest/userguide/prometheus.html
- prometheus data format: https://github.com/prometheus/docs/blob/main/content/docs/instrumenting/exposition_formats.md

