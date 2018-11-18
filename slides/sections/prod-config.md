# Production Readiness - Config

---

<section data-background-image="/img/prod/Slide6.png">

---

A key benefit of containers is that you deploy the same image in every environment, so what's in production is exactly what you tested.

You should package images with a default set of config for running in dev, but you need a way to inject configuration from the environment into the container. 

We'll do this next, extending the web image to read external configuration.

---

The app has a [Web.config]() file, which contains setup that will be the same in every environment, and a [log4net.config]() file and [connectionStrings.config]() file which will change.

The [updated Dockerfile](./docker/prod-config/signup-web/Dockerfile) sets that up using environment variables to inject a different source path for the config files.

The [startup script](./docker/prod-config/signup-web/startup.ps1) checks those variables, and if they're set it overwrites the default config files with the new sources.

---

## Build the new web image

_ Tag the image as `v5`, which includes variable configuration: _

```
cd $env:workshop; `

docker image build `
  -t dwwx/signup-web:v5 `
  -f ./docker/prod-config/signup-web/Dockerfile .
```

---

## Build the new handler image

There's also an [updated Dockerfile for the save handler](), which adds the same config-loading logic.

_ Tag this image as `v3`, which includes variable configuration: _

```
docker image build `
  -t dwwx/save-handler:v3 `
  -f ./docker/prod-config/save-handler/Dockerfile .
```

---

## Run the app with the default config

We'll swap out the configuration files later when we run the app in a Docker swarm cluster. 

For now we need to make sure we haven't broker the app, so we can run it with the default config in the image. The [v8 manifest](./app/v8.yml) just updates to the new images.

_ Update the application: _

```
docker-compose -f .\app\v8.yml up -d
```

---

## Everything should be the same

Check out the app by browsing to the new container, and saving some data:

```
$ip = docker container inspect `
  --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_proxy_1

firefox "http://$ip"
```

> It all works as before, using the default config in the image

---

## Check the logs again

The logs will show that the startup script did run the config logic:

```
docker container logs app_signup-web_1
docker container logs app_signup-save-handler_1
```

> You'll see `STARTUP: Loading config files` - but the source path isn't specified, so the default files are not overwritten

---

## Overwriting default config

Your containerized apps should have default configuration settings bundled in the image, so the team can use `docker container run` without needing any extra setup.

But you need to be able to inject external configuration data into your container at runtime, which is what this pattern does. The config source is configurable, so it can come from the files in the image, or from the container platform.

We'll see that in action shortly.