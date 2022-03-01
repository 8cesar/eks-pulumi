# Azure Alerts templates

The two folders you see contain two separate types of resources:

- The `alerts` folder contains the templates for the [Azure alert rules](https://portal.azure.com/#blade/Microsoft_Azure_Monitoring/AzureMonitoringBrowseBlade/alertsV2). Each template covers the alert rules for the Azure resource type mentioned in the template's filename.
- The `azure-monitoring-resources` folder contains the templates that are used to deploy the monitoring infrastructure which the Azure alert rules defined above use. The resource types are again mentioned in the filename of each template file.

Note: the logic app templates also include the API connection as a resource because each logic app (in each subscription) is dependent upon the API connection to MS Teams.
