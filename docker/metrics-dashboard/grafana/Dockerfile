# escape=`
FROM dockersamples/aspnet-monitoring-grafana:5.2.1-windowsservercore-ltsc2019
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

COPY .\docker\metrics-dashboard\grafana\datasource-prometheus.yaml \grafana\conf\provisioning\datasources\
COPY .\docker\metrics-dashboard\grafana\dashboard-provider.yaml \grafana\conf\provisioning\dashboards\
COPY .\docker\metrics-dashboard\grafana\signup-dashboard.json \var\lib\grafana\dashboards\

COPY  .\docker\metrics-dashboard\grafana\init.ps1 .
RUN .\init.ps1 