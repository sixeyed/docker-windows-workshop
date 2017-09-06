# Part 7 - Docker Swarm - Native Clustering for Production



## Steps

* [1. Switch to Swarm Mode](#1)
* [2. Deploy Services](#2)
* [3. Configure a stack YAML file](#3)
* [4. Deploy the stack](#4)


## <a name="1"></a>Step 1. Switch to Swarm Mode

```
docker swarm init --listen-addr 127.0.0.1 --advertise-addr 127.0.0.1
```

create service:

```
docker service create --entrypoint "ping -t localhost" --name pinger microsoft/nanoserver

docker service ls

docker service ps pinger
```

scale up:

```
docker service update --replicas=5 pinger

docker service ps pinger

docker service logs pinger
```


update:

```
docker service update --image microsoft/windowsservercore pinger

docker service inspect pinger

docker service ps pinger
```

rollback:

```
docker service update --rollback pinger

docker service ps pinger
```

remove:

```
docker service rm pinger
```

## <a name="2"></a>Step 2. Deploy App Services

```
cd $env:workshop\part-7

.\create-services.ps1
```

Clear up

```
docker service rm $(docker service ls -q)
```


## <a name="1"></a>Step 3. Deploy the stack

build the stack file:

```
cd $env:workshop\part-7

docker-compose -f docker-compose.yml -f docker-compose.test.yml config > docker-stack.yml
```

deploy the stack:

```
cd $env:workshop\part-7

docker stack deploy -c docker-stack.yml signup
```

check

```
docker stack ls

docker stack ps signup
```

test

## Next Steps

- try a lab
- follow @EltonStoneman on Twitter
- try out Image2Docker
- buy a ticket for DockerCon