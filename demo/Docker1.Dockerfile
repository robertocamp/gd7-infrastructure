# syntax=docker/dockerfile:1

## Build
FROM golang:1.19-alpine AS build
WORKDIR /app

COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY *.go ./

RUN go mod tidy
# this command builds an image that runs on MAC M1
# RUN go build -o /gd5go

# this cvommand builds an image to run on K8s/EKS
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -o /gd5go


## Deploy
FROM alpine:latest
RUN apk update && apk add --no-cache git ca-certificates && update-ca-certificates

WORKDIR /

COPY --from=build /gd5go /gd5go

# EXPOSE 3000

# USER nonroot:nonroot

CMD ["/gd5go"]