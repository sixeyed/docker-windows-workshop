# Breaking Out a Reference Data API

Docker makes it easy to run features in separate containers, and takes care of communication between containers.

Right now the web application loads reference data direct from the database - that's the list of countries and roles in the dropdown boxes.

We're going to provide that reference data through an API instead.

---

## The reference data API

The new component is a simple REST API. You can browse the [source for the Reference Data API](./signup/src/SignUp.Api.ReferenceData) - there's one controller to fetch countries, and another to fetch roles.

The API uses a new technology stack:

- ASP.NET Core as a fast, cross-platform alternative to full ASP.NET
- [Dapper]() as a fast, lightweight ORM

We can use new technologies without impacting the monolith, because this component runs in a separate container.

---

## Build the API

Check out the [Dockerfile]() for the API. 

It uses the same principle to compile and package the app using containers, but the images use .NET Core running on Nano Server. 

.exercise[
    - Build the API image:

    ```
    docker image build `
      -t dwwx/reference-data-api `
      -f .\backend-rest-api\reference-data-api\Dockerfile .
    ```]

---

## Run the new API

You can run the API on its own, but it needs to connect to SQL Server. 

The image bundles a default database connection string, but you can override it when you run containers with an environment variable.

.exercise[
    - Run the API, connecting it to the existing SQL container:

    ```
    docker container run -d -p 8060:80 --name api `
      -e ConnectionStrings:SignUpDb="Server=signup-db;Database=SignUp;User Id=sa;Password=DockerCon!!!" `
      dwwx/reference-data-api
    ```]
---

## Try it out

The API is available on port `8060` on your Docker host, so you can browse there or direct to the container:

.exercise[
    - Get the API container's IP and launch the browser:

    ```
    $ip = docker container inspect `
      --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' api

    firefox "http://$ip/api/countries"
    ```]

> Replace `/countries` with `/roles` to see the other dataset

---

## Upgrade to use the new API

Now we can run the app and have the reference data served by the API. Check out the [v3 manifest](./app/v3.yml) - it adds a services for the REST API.

The manifest also configures the web app to use the API. This has to be a change to the monolith - in this case using Dependency Injection to load a different implementation of the reference data loader.

.exercise[
    - Upgrade to v3:

    ```
    docker-compose -f .\app\v3.yml up -d
    ```] 
---

## Try the new distributed app

The entrypoint is still the proxy listening on port `8020`, so you can browse there or to the container:

.exercise[
    ```
    $ip = docker container inspect `
      --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_proxy_1

    firefox "http://$ip"
    ```]

> Now when you click through to the original _Sign Up_ page, the dropdowns are loaded from the API.

---

## Let's just check that

The new REST API writes log entries to the console, which Docker can read from the container. 

The logs will show that the countries and roles controllers have been called - the request came from the web app.

.exercise[
    - Check the logs:

    ```
    docker container logs app_reference-data-api_1
    ```] 

---

## And just to be sure

The API uses a different ORM from the main app, but the entity classes are shared, so the reference data codes match up.

Click the _Sign Up!_ button, fill in the form and click _Go!_ to save your details.

.exercise[
    - Check the new data is there in the SQL container:

    ```
    docker container exec app_signup-db_1 powershell `
      "Invoke-SqlCmd -Query 'SELECT * FROM Prospects' -Database SignUp"
    ```]

---

## All good

Now we've got a small, fast REST API providing a reference data service. It's only available to the web app right now, but we could easily make it publicly accessible.

How? Just by adding a new routing rule in the reverse proxy that's already part of our app. It could direct `/api` requests into the API container.

That's something you can try out yourself.

> Hint: `nginx.conf` is where you need to start