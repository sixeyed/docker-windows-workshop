# Splitting Out the Application Homepage

---

Monoliths can run in containers just fine. But they aren't modern apps - they're just old apps running in containers.

You can rebuild a monolith into microservices, but that's a long-term project. 

We'll do it incrementally instead, by breaking features out of the monolith and running them in separate containers - starting with the app's homepage

---

## The new application homepage

Check out [the new homepage](./docker/frontend-reverse-proxy/homepage/index.html). It's a static HTML site which uses Vue.js - it will run in its own container, so it can use a different technology stack from the main app.

The [Dockerfile](./docker/frontend-reverse-proxy/homepage/Dockerfile) is really simple - it just copies the HTML content into an IIS image.

_Build the homepage image:_

```
docker image build `
  -t dwwx/homepage `
  -f .\docker\frontend-reverse-proxy\homepage\Dockerfile .
```

---

## Run the new homepage

You can run the homepage on its own - great for fast iterating through changes. 

_Run the homepage:_

```
docker container run -d -p 8040:80 --name home dwwx/homepage
```

---

## Try it out

The homepage is available on port `8040` on your Docker host, so you can browse there or direct to `localhost`:


```
firefox http://localhost:8040
```

---

## Almost there

The new homepage looks good, starts quickly and is packaged in a small Windows Server Core image.

It doesn't work on its own though - click _Sign Up_ and you'll get an error.

To use the new homepage **without changing the original app** we can run a reverse proxy in another container.

---

## The reverse proxy

We're using [Traefik](http://traefik.io), which is really easy to integrate with Docker. All requests come to Traefik, and it fetches content from the homepage container or the original app container, based on the requested route.

Traefik can do a lot more than that - SSL termination, load-balancing and sticky sessions. The [official Traefik image on Docker Hub](https://docs.traefik.io/#the-official-docker-image) doesn't have a Windows Server 2019 version, so we'll build our own.

_Build the reverse proxy image:_

```
docker image build `
  -t dwwx/reverse-proxy `
  -f .\docker\frontend-reverse-proxy\reverse-proxy\Dockerfile .
```

---

## Upgrade to the new homepage

Check out the [v2 manifest](./app/v2.yml) - it adds services for the homepage and the proxy. The routing rules for the proxy are specified using [labels](https://docs.traefik.io/basics/#matchers).

Only the proxy has `ports` specified. It's the public entrypoint to the app, the other containers can access each other, but the outside world can't get to them.

_Upgrade to v2:_

```
docker-compose -f .\app\v2.yml up -d
```

> Compose compares the running state to the desired state in the manifest and starts new containers. 

---

## Check out the new integrated app

The reverse proxy is published to port `8020` so you can just refresh your browser window, or run:

```
firefox http://localhost:8020
```

> Now you can click through to the original _Sign Up_ page.

---

## And just to be sure

Check nothing's broken. 

Click the _Sign Up!_ button, fill in the form and click _Go!_ to save your details.

_Check the new data is there in the SQL container:_

```
docker container exec app_signup-db_1 powershell `
  "Invoke-SqlCmd -Query 'SELECT * FROM Prospects' -Database SignUp"
```

---

## How does Traefik know where to route requests?

The Docker Engine has an API you can use to manage and query containers. Traefik uses that to find containers with Traefik labels, and it uses the label values to build the routing table.

Traefik is running inside a container, talking to the Docker Engine it is running on to find out about other containers. The [command]() option in the [v2.yml]() compose file sets up the connection:

```
 command: --docker --docker.endpoint=npipe:////./pipe/docker_engine --api
```

> That endpoint is a [named pipe]() for private communication on the machine

---

## All good

So now we have a reverse proxy which lets us break UI features out of the monolith. 

We're running a new homepage with Vue, but we could easily use a CMS for the homepage by running Umbraco in a container - or we could replace the Sign Up form with a separate component using Blazor.

These small units can be independently deployed, scaled and managed. That makes it easy to release front end changes without regression testing the whole monolith.
