# Switch to Swarm Mode

---

In production environments you will run multiple Docker engines in a cluster and manage services rather than individual containers.

The clustering technology built into Docker is called [swarm mode](https://docs.docker.com/engine/swarm/) - you can easily create a swarm across dozens of machines just by running one command on each.

You can also run a single-node swarm for dev and test environments.

---

## *A note about Kubernetes

The two most popular container orchestrators are Docker swarm and [Kubernetes](https://kubernetes.io/).

Kubernetes has many more integration points than swarm which makes it easier for cloud providers to offer managed Kubernetes services, like [AKS on Azure](https://docs.microsoft.com/en-us/azure/aks/).

** But Kubernetes doesn't support Windows containers**. Yet. Windows support came in beta in 2018 and is [expected to GA in Q1 of 2019](https://twitter.com/EltonStoneman/status/1063408843923836928).

---

## Clean up all containers

We don't need any of the running containers, so we'll remove them all.

```
docker container rm --force `
  $(docker container ls --quiet --all)
```

> The `$()` syntax joins commands together. PowerShell uses the pipe `|` but this syntax also works in Linux shells.

---

## Switch to swarm mode

You can run a single node swarm, which gives you all the functionality of swarm mode but without high availability or the opportunity to scale and use more compute.

_ Switching to swarm mode is easy:_ 

```
docker swarm init
```

> Your RDP session will flicker here. That's to do with a network shift Windows does to support networking in swarm mode.

---

## Now you're a swarm of one

That makes your node a swarm manager. The output is the command you would use to join other nodes to the swarm, but for now we'll stick with a single node.

Shortly we'll deploy the workshop app to the swarm, but before that we'll just explore swarm mode with some simple services.

