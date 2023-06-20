
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

## Why install the Prometheus Operator?
- the Prometheus Operator can help you create and discover objects in Kubernetes
- eg: the ServiceMonitor object is automatically converted into *native Prometheus configuration*
- *hot reload* of Prometheus when new ServiceMonitors are added
- Prometheus custom resources provided by the Operator also allow you to configure Prometheus-specific parameters such as retention and global scrape interval

### Prometheus CRDs
- **monitoring.coreos.com**
- monitoring.coreos.com refers to the Custom Resource Definitions (CRDs) provided by the Prometheus Operator
### PodMonitor vs ServiceMonitor

## Prometheus Deployment (Cluster Build is Complete --see README.md)
1. `cd infrastructure-modules/prometheus`
2. `k apply -f namespace.yml`
  + the `monitoring: prometheus` label is used by the Operator to select objects such as ServiceMonitors and PodMonitors

3. construct the "prometheus" module under the "infrastructure modules" folder in "infrastructure-live-v4"
  + https://github.com/antonputra/tutorials/tree/main/lessons/154/terraform
4. CRDS: `k apply --server-side -f prometheus-operator/crds`
```
❯ k apply --server-side -f prometheus-operator/crds
customresourcedefinition.apiextensions.k8s.io/alertmanagerconfigs.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/alertmanagerconfigs.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/podmonitors.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/probes.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/prometheuses.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/prometheusrules.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/servicemonitors.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/thanosrulers.monitoring.coreos.com serverside-applied
❯ k get crds
NAME                                         CREATED AT
alertmanagerconfigs.monitoring.coreos.com    2023-06-17T00:21:00Z
eniconfigs.crd.k8s.amazonaws.com             2023-06-11T20:42:59Z
podmonitors.monitoring.coreos.com            2023-06-17T00:21:02Z
probes.monitoring.coreos.com                 2023-06-17T00:21:02Z
prometheuses.monitoring.coreos.com           2023-06-17T00:21:02Z
prometheusrules.monitoring.coreos.com        2023-06-17T00:21:03Z
securitygrouppolicies.vpcresources.k8s.aws   2023-06-11T20:43:02Z
servicemonitors.monitoring.coreos.com        2023-06-17T00:21:03Z
thanosrulers.monitoring.coreos.com           2023-06-17T00:21:03Z
```
5. create RBAC policy for CRDs ; there are "view" and "edit" roles
- `k apply -f prometheus-operator/rbac`
- `kubectl get clusterroles --no-headers -o custom-columns="NAME:.metadata.name"`
  + *This command will list only the names of the ClusterRoles without any headers or additional details*
- Note that you need appropriate permissions and access to the EKS cluster to perform these operations. 
  + *Make sure you have the necessary IAM roles and credentials to access the cluster and retrieve the ClusterRole information*
6. **Prometheus Operator deployment**
  - dedicated service account
  - cluster role to get access to all the CRDs in all the namespaces
  - cluster role binding to bind the service account for the operator with the cluster role
  - deployment will provision a kubelet service to monitor persistent volumes
  - `k apply -f prometheus-operator/deployment`
  - `k get pods -n monitoring`
```
❯ k apply -f prometheus-operator/deployment
serviceaccount/prometheus-operator created
clusterrole.rbac.authorization.k8s.io/prometheus-operator created
clusterrolebinding.rbac.authorization.k8s.io/prometheus-operator created
deployment.apps/prometheus-operator created
```
> Prometheus Operator will also create a service that you can use with the ingress or simply port-forwarded to the local host:
- `k get service -n monitoring`
- `k port-forward svc/prometheus-operated 9090 -n monitoring`
7. **Prometheus Deployment**
  - get (ARN) of Prometheus  AWS IAM role: `aws iam get-role --role-name prometheus --query 'Role.Arn' --output text`
8. `k apply -f prometheus`
❯ k apply -f prometheus
```
serviceaccount/prometheus created
clusterrole.rbac.authorization.k8s.io/prometheus created
clusterrolebinding.rbac.authorization.k8s.io/prometheus created
secret/additional-scrape-configs created
```
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


## ClusterRoles
> In AWS EKS (Elastic Kubernetes Service), a ClusterRole is a Kubernetes resource that defines a set of permissions or policies for controlling access to cluster-wide resources. 
- ClusterRoles are used to grant permissions to perform certain operations within an EKS cluster, such as managing nodes, services, namespaces, or other cluster-level resources.
- The purpose of a ClusterRole is to define a set of rules that determine what actions a user or a group of users can perform within the cluster. 
- These rules are based on specific verbs (e.g., get, create, delete) and are associated with specific API resources (e.g., pods, services, namespaces).

> ClusterRoles are different from regular Roles in Kubernetes because they are not bound to a specific namespace
- They provide a way to grant permissions across the entire EKS cluster, allowing more fine-grained control over cluster-level resources.
- Once a ClusterRole is defined, it can be associated with users, groups, or service accounts using ClusterRoleBindings or RoleBindings. 
- This association determines which users or entities have the permissions defined by the ClusterRole.
- By using ClusterRoles, you can enforce security policies and control access to various resources within your EKS cluster, ensuring that only authorized entities have the necessary privileges to perform specific operations

### ClusterRoles and AWS IAM (IRSA)
> When used in an AWS EKS cluster, ClusterRoles interact with the AWS IAM service through the AWS IAM Roles for Service Accounts feature
- This integration allows you to associate IAM roles with Kubernetes service accounts, enabling you to leverage AWS IAM's fine-grained access control mechanisms within your EKS cluster
#### Here's how ClusterRoles interact with AWS IAM in an EKS cluster:
1. IAM Role Creation: This IAM role defines the AWS permissions that the Kubernetes service account will assume.
2. Kubernetes Service Account: Within your EKS cluster, you create a Kubernetes service account or use an existing one 
  + A service account represents an identity used by pods or processes running within the cluster
3. Annotating the Service Account: **To associate the IAM role with the Kubernetes service account, you need to annotate the service account with the ARN (Amazon Resource Name) of the IAM role**
  + This annotation provides the linkage between the Kubernetes service account and the IAM role.
4. IAM Role and ClusterRoleBinding: In addition to annotating the service account, you also create a ClusterRoleBinding
  + The ClusterRoleBinding associates the ClusterRole with the Kubernetes service account
  + It specifies that the defined ClusterRole applies to the service account and grants the corresponding permissions within the EKS cluster.
5. Permission Enforcement: 
  + When a pod or process associated with the Kubernetes service account attempts to access AWS resources using an AWS SDK or CLI, *it authenticates via the IAM role associated with the service account*
  + The IAM role's permissions are then enforced by the AWS IAM service, ensuring that only authorized actions are allowed.
> In the context of AWS EKS IAM roles for Service Accounts (IRSA), the ClusterRoleBinding object plays a crucial role in associating Kubernetes service accounts with ClusterRoles, allowing you to grant permissions to those service accounts within the EKS cluster.

## links
- https://www.youtube.com/watch?v=HOmdYtsB950&t=495s
- https://docs.aws.amazon.com/eks/latest/userguide/prometheus.html
- prometheus data format: https://github.com/prometheus/docs/blob/main/content/docs/instrumenting/exposition_formats.md
- https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html


## troubleshooting
- k get pods -n monitoring
- 