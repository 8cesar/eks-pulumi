 param(

[String]$parameterfile,

[String]$JsonFile, 

[String]$AzureResourceGroup = 'ServiceHealth01',

$processname = 'parameters'

)
$templatefile = '\templates\alerts\serviceHealth.json'
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

$AlertGroupName=$arraydata.AlertGroupName

$ServiceHealthName=$arraydata.ServiceHealthName

 New-AzResourceGroupDeployment -name $deploymentName -ResourceGroupName $resourceGroup -TemplateFile $tempFilePath -AlertGroupName $AlertGroupName -ServiceHealthName $ServiceHealthName -Verbose
       