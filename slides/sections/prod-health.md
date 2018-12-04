# Production Readiness - Health

---

<section data-background-image="/img/prod/Slide8.png">

---

Healthchecks are the final piece to making your old apps behave like new apps when they're running in containers.

The healthecheck should exercise key logic in your app and make sure it's functioning properly. You can do that by adding a dedicated `/health` API endpoint to your app.

We'll use the other option, bundling a healthcheck utility in the Docker image.

---

## The health check utility

The utility is another .NET Framework console app. It just makes an HTTP GET to the app running locally in the container.

In the [Program class](./src/Utilities.HealthCheck/Program.cs) the utility expects the site to return a `200 OK` response, within 200 milliseconds. If it doesn't do that, the health check returns an exit code of `1`, meaning failure.

---

## Packaging the health checker

There's another new stage in the [updated Dockerfile](./docker/prod-health/signup-web/Dockerfile) - it builds the health check utility from source. 

Then the output is copied into the final Docker image, alongside the original ASP.NET app and the dependency checker.

There's also a `HEALTHCHECK` instruction, which tells Docker to run the utility every 30 seconds. Docker records the result of executing each healthcheck.

---

## Build the new image

_ Tag the image as `v7`, which includes the health check: _

```
cd $env:workshop; `

docker image build `
  -t dwwx/signup-web:v7 `
  -f ./docker/prod-health/signup-web/Dockerfile .
```

---

## Upgrade the app

The [v10 manifest](./app/v10.yml) uses the upgraded web app, and it specifies a different schedule for the healthcheck.

_ Update the application: _

```
docker-compose -f .\app\v10.yml up -d
```

---

## Browse to the app

The app still works in the same way:

```
$ip = docker container inspect `
  --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_proxy_1

firefox "http://$ip/app"
```

---

## Check container health

Containers with a healthcheck report their current status.

_ You should see that the web app is showing as `Up` and `healthy`: _

```
docker container list
```

And you can see the result of the executing healthchecks by inspecting the container:

```
docker container inspect app_signup-web_1
```

---


## Self-healing applications

A healthcheck lets the container platform test if your application is working correctly. If it's not the platform can kill an unhealthy container and start a replacement.

This is perfect for old apps which have known issues - if they're known to crash and stop responding, the healthcheck means Docker will repair the app with minimal downtime and with no manual intervention.

Production readiness with these patterns means our legacy ASP.NET WebForms app will behave just like a cloud-native app when we deploy it to a Docker cluster.