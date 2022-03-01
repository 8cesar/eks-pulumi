#Connect-AzAccount

# Greenflux DEV
Set-AzContext f59b5966-8330-4c21-988a-059972aebf17

# Deploy RG
. "NewAlertResourceGroup.ps1"

# Deploy monitoring workspace
. "monitWorkSpace.ps1"

# Deploy logic app metric alerts
. "logicAppDeployment.ps1"

# Deploy logic app service health
. "logicApp01Deployment.ps1"

# Deploy action group
. "alertDeploy.ps1"

# Deploy ASP alerts
. "appServicePlanAlertDeploy.ps1"