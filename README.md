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
####  why use "this" ???
- provider and backend will be configured in the "infrastructure-live" folder
- if there is no more descriptive name available or if the resource module creates only 1 resource of this type, call the resource "this"

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
- `cd infrastructure-live-v2/dev/vpc`
- 
### infrastructure-live-v3
- use terragrunt
- `cd infrastructure-live-v3/dev/vpc`
- `terragrunt init`
- terragrunt lets you tear down multiple environments from the root module:
  + `terragrunt run-all destroy`
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

#### terragrunt backend
- terragrunt generates backend and profile configurations in its own directory
- 
### infrastructure-live-v4
#### subnet design
- 10.0.0.0/16 --> /24 subnets
####  kubernetes nodes design
- `aws ec2 describe-instance-types --query 'InstanceTypes[].InstanceType'`
- the kuernetes nodes will need multiple IAM policies attached to an IAM role
- the initial build will use **managed instances groups**
#### IRSA
- most of the time you will want to use irsa in conjunction with an OpenID Connect provider to grant access to the AWS API
- this design creates a boolean flag called `enable_irsa` that we can use to create this provider on-demand
- *once we have retrieved the EKS TLS certificate, the OIDC provider can be created*
- `aws sts get-caller-identity`
- aws iam list-open-id-connect-providers

#### tree
├── eks
│   └── terragrunt.hcl
├── env.hcl
├── kubernetes-addons
│   └── terragrunt.hcl
└── vpc
    └── terragrunt.hcl

#### deployment commands
- `cd gd7-infrastructure/infrastructure-live-v4/dev`
- `terragrunt run-all init`
- `terragrunt run-all plan`
- `terragrunt run-all apply`


#### setting up kubectl: AWS CLI
- https://awscli.amazonaws.com/v2/documentation/api/latest/reference/eks/update-kubeconfig.html
- This command constructs a configuration with prepopulated server and certificate authority data values for a specified cluster
- You can specify an IAM role ARN with the –role-arn option to use for authentication when you issue kubectl commands
- Otherwise, the IAM entity in your default AWS CLI or SDK credential chain is used
- You can view your default AWS CLI or SDK identity by running the aws sts get-caller-identity command
- Amazon EKS uses the aws eks get-token command (available in version 1.16.156 or later of the AWS CLI) or the *AWS IAM Authenticator for Kubernetes* with kubectl for cluster authentication
- **get cluster ARN from console:** arn:aws:eks:us-east-2:240195868935:cluster/live-infrastructure-v4-brahmabar
- If you have installed the AWS CLI on your system, then by default the AWS IAM Authenticator for Kubernetes uses the same credentials that are returned with the following command: `aws sts get-caller-identity`
- `aws eks update-kubeconfig --name live-infrastructure-v4-brahmabar --region us-east-2 --dry-run`
- if you are satisfied with the output of the dry run, run the command without the dry run, to install this context.
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
- terragrunt will generate the Helm provider
- we CANNOT pass variables from the EKS provider to the `terragrunt.hcl` file for Kubernetes Addons
- to initialize the Helm provider, you need to generate a temporary token
#### deployment
```
/Users/robert/Documents/CODE/gd7-infrastructure/infrastructure-live-v4/dev
❯ tree
.
├── eks
│   └── terragrunt.hcl
├── env.hcl
├── kubernetes-addons
│   └── terragrunt.hcl
└── vpc
    └── terragrunt.hcl
```
- `terragrunt run-all plan`
- `terragrunt run-all apply`

#### EKS cluster checkout
- **initial cluster checkout**
- validate that helm was installed correctly: `helm list -A`
- `kubectl get pods -n kube-system`
- example of the initial pods that should be running:
```
NAME                                                 READY   STATUS    RESTARTS   AGE
autoscaler-aws-cluster-autoscaler-7457696899-2928w   1/1     Running   0          5m55s
aws-node-d7d4r                                       1/1     Running   0          5h17m
coredns-6dff7847bf-cwgmn                             1/1     Running   0          5h20m
coredns-6dff7847bf-wkb8v                             1/1     Running   0          5h20m
kube-proxy-d84tq                                     1/1     Running   0          5h17m
```
- `k logs autoscaler-aws-cluster-autoscaler-7457696899-2928w -n kube-system` 
- `k nodes -o wide`
#### authenticating helm provider
- we *cannot* pass variables from the eks modules into ``infrastructure-live-v4/dev/kubernetes-addons
- the cluster-autoscaler helm chart is a generated by the module and can only take in variables provided by the module itself
#### depoly a test app
- **Verify the available resources on your EKS worker nodes**
  + `kubectl describe node <node_name>`
- Review the resource requests and limits specified in your nginx deployment
  + *If the requested memory exceeds the available resources on your nodes, the pods won't be scheduled*
- **modify the test app deployment yaml**  to more appropriately match the resources available in your cluster
- `watch -t kubectl get pods -n default`
- simple nginx *deployment* with (4) replicas
- k apply -f deployment.yml
## links
- https://github.com/antonputra/tutorials
- assume role with web identity: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html#cli-configure-role-oidc
- TF AWS provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#cli-configure-quickstart-precedence
- TF Getting Started with AWS: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-build
- https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html
- https://github.com/kubernetes/autoscaler/tree/57e54f6b93b170ec3d0674300441738274627aa4/charts/cluster-autoscaler-chart#aws---using-auto-discovery-of-tagged-instance-groups

#### deployment
- `terragrunt run-all plan`  
- `terragrunt run-all apply`

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

## links
https://awscli.amazonaws.com/v2/documentation/api/latest/reference/eks/update-kubeconfig.html
https://www.youtube.com/watch?v=yduHaOj3XMg&t=2859s
https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
https://awscli.amazonaws.com/v2/documentation/api/latest/reference/eks/update-kubeconfig.html
https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/