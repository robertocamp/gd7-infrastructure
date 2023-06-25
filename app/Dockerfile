# syntax=docker/dockerfile:1

##
## Build the application from source
##

FROM golang:1.19 AS build-stage

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY *.go ./

# RUN CGO_ENABLED=0 GOOS=linux go build -o /docker-gs-ping
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /app main.go
##
## Run the tests in the container
##

FROM build-stage AS run-test-stage
# add test files later
#RUN go test -v ./...

##
## Deploy the application binary into a lean image
##

FROM alpine:latest
RUN apk update && apk add --no-cache git ca-certificates && update-ca-certificates

# WORKDIR /

COPY --from=build-stage /app /app

EXPOSE 8080

# not sure what this is for
# USER nonroot:nonroot

ENTRYPOINT ["/app"]