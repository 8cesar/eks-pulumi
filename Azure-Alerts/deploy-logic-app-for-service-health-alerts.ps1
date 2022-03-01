 param(

[String]$parameterfile,

[String]$JsonFile, 

[String]$AzureResourceGroup = 'LogicApp02',

$processname = 'parameters'

)
$templatefile = '\templates\azure-monitoring-resources\logicAppServiceHealthAlerts.json'
$parameterfile = '\parameters\'+$JsonFile

$scriptPath = split-path -parent $MyInvocation.MyCommand.Path

$tempFilePath = $scriptPath + "$templatefile"

$scriptPath = split-path -parent $MyInvocation.MyCommand.Path

$paramFilePath = $scriptPath + "$parameterfile"


$deploymentName=$AzureResourceGroup 

$data =@()

$data += Get-Content -Raw -path $paramFilePath  | ConvertFrom-Json 



$arraydata=$data.$processname.$AzureResourceGroup

$resourceGroup=$arraydata.resourceGroup

$logicAppName=$arraydata.logicAppName

$ConnectionName=$arraydata.ConnectionName

$ConnectionDisplayName=$arraydata.ConnectionDisplayName

$ConnectiontokenTenantId=$arraydata.ConnectiontokenTenantId


 New-AzResourceGroupDeployment -name $deploymentName -ResourceGroupName $resourceGroup -TemplateFile $tempFilePath `
     -logicAppName $logicAppName `
     -ConnectionName $ConnectionName `
     -ConnectionDisplayName $ConnectionDisplayName `
     -ConnectiontokenTenantId $ConnectiontokenTenantId `
     -Verbose
       