<a name="procedure"></a>
## procedure
1. clone example app
  +  `git clone https://github.com/olliefr/docker-gs-ping`
2. remove go.mod and go.sum from project root so that you can create your own (good practice)
3. initialize the project as a go modules project:  `go mod init github.com/<PATH TO YOUR GITHUB PROJECT>`
4. build code: https://github.com/antonputra/tutorials/tree/main/lessons/154/myapp
5. local smoke test the app: `cd /Users/robert/Documents/CODE/gd7-infrastructure/app`
  + `go mod tidy`
  + `go run main.go`
  + connect to local host: http://127.0.0.1:8080/api/devices
6. build the image: `docker build --tag myapp:v0.1  .`
7. package the image for AWS: `docker tag myapp:v0.1 240195868935.dkr.ecr.us-east-2.amazonaws.com/myapp:v0.1`
  + example:  `docker tag docker-gs-ping:multistage 240195868935.dkr.ecr.us-east-2.amazonaws.com/docker-gs-ping:multistage`
8. upload to ECR
  + `aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 240195868935.dkr.ecr.us-east-2.amazonaws.com`
  + `docker push 240195868935.dkr.ecr.us-east-2.amazonaws.com/myapp:v0.1`
9. get the image URI from the AWS Console (go to ECR):  240195868935.dkr.ecr.us-east-2.amazonaws.com/prometheus-demo-app:latest
10. update the deployment YML with the image uri
11. deploy:  `k apply -f deploy`
### troubleshooting the installation
- log message: 
- `docker image inspect prometheus-demo-app:v0.1`
## Docker
- Docker images can be inherited from other images. 
- Therefore, instead of creating our own base image from scratch, we can use the official Go image that already has all necessary tools and libraries to compile and run a Go application.
- To make things easier when running the rest of our commands, let’s create a directory inside the image that we are building. - - - This also instructs Docker to use this directory as the default destination for all subsequent commands
- Usually the very first thing you do once you’ve downloaded a project written in Go is to install the modules necessary to compile it. 
- **Note, that the base image has the toolchain already, but our source code is not in it yet.**
- before we can run go mod download inside our image, we need to get our go.mod and go.sum files copied into it. 
- We use the COPY command to do this.
- when setup correctly in the Dockerfile, the `go mod download` command works the same as if we were running go locally on our machine, but this time these Go modules will be installed into a directory inside the image.

So before we can run go mod download inside our image, we need to get our go.mod and go.sum files copied into it. We use the COPY command to do this
## build Docker file (other examples in the "demo" folder)
```
# syntax=docker/dockerfile:1

FROM golang:1.19

# Set destination for COPY
WORKDIR /app

# Download Go modules
COPY go.mod go.sum ./
RUN go mod download

# Copy the source code. Note the slash at the end, as explained in
# https://docs.docker.com/engine/reference/builder/#copy
COPY *.go ./

# Build
RUN CGO_ENABLED=0 GOOS=linux go build -o /docker-gs-ping

# Optional:
# To bind to a TCP port, runtime parameters must be supplied to the docker command.
# But we can document in the Dockerfile what ports
# the application is going to listen on by default.
# https://docs.docker.com/engine/reference/builder/#expose
EXPOSE 8080

# Run
CMD ["/docker-gs-ping"]
```
- `docker build --tag docker-gs-ping .`
- Because we had not specified a custom tag when we built our image, Docker assumed that the tag would be latest, which is a special value
- `docker image ls`
- **note the size of the image**

## Docker tags
- An image name is made up of slash-separated name components. 
- Name components may contain lowercase letters, digits and separators. 
- A separator is defined as a period, one or two underscores, or one or more dashes. 
- A name component may not start or end with a separator.
- An image is made up of a manifest and a list of layers. 
- **In simple terms, a “tag” points to a combination of these artifacts**
- `docker image tag docker-gs-ping:latest docker-gs-ping:v1.0`
- The Docker tag command creates a new tag for the image. 
- *It does not create a new image*

## multi-stage build
- a multi-stage build can carry over the artifacts from one build stage into another
- every build stage can be instantiated from a different base image.

## Run the Docker image as a container
- A container is a normal operating system process except that this process is isolated and has its own file system, its own networking, and its own isolated process tree separate from the host
- `docker run docker-gs-ping:multistage`
- curl http://localhost:8080/
  + curl: (7) Failed to connect to localhost port 8080: Connection refused
- Our curl command failed because the connection to our server was refused. 
- Meaning that we were not able to connect to localhost on port 8080. 
- This is expected because our container is running in isolation which includes networking. 
- Let’s stop the container and restart with port 8080 published on our local network.
  + To publish a port for our container, we’ll use the --publish flag (-p for short) 
  + `docker run --publish 8080:8080 docker-gs-ping`

## upload image to ECR
1. Tag your Docker image with the ECR repository URI. 
  + `aws sts get-caller-identity`
  + the repository URI follows the pattern `<account-id>.dkr.ecr.<region>.amazonaws.com/<repository-name>`. 
  + Replace <account-id> with your AWS account ID, <region> with the desired AWS region, and <repository-name> with the name of the repository in ECR
    + `docker tag docker-gs-ping:multistage 240195868935.dkr.ecr.us-east-2.amazonaws.com/docker-gs-ping:multistage`
2. log into the ECR Repository vi CLI
  + `aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account-id>.dkr.ecr.<region>.amazonaws.com`
  + `aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 240195868935.dkr.ecr.us-east-2.amazonaws.com`
  + Login Succeeded
3. push the image: `docker push 240195868935.dkr.ecr.us-east-2.amazonaws.com/docker-gs-ping:multistage`

## Links
https://docs.docker.com/language/golang/build-images/
