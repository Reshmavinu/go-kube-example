   # Example for deploying a simple Go application to Kubernetes

Go source is in main.go. It is a simple http server which returns the http request headers.

# Requirements

Install go. For example `sudo snap install go --classic` for Ubuntu.

Install ko-build: https://github.com/ko-build/ko

You need a running kubernetes (or minikube) and `kubectl`.

In this text `k` is an alias for `kubectl`

# Develop locally (without containers)

This example shows how to deploy a go application to Kubernetes. But don't do
this during your inner development loop (edit-compile-test). 

Tools like [tilt](https://tilt.dev/), [devspace](https://github.com/loft-sh/devspace) or [Skaffold](https://skaffold.dev/) can help
you to easily run your code in Kubernetes during development. But it is more easy if you don't run your
code in Kubernetes during development. 


# Config

The file `dot-envrc-example` contains environment variables which are
needed. I use [direnv](https://direnv.net/) to automatically enable them. Choose
your favorite way.

Modify the ko-image URL in deployment.yaml, if you forked the repo.

```
ko apply -f deployment.yaml
```

Above command will build a container image of the Go code. Then the image will be pushed to the container registry
which is defined in KO_DOCKER_REPO. Then it will use deployment.yaml, replace the ko:// URL to the URL of
the new image, and then create the deployment via your current `kubectl` config.

If you do this for the first time, it will fail, since the image is not public yet.

Then navigate to the URL of the image (just add https:// before ghcr.io).

Then "Change package visibility" (in the box "Danger Zone") to public.

Execute above `ko apply` command again, and then the deployment will be available.

# Deployment

You can use k8slens, k9s or kubectl to have a look at
your [deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

```
k port-forward deployments/go-kube-example-deployment 8080:8080
```

Now you can see the running Go code. It shows you the http request headers:

```
curl http://localhost:8080/
```

Up to now the port 8080 of our application is only easily accessible
for other containers which run in this pod. To make the port available
to other pods in the cluster we need a service.

# Service

To make the app available for other pods,
we need to create a [service](https://kubernetes.io/docs/concepts/services-networking/service/)

```
k apply -f service.yaml
```

Start a temporary [netshoot](https://github.com/nicolaka/netshoot) container:

```
k run -it --rm --image=nicolaka/netshoot foo

foo> curl http://go-kube-example-service:8080/

foo> nslookup go-kube-example-service

Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   go-kube-example-service.default.svc.cluster.local
Address: 10.103.211.158
```

# Ingress

Up to now the service is only available inside the cluster.



Now we make the service available on the internet via an [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/).

```
k apply -f ingress.yaml
```

```
❯ k get ingress go-kube-example-ingress 

NAME                      CLASS   HOSTS   ADDRESS                               PORTS   AGE
go-kube-example-ingress   nginx   *       167.235.216.87,2a01:4f8:c01e:23f::1   80      23h
```

--> http://167.235.216.87

https://console.hetzner.cloud/

# Related

This example is part of my talk [Kubernetes, Golang & Cluster-API](https://docs.google.com/presentation/d/1VG0XtUK48aJ7FITC9A7vuiI9h8YLRBgqHq7oqxFiofY/edit#slide=id.g16c3fde7cd8_0_79)

[Me, Working-out-Load](//github.com/guettli/wol)

