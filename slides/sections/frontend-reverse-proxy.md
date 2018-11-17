# Splitting Out the Application Homepage

---

<section data-background-image="/img/frontend/Slide2.png">

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

The homepage is available on port `8040` on your Docker host, so you can browse there or direct to the container:

_Get the homepage container's IP and launch the browser:_

```
$ip = docker container inspect `
  --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' home

firefox "http://$ip"
```

---

## Almost there

The new homepage looks good, starts quickly and is packaged in a small Nano Server image.

It doesn't work on its own though - click _Sign Up_ and you'll get an error.

To use the new homepage **without changing the original app** we can run a reverse proxy in another container.

---

## The reverse proxy

We're using [Nginx](http://nginx.org/en/). All requests come to Nginx, and it proxies content from the homepage container or the original app container, based on the requested route.

Nginx can do a lot more than that - in the [nginx.conf configuration file](./docker/frontend-reverse-proxy/reverse-proxy/conf/nginx.conf) we're setting up caching, and you can also use Nginx for SSL termination.

_Build the reverse proxy image:_

```
docker image build `
  -t dwwx/reverse-proxy `
  -f .\docker\frontend-reverse-proxy\reverse-proxy\Dockerfile .
```

---

## Upgrade to use the new homepage

Check out the [v2 manifest](./app/v2.yml) - it adds services for the homepage and the proxy. 

Only the proxy has `ports` specified. It's the public entrypoint to the app, the other containers can access each other, but the outside world can't get to them.

_Upgrade to v2:_

```
docker-compose -f .\app\v2.yml up -d
```

> Compose compares the running state to the desired state in the manifest and starts new containers. 

---

## Check out the new integrated app

The reverse proxy is published to port `8020`, so you can browse there or to the new Nginx container:

```
$ip = docker container inspect `
  --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_proxy_1

firefox "http://$ip"
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

## All good

So now we have a reverse proxy which lets us break UI features out of the monolith. 

We're running a new homepage with Vue, but we could easily use a CMS for the homepage by running Umbraco in a container - or we could replace the Sign Up form with a separate component using Blazor.

These small units can be independently deployed, scaled and managed. That makes it easy to release front end changes without regression testing the whole monolith.
