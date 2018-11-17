# Breaking Out a Reference Data API

---

<section data-background-image="/img/backend/Slide1.png">

---

Docker makes it easy to run features in separate containers, and takes care of communication between containers.

Right now the web application loads reference data direct from the database - that's the list of countries and roles in the dropdown boxes.

We're going to provide that reference data through an API instead.

---

## The reference data API

The new component is a simple REST API. You can browse the [source for the Reference Data API](./src/SignUp.Api.ReferenceData) - there's one controller to fetch countries, and another to fetch roles.

The API uses a new technology stack:

- [ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/?view=aspnetcore-2.1) as a fast, cross-platform alternative to full ASP.NET
- [Dapper](https://github.com/StackExchange/Dapper) as a fast, lightweight ORM

We can use new technologies without impacting the monolith, because this component runs in a separate container.

---

## Build the API

Check out the [Dockerfile](./docker/backend-rest-api/reference-data-api/Dockerfile) for the API. 

It uses the same principle to compile and package the app using containers, but the images use .NET Core running on Nano Server. 

_Build the API image:_

```
docker image build `
  -t dwwx/reference-data-api `
  -f .\docker\backend-rest-api\reference-data-api\Dockerfile .
```

---

## Run the new API

You can run the API on its own, but it needs to connect to SQL Server. 

The image bundles a default database connection string, and you can override it when you run containers with an environment variable.

_Run the API, connecting it to the existing SQL container:_

```
docker container run -d -p 8060:80 --name api `
  -e ConnectionStrings:SignUpDb="Server=signup-db;Database=SignUp;User Id=sa;Password=DockerCon!!!" `
  dwwx/reference-data-api
```

---

## Try it out

The API is available on port `8060` on your Docker host, so you can browse there or direct to the container:

_Get the API container's IP and launch the browser:_

```
$ip = docker container inspect `
  --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' api

firefox "http://$ip/api/countries"
```

> Replace `/countries` with `/roles` to see the other dataset

---

## Upgrade to use the new API

Now we can run the app and have the reference data served by the API. Check out the [v3 manifest](./app/v3.yml) - it adds a service for the REST API.

The manifest also configures the web app to use the API - using Dependency Injection to load a different implementation of the reference data loader.

_Upgrade to v3:_

```
docker-compose -f .\app\v3.yml up -d
```

---

## Check what's running

There are lots of containers running now - the original web app and database, the new homepage and reverse proxy, and the new REST API.

_List all the running containers:_

```
docker container ls
```

---

## Try the new distributed app

The entrypoint is still the proxy listening on port `8020`, so you can browse there or to the container:

```
$ip = docker container inspect `
  --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_proxy_1

firefox "http://$ip"
```

> Now when you click through to the original _Sign Up_ page, the dropdowns are loaded from the API.

---

## Let's just check that

The new REST API writes log entries to the console, which Docker can read from the container. 

The logs will show that the countries and roles controllers have been called - the request came from the web app.

_Check the logs:_

```
docker container logs app_reference-data-api_1
```

---

## And just to be sure

The API uses a different ORM from the main app, but the entity classes are shared, so the reference data codes match up.

Click the _Sign Up!_ button, fill in the form and click _Go!_ to save your details.

_Check the new data is there in the SQL container:_

```
docker container exec app_signup-db_1 powershell `
  "Invoke-SqlCmd -Query 'SELECT * FROM Prospects' -Database SignUp"
```

---

## All good

Now we've got a small, fast REST API providing a reference data service. It's only available to the web app right now, but we could easily make it publicly accessible.

How? Just by adding a new routing rule in the reverse proxy that's already part of our app. It could direct `/api` requests into the API container.

That's something you can try out yourself.

> Hint: the `location` blocks in `nginx.conf` are where you need to start
