# gd7-infrastructure
Amazon EKS cluster from scratch using Terraform and maybe even Terragrunt
## Terraform AWS Authentication
### Terraform Version
- `t version`
- `brew upgrade terraform`
### AWS Credentials
- Configuration for the AWS Provider can be derived from several sources, which are applied in the following order:
  1. Parameters in the provider configuration
  2. Environment variables
  3. Shared credentials files
  4. Shared configuration files
  5. Container credentials
  6. Instance profile credentials and region

- The AWS Provider supports assuming an **IAM role**, either in the provider configuration block parameter `assume_role` or in a named profile.
- The AWS Provider supports assuming an IAM role using web identity federation and OpenID Connect (OIDC). This can be configured either using environment variables or in a named profile

#### configuring environment variables for TF
- `echo $AWS_ACCESS_KEY_ID`: if this is not setup, proceed to "step 1" below
- cd ~/.aws
- you should have a `config`  and a `credentials` file
- `config` will have your profile information
- `credentials` will have your secret and access key
- configure environment:
  1. edit ~/.zshrc
  2. add environment variables:
```
export AWS_ACCESS_KEY_ID="************"
export AWS_SECRET_ACCESS_KEY="************"
export AWS_REGION="us-east-2"
```
## Terraform variables
- When you declare variables in the root module of your configuration, you can set their values using CLI options and environment variables. 
- When you declare them in child modules, the calling module should pass values in the module block
## infrastructure notes
- *for the NAT gateway, we must explicitly depend on the Internet gateway*
- public load-balancers get public IP addresses and are used to expose your service to the Internet
- a NAT gateway provides Internet access to private subnets
- *the NAT gateway must be placed in a public subnet with a NAT gateway*
- a "private route table" can enable the private subnets to reach the internet via the NAT gateway

### infrastructure-live-v1
- this was created without modules
- topology:
```
├── LICENSE
├── README.md
└── infrastructure-live-v1
    └── dev
        └── vpc
            ├── 0-provider.tf
            ├── 1-vpc.tf
            ├── 2-igw.tf
            ├── 3-subnets.tf
            ├── 4-nat.tf
            ├── 5-routes.tf
            └── 6-outputs.tf
```
- intialize infrastructure-live-v1
- `cd infrastructure-live-v1/dev/vpc`
- `t init`
- `t plan`

### infrastructure-live-v2
- this will use a modules design
- module directory: **infrastructure-modules**
- topology:
```
├── infrastructure-live-v2
│   ├── dev
│   │   └── vpc
│   │       ├── main.tf
│   │       └── outputs.tf
│   └── staging
└── infrastructure-modules
    └── vpc
        ├── 0-versions.tf
        ├── 1-vpc.tf
        ├── 2-igw.tf
        ├── 3-subnets.tf
        ├── 4-nat.tf
        ├── 5-routes.tf
        ├── 6-outputs.tf
        └── 7-variables.tf
```

### infrastructure-live-v3
- use terragrunt
- `cd infrastructure-live-v3/dev/vpc`
- `terragrunt init`
- terragrunt lets you tear down multiple environments from the root module:
- `terragrunt run-all destroy`
- topology:
```
├── dev
│   └── vpc
│       └── terragrunt.hcl
├── staging
│   └── vpc
│       └── terragrunt.hcl
└── terragrunt.hcl
```
- deployment sequence:
  * `terragrunt init`
  * `terragrunt apply`
  * `terragrunt run-all destroy`

### infrastructure-live-v4
- `cd gd7-infrastructure/infrastructure-live-v4/dev`
- `terragrunt run-all init`
- `terragrunt run-all plan`
- `terragrunt run-all apply`

### setting up kubectl
- Amazon EKS uses the aws eks get-token command (available in version 1.16.156 or later of the AWS CLI) or the *AWS IAM Authenticator for Kubernetes* with kubectl for cluster authentication. 
- If you have installed the AWS CLI on your system, then by default the AWS IAM Authenticator for Kubernetes uses the same credentials that are returned with the following command: `aws sts get-caller-identity`
- `aws eks update-kubeconfig --name dev-demo --region us-east-2`
- output: Added new context arn:aws:eks:us-east-2:<ACCOUNT#>:cluster/dev-demo to /Users/<USER>/.kube/config
#### kubernetes addons
- **cluster autoscaler** needs access to the AWS API to discover autoscaling groups and to adjust the desired size setting on them
- we will use IAM for Service Accounts (IRSA)
- our IRSA solution is deployed in the kube-system namespace
- kubernetes service account name: `cluster-autoscaler`
- use the eks name as a prefix for the IAM role
- in the Helm chart for the cluster autoscaler, the *namespace* must match the namespace for the IAM role
- in the Helm chart for the cluster autoscaler, the *service account* must match the service account  for the IAM role
- helm chart for cluster autoscaler will need the openID connecto provider ARN from the EKS cluster
- **initial cluster checkout**
- `terragrunt run-all apply`
- `helm list -A`
- `kubectl get pods -n kube-system`
- `k logs autoscaler-aws-cluster-autoscaler-69847d7574-lhn5l -n kube-system` 

#### authenticating helm provider
- we *cannot* pass variables from the eks modules into ``infrastructure-live-v4/dev/kubernetes-addons
- the cluster-autoscaler helm chart is a generated by the module and can only take in variables provided by the module itself
#### depoly a test app
- `watch -t kubectl get pods -n default`
- simple nginx *deployment* with (4) replicas
- k apply -f demo/deployment.yml
## links
- https://github.com/antonputra/tutorials
- assume role with web identity: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html#cli-configure-role-oidc
- TF AWS provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#cli-configure-quickstart-precedence
- TF Getting Started with AWS: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-build
- https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html
- https://github.com/kubernetes/autoscaler/tree/57e54f6b93b170ec3d0674300441738274627aa4/charts/cluster-autoscaler-chart#aws---using-auto-discovery-of-tagged-instance-groups


## work sessions: clean this up after
- FRI: https://www.youtube.com/watch?v=yduHaOj3XMg 10:00

## work sessions:
- TUE:  video 41:00
  * infrastructure-live-v4
  * deployed eks cluster, but no access
  * pickup at 41:00 to re-deploy from infrastructure-live-v4 and get access configured

```
Apply complete! Resources: 10 added, 0 changed, 0 destroyed.

Outputs:

eks_name = "dev-demo"
openid_provider_arn = "arn:aws:iam::240195868935:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/EBEB5FB66F823389CF62EE0999BFEED9"
```

## work sessions:
- SAT 19-May
- deployed `infrastructure-live-v4/dev`
- performed initial cluster checkout
- deployed demo app (nginx)
### issue
- autoscaler did not deploy (4) replicas:
- `k get pods -n default`
```
NAME                     READY   STATUS    RESTARTS   AGE
nginx-697fc7c95b-6fnjj   1/1     Running   0          9m1s
nginx-697fc7c95b-q8krj   0/1     Pending   0          9m1s
nginx-697fc7c95b-rpqrk   1/1     Running   0          9m1s
nginx-697fc7c95b-wcvrv   1/1     Running   0          9m1s
```
- need to troubleshoot
- **cannot go further until autoscaler is validated**
- delete deployment, teardown cluster
- k delete deployment -n default
- video:  45:00