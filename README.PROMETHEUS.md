
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
3. construct the "prometheus" module under the "infrastructure modules" folder in "infrastructure-live-v4"


## EBS CSI DRIVER
- To improve security and reduce the amount of work, you can manage the Amazon EBS CSI driver as an Amazon EKS add-on
### EBS CSI Prerquisites
- *To see the required platform version:*  `aws eks describe-addon-versions --addon-name aws-ebs-csi-driver`
- An existing AWS Identity and Access Management (IAM) OpenID Connect (OIDC) provider for your cluster
- https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
- **Determine whether you have an existing IAM OIDC provider for your cluster:**
  + `aws eks list-clusters`
  + `oidc_id=$(aws eks describe-cluster --name live-infrastructure-v4-brahmabar --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)`
  + `aws iam list-open-id-connect-providers | grep $oidc_id | cut -d "/" -f4`
    - *this output should be the oidc provider ID for your cluster*

## links
- https://www.youtube.com/watch?v=HOmdYtsB950&t=495s
- https://docs.aws.amazon.com/eks/latest/userguide/prometheus.html
- prometheus data format: https://github.com/prometheus/docs/blob/main/content/docs/instrumenting/exposition_formats.md
- https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html
