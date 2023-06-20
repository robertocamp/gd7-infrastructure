## deploy simple app to test Prometheus
1. build code
  + `go mod init github.com/robertocamp/gd7-infrastructure/app`
2.  build Docker image: `docker build --tag app:v0.1 .`
3. upload Docker image to ECR
4. deploy image to EKS