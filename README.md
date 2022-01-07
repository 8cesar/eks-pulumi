# GreenFlux.DevOps.Monitoring

In this repository you can find the templates for our Azure Alerts, Elastic Watchers, Elastic Heartbeats, and Grafana (and its dashboards).

Our infrastructure is monitored using:

1. **Azure Alerts**: for metrics monitoring (e.g. for the [_CPU Percentage_ metric of the gfx-app-plan-p](https://portal.azure.com/#@greenflux.com/blade/Microsoft_Azure_MonitoringMetrics/Metrics.ReactView/Referer/MetricsExplorer/ResourceId/%2Fsubscriptions%2F58d729f3-33af-4981-84ca-93e537fbdfbc%2FresourceGroups%2Fgfx-app-p%2Fproviders%2FMicrosoft.Web%2Fserverfarms%2Fgfx-app-plan-p/TimeContext/%7B%22relative%22%3A%7B%22duration%22%3A86400000%7D%2C%22showUTCTime%22%3Afalse%2C%22grain%22%3A1%7D/ChartDefinition/%7B%22v2charts%22%3A%5B%7B%22metrics%22%3A%5B%7B%22resourceMetadata%22%3A%7B%22id%22%3A%22%2Fsubscriptions%2F58d729f3-33af-4981-84ca-93e537fbdfbc%2FresourceGroups%2Fgfx-app-p%2Fproviders%2FMicrosoft.Web%2Fserverfarms%2Fgfx-app-plan-p%22%7D%2C%22name%22%3A%22CpuPercentage%22%2C%22aggregationType%22%3A4%2C%22namespace%22%3A%22microsoft.web%2Fserverfarms%22%2C%22metricVisualization%22%3A%7B%22displayName%22%3A%22CPU%20Percentage%22%7D%7D%5D%2C%22title%22%3A%22Avg%20CPU%20Percentage%20for%20gfx-app-plan-p%22%2C%22titleKind%22%3A1%2C%22visualization%22%3A%7B%22chartType%22%3A2%2C%22legendVisualization%22%3A%7B%22isVisible%22%3Atrue%2C%22position%22%3A2%2C%22hideSubtitle%22%3Afalse%7D%2C%22axisVisualization%22%3A%7B%22x%22%3A%7B%22isVisible%22%3Atrue%2C%22axisType%22%3A2%7D%2C%22y%22%3A%7B%22isVisible%22%3Atrue%2C%22axisType%22%3A1%7D%7D%7D%7D%5D%7D) App Service Plan)
2. **Elastic Watchers**: for customizable service health checks
3. **Elastic Heartbeats**: for pinging API health endpoints
4. **Grafana dashboards**: to get the big picture

The reason we use watchers and heartbeats is because the heartbeats only check our services (and display the status in the [Elatic Heartbeats Dashboard](https://aa72c8caf80943bab3ce3eb7a4bc0530.westeurope.azure.elastic-cloud.com:9243/app/uptime)). It is the goal of the watchers to inform us (through MS Teams notifications) about their health.

## Azure Alerts

The alerts are deployed via the [Azure Alerts](https://dev.azure.com/greenflux/Shared/_release?view=mine&_a=releases&definitionId=9) release pipeline.

### Severity levels and actions

| Severity level | Description       | Example                            | Actions                             |
|----------------|-------------------|------------------------------------|-------------------------------------|
| 0              | Major severity    | System is compromised              | Analyze and close alert, create PBI |
| 1              | Critical severity | Critical components are in trouble | Analyze and close alert, create PBI |
| 2              | High severity     | App service stopped working        | Analyze and close alert             |
| 3              | Medium severity   | Database storage is above 80 %     | Analyze and close alert             |
| 4              | Low severity      | Low-level alert                    | Analyze and close alert             |

See the [Close alerts wiki page](https://dev.azure.com/greenflux/Shared/_wiki/wikis/Shared.wiki/3972/Close-alerts) for info on how to analyze and close alerts.

### Infrastructure

Composed of 5 resources:

1. Alert rules
2. Logic Apps
3. Action groups
4. API connections
5. Microsoft.Insights activityLogAlerts (for the service health alerts in a resource's activity log)

The Logic Apps do the heavy lifting of parsing the alert to determine the MS Teams channel it should be sent to - either a team channel or the Severity 0/1 team-independent channels.

Action groups define a list of actions to execute when an alert is triggered. In our case, there is only one defined action: send alerts to MS Teams and the devops@greenflux.com shared mailbox (as a backup in case Teams goes down).

The API connections are used to connect the Logic Apps to MS Teams.

### Flow

The [Azure Monitor](https://docs.microsoft.com/en-us/azure/azure-monitor/overview) retrieves metrics from Azure resources. Our alert rules poll Azure Monitor (at intervals we specify) for metrics. If the metric for a particular resource meets our selected threshold, the azure alert uses an action group to send the Azure Monitor data to our aforementioned logic apps. The logic apps determine where to send the alert to based on severity, team tag, and alert status. Then, using the API connection to Teams, the logic apps send the alert to the proper Teams channel.

<!-- #### Logic Apps in-depth

We use 3 logic apps: 2 for metrics and 1 for service health alerts in a resource's activity log.

The reason we use 2 logic apps for metric alerts and not 1 is a legacy one that will be soon restructured: we hit the [nesting depth](https://docs.microsoft.com/en-us/azure/logic-apps/logic-apps-limits-and-config?tabs=azure-portal#workflow-definition-limits) with the first logic app, so our team created a second one to extend our monitoring capabilities. The second Logic App currently deals with the Charge Assist and Charge Station alerts.
-->

## Elastic Watchers

WORK IN PROGRESS
<!-- We have 2 types of watchers:

1. URL endpoints - index starting with 0 (e.g. _[001PROD-gsop-gfx-ocpicdrservice.json]()_)
2. Query watchers - index starting with 1 (e.g _[101GfxProdOcpiPublisherPost-CdrsSuccessfullyPublishedLessThan1.json]()_)

They are both deployed by the [Alerts - Elastic Watchers](https://dev.azure.com/greenflux/Shared/_release?view=mine&_a=releases&definitionId=11) release pipeline.

You can find the Watchers in [Elastic](https://aa72c8caf80943bab3ce3eb7a4bc0530.westeurope.azure.elastic-cloud.com:9243/app/management/insightsAndAlerting/watcher/watches). -->

## Elastic Heartbeats

The Heartbeat container (defined in [this Dockerfile](heartbeat/Dockerfile)) pings the "beats" defined in [heartbeat.yml](heartbeat/heartbeat.yml) and then displays the results in the [Elastic Heartbeats Dashboard](https://aa72c8caf80943bab3ce3eb7a4bc0530.westeurope.azure.elastic-cloud.com:9243/app/uptime).

The heartbeats are deployed via the [Elastic Heartbeat](https://dev.azure.com/greenflux/Shared/_release?definitionId=51&view=mine&_a=releases) release pipeline.

## Grafana dashboards

**NOTE**: Currently in the testing phase.

The dashboards are deployed via the [Grafana](https://dev.azure.com/greenflux/Shared/_release?_a=releases&view=mine&definitionId=49) release pipeline.
