# Deploying Stacks to Docker Swarm

---

Now we're ready to deploy the real application to a real swarm.

---

## But first, tidy up

Exit swarm mode, which will remove your single-node cluster:

```
docker swarm leave -f
```

And remove any running containers:

```
docker container rm -f $(docker container ls -aq)
```

---

## Plan the production swarm

It's time to buddy up! 
    
Your workshop VM is in the same virtual network as your neighbour's, so you can create a swarm between you:

- pick another person (or 2 or 3) to work with
- choose who's going to be the manager and who will be the worker(s)

> If you don't like the sound of this, it's no big deal. You can continue with the single-node swarm on your own VM.

---

## Initialize the swarm

> This part is for the **manager**

On the manager's VM, get the machine's internal IP address:

```
ipconfig
```

The internal address will start with `10.0.0`. Use it to create your swarm:

```
docker swarm init `
  --listen-addr <ip-address> `
  --advertise-addr <ip-address>
```

---

## Share the join token

The output of `docker swarm init` is a `swarm join` command which you need to share with your buddies. 

> You can use the Google sheet for this. Or memorize the token...

---

## Join the swarm

> This part is for the **worker(s)**

Run the `docker swarm join` command which your manager has shared with you. 

Now you can sit back for a while. In swarm mode all the work gets scheduled on the manager node, so you'll be a passenger for the next few steps.

---

## Check the swarm

> This part is for the **manager**

Check you have all the expected nodes in the swarm:

```
docker node ls
```

The output will list all the nodes in the swarm. You should have one manager and multiple workers - and they should all be in the `ready` state.

---

## Compose files in swarm mode

You deploy apps to swarm using Docker Compose files. There are some attributes which only apply to swarm mode (like the `deploy` section), and some which are ignored in swarm mode (like `depends_on`).

You can combine multiple compose files together to make a single stack file. That's useful for keeping the core solution in one compose file like [v9-compose.yml](./app/v9-compose.yml), and adding environment-specific overrides in other files like [v9-prod.yml](./app/v9-prod.yml).

---

## Generate the application manifest

> Everyone can do this part

```
cd $env:workshop

docker-compose `
  -f .\app\v9-compose.yml `
  -f .\app\v9-prod.yml config > docker-stack.yml
```

> The generated `docker-stack.yml` file contains the merged contents, ready for deployment. In a real production app you would use [Docker secrets](https://docs.docker.com/engine/swarm/secrets/) and not plaintext passwords in environment variables.

---

## Deploy the application as a stack

> This part is for the **manager** 

Deploy the stack:

```
docker stack deploy -c docker-stack.yml signup
```

> Docker creates all the resources in the stack: an overlay network, and a set of services. It will deploy service tasks across the swarm, so you should see containers running on many nodes.

---

## Managing the stack

Application stacks are first-class object in swarm mode. You can see the stacks which are running, and the services which are in the stack:

```
docker stack ls

docker stack ps signup
```

> You can navigate around the services, and make changes to the deployment. But your stack file is the source of truth, which lets you work declaratively.

---

## High availability and scale in swarm mode

The swarm keeps your app running at the desired service level. You can manualy remove containers from worker nodes, have workers leave the swarm, or even stop the worker VMs - Docker will keep the app running.

You can add more nodes to the swarm just by running the `swarm join` command, and immediately add capacity.
