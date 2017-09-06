# Part 4 - Preparing for Production with Instrumentation

The app is ready to be promoted to production now, but we'll have problems when we run at scale. For prodcution load you may run dozens of web containers and message handler containers, and currently the only instruementation we have is text log entries. In Docker all containers look the same, whether they're running ASP.NET WebForms apps or .NET Core console apps - and you can expose metrics from containers to give you a single dashboard for the performance of your app.

In this section we'll add metrics to the solution using Prometheus -a popular open-source monitoring server, and Grafana - a dashboard that plugs into Prometheus. We'll run those new components in Docker Windows containers too.

## Steps

* [1. Record custom metrics in the message handlers](#1)
* [2. Expose IIS metrics from the web application](#2)
* [3. Run the solution with Prometheus and Grafana](#3)

## <a name="1"></a>Step 1. Record custom metrics in the message handlers

TODO - uncomment metrics code

Rebuild handlers:

```
cd $env:workshop

docker image build --tag $env:dockerId/signup-index-handler:2 -f part-3\index-handler\Dockerfile .

docker image build --tag $env:dockerId/signup-save-handler:2 -f part-3\save-handler\Dockerfile .
```

## <a name="2"></a>Step 2. Expose IIS metrics from the web application

Rebuild web app:

```
cd $env:workshop

docker image build --tag $env:dockerId/signup-web:1.4 -f part-4\web-1.4\Dockerfile .
```

## <a name="3"></a>Step 3. Run the solution with Prometheus and Grafana

Build Prometheus:

```
cd "$env:workshop\part-4\prometheus"

docker image build --tag $env:dockerId/signup-prometheus .
```

Build Grafana:

```
cd "$env:workshop\part-4\grafana"

docker image build --tag $env:dockerId/signup-grafana .
```

Run:

```
cd "$env:workshop\app"

docker-compose -f .\docker-compose-1.6.yml up -d
```

Test:

```
$ip = docker container inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_signup-web_1
firefox "http://$ip"
```

Check Prometheus:

```
$ip = docker container inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_prometheus_1
firefox "http://$($ip):9090"
```

Check Grafana:

```
$ip = docker container inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' app_grafana_1
firefox "http://$($ip):3000"
```

Login with admin/admin

- Add data source
-- Name Sign Up
-- Type Prometheus
-- Url http://prometheus:9090
-- Access proxy

Dashboards...Import