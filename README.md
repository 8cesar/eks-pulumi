# GreenFlux.DevOps.Monitoring

In this repository you can find the templates for our Azure alerts, Elastic Watcher configuration, Elastic Heartbeat deployment, and Grafana (and its dashboards).

[[_TOC_]]

Our infrastructure is monitored using:

1. **Azure alerts**: for metrics monitoring (e.g. for the [_CPU Percentage_ metric of the gfx-app-plan-p](https://portal.azure.com/#@greenflux.com/blade/Microsoft_Azure_MonitoringMetrics/Metrics.ReactView/Referer/MetricsExplorer/ResourceId/%2Fsubscriptions%2F58d729f3-33af-4981-84ca-93e537fbdfbc%2FresourceGroups%2Fgfx-app-p%2Fproviders%2FMicrosoft.Web%2Fserverfarms%2Fgfx-app-plan-p/TimeContext/%7B%22relative%22%3A%7B%22duration%22%3A86400000%7D%2C%22showUTCTime%22%3Afalse%2C%22grain%22%3A1%7D/ChartDefinition/%7B%22v2charts%22%3A%5B%7B%22metrics%22%3A%5B%7B%22resourceMetadata%22%3A%7B%22id%22%3A%22%2Fsubscriptions%2F58d729f3-33af-4981-84ca-93e537fbdfbc%2FresourceGroups%2Fgfx-app-p%2Fproviders%2FMicrosoft.Web%2Fserverfarms%2Fgfx-app-plan-p%22%7D%2C%22name%22%3A%22CpuPercentage%22%2C%22aggregationType%22%3A4%2C%22namespace%22%3A%22microsoft.web%2Fserverfarms%22%2C%22metricVisualization%22%3A%7B%22displayName%22%3A%22CPU%20Percentage%22%7D%7D%5D%2C%22title%22%3A%22Avg%20CPU%20Percentage%20for%20gfx-app-plan-p%22%2C%22titleKind%22%3A1%2C%22visualization%22%3A%7B%22chartType%22%3A2%2C%22legendVisualization%22%3A%7B%22isVisible%22%3Atrue%2C%22position%22%3A2%2C%22hideSubtitle%22%3Afalse%7D%2C%22axisVisualization%22%3A%7B%22x%22%3A%7B%22isVisible%22%3Atrue%2C%22axisType%22%3A2%7D%2C%22y%22%3A%7B%22isVisible%22%3Atrue%2C%22axisType%22%3A1%7D%7D%7D%7D%5D%7D) App Service Plan)
2. **Elastic heartbeats**: for pinging API health endpoints
3. **Elastic watches**: for (1) delivering the Elastic Heartbeat data from Elastic to Microsoft Teams and (2) customizable service health checks using Kibana queries
4. **Grafana dashboards**: to get the big picture

## Azure alerts

The alerts are deployed via the [Azure Alerts](https://dev.azure.com/greenflux/Shared/_release?view=mine&_a=releases&definitionId=9) release pipeline.

### Severity levels and actions

| Severity level | Description   | Example                            | Actions                             |
| -------------- | ------------- | ---------------------------------- | ----------------------------------- |
| 0              | Critical      | System is compromised              | Analyze and close alert, create PBI |
| 1              | Error         | Critical components are in trouble | Analyze and close alert, create PBI |
| 2              | Warning       | App service stopped working        | Analyze and close alert             |
| 3              | Informational | Database storage is above 80 %     | Analyze and close alert             |
| 4              | Verbose       | Low-level alert                    | Analyze and close alert             |

See the [Close alerts wiki page](https://dev.azure.com/greenflux/Shared/_wiki/wikis/Shared.wiki/3972/Close-alerts) for info on how to analyze and close alerts.

### Infrastructure

Composed of 5 resources:

1. Alert rules
2. Logic Apps
3. Action Groups
4. API connections
5. Microsoft.Insights activityLogAlerts (for the service health alerts in a resource's activity log)

The Logic Apps do the heavy lifting of parsing the alert to determine the MS Teams channel it should be sent to - either a team channel or the Severity 0/1 team-independent channels. See the [gfx-monitoring-logic-app-metrics](https://portal.azure.com/#@greenflux.com/resource/subscriptions/58d729f3-33af-4981-84ca-93e537fbdfbc/resourceGroups/gfx-monitoring-rg/providers/Microsoft.Logic/workflows/gfx-monitoring-logic-app-metrics/logicApp) and the [gfx-monitoring-logic-app-service-health](https://portal.azure.com/#@greenflux.com/resource/subscriptions/58d729f3-33af-4981-84ca-93e537fbdfbc/resourceGroups/gfx-monitoring-rg/providers/Microsoft.Logic/workflows/gfx-monitoring-logic-app-service-health/logicApp) as an example.

Action groups define a list of actions to execute when an alert is triggered. In our case, there are two defined actions: send alerts to MS Teams and the devops@greenflux.com shared mailbox (as a backup in case Teams goes down).

The API connections are used to connect the Logic Apps to MS Teams.

### Flow

The [Azure Monitor](https://docs.microsoft.com/en-us/azure/azure-monitor/overview) retrieves metrics from Azure resources. Our alert rules poll Azure Monitor (at intervals we specify) for metrics. If the metric for a particular resource meets our selected threshold, the azure alert uses an action group to send the Azure Monitor data to our aforementioned logic apps. The logic apps determine where to send the alert to based on severity, team tag, and alert status. Then, using the API connection to Teams, the logic apps send the alert to the proper Teams channel.

## Elastic heartbeats

The Heartbeat container (defined in [this Dockerfile](heartbeat/Dockerfile)) pings the "beats" defined in [heartbeat.yml](heartbeat/heartbeat.yml) and then displays the results in the [Elastic Heartbeats Dashboard](https://aa72c8caf80943bab3ce3eb7a4bc0530.westeurope.azure.elastic-cloud.com:9243/app/uptime).

The heartbeats are deployed via the [Elastic Heartbeat](https://dev.azure.com/greenflux/Shared/_release?definitionId=51&view=mine&_a=releases) release pipeline.

## Elastic watches

Elastic Watcher is an Elasticsearch feature that you can use to create actions based on conditions, which are periodically evaluated using queries on your data.

We have 2 broad types of watches:

1. Those that retrieve the Elastic Heartbeat data and send it to MS Teams (stored in the [heartbeats folder](Elastic-Watcher/watches/heartbeats/1a01119c-HeartbeatsTeamDevOps.json))
2. Those that use queries to retrieve specific data from Elastic. These are first grouped by environment (`Eneco Prod` and `GreenFlux Prod`) and then by team.

Both types are deployed by the [Elastic Watcher](https://dev.azure.com/greenflux/Shared/_release?definitionId=54&view=mine&_a=releases) release pipeline.

**<font color="red">Important!</font>** Watches use the Lucene query language instead of the KQL, which is the default in the web version of Elastic. Be aware that logical operators (e.g. AND, OR) will need to be CAPITALIZED in the Watch query, otherwise they won't work. This is because Lucene is more strict than KQL.

### Naming convention

All watches must have the name of the form:

`<guid>-<ShortFunctionalNameInCamelCase>.json`

### Template conventions

#### Watch action

All the watch actions must follow this structure:

```json
"actions": {
    "MS_Teams": {
      "webhook": {
        "scheme": "https",
        "method": "POST",
        "host": "greenfluxbv.webhook.office.com",
        "port": 443,
        "path": "$(watcherWebhook<choose-the-one-for-you>)",
        "headers": {
          "Content-Type": "application/json; charset=UTF-8"
        },
        "body": {
          "source": {
            "text": "<h1>Watch <watch-guid> (<Gfx/Ene> Prod)</h1><br>Message"
          }
        }
      }
    }
  }
```

## Grafana dashboards

**NOTE**: Currently in the testing phase.

The dashboards are deployed via the [Grafana](https://dev.azure.com/greenflux/Shared/_release?_a=releases&view=mine&definitionId=49) release pipeline.
