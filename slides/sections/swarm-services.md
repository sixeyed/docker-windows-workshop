# Work with Swarm Services

---

Services are the unit of deployment in swarm mode. You don't run containers, you create services which Docker deploys as containers on the swarm.

---

## Creating services

You can create services imperatively with the command line, or declaratively using compose files.

_Create a simple service which pings itself:_

```
docker service create `
  --entrypoint "ping -t localhost" `
  --name pinger microsoft/nanoserver
```

> The declarative approach is better. We'll use that for the final app.

---

## Managing services

Services are a first-class resource in swarm mode. You can list services, list the containers running the service (called "tasks"), and check the logs for the service:

```
docker service ls

docker service ps pinger

docker service logs pinger
```

---

## Scaling services

Services are an abstraction over containers. You don't care which node is running the containers, you just specify a service level, and the swarm maintains it. 

_Scale up the service by running more replicas:_

```
docker service update --replicas=3 pinger
```

> Scaling up the service adds more task containers. This is a single node swarm so they will all be running on your VM, but it's the same command for a swarm of any size.

---

## Check the new service tasks

You can see the extra tasks, and their logs:

```
docker service ps pinger

docker service logs pinger
```

---

## Updating services

Swarm mode supports automatic updates. You upgrade your app by updating the service with a new image. 

This is a zero-downtime update for services with multiple replicas, because Docker replaces one container at a time, so your app stays available.

_ Update the image for the `pinger` service: _

```
docker service update --image microsoft/windowsservercore pinger
```

> This replaces the container image. The start command is still the same, so when new tasks start, they will run the original command. 

---

## Rolling service updates

Check the task list for the service, and you can see the rollout happens gradually. 

Some containers will be using the original definition with Nano Server, and some will be using Windows Server Core:

```
docker service ps pinger
```

> Docker ensures new tasks are healthy before carrying on with the rollout. You have [fine control](TODO) over how the rollout happens.

---

## Inspecting swarm services

The service definition is stored in the swarm, securely peristeted among the manager nodes. 

_ Check the service details: _

```
docker service inspect pinger
```

---

## Rollback the service update

Swarm saves the service definition, so you can easily rollback an update if the new version of the app has a problem. 

You don't need to use a compose file, because the swarm has all the details.

```
docker service update --rollback pinger
```

---

## Rolling rollbacks

The rollback happens in the same way, with task containers being replaced with versions using the original definition:

```
docker service ps pinger
```

And you can see the logs are still collected from all the containers:

```
docker service logs pinger
```

---

## Removing the service

You can stop and remove all the task containers just by removing the service:

```
docker service rm pinger
```

---

## Services in HA swarms

Production swarm clusters typically have 3 manager nodes for high availability, and as many worker nodes as you need for your workloads.

One swarm can be a cluster of hundreds of worker nodes, and you manage your services in exactly the same way for any size of swarm.

Docker takes care of service levels, so if a server goes down and takes containers with it, Docker spins up replacements on other nodes.
