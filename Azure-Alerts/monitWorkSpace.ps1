 param(

[String]$templatefile = '\templates\WorkSpaces.json',

[String]$parameterfile,

[String]$JsonFile, 

[String]$AzureResourceGroup = 'MonitWorkSpace',

$processname = 'parameters'

)
 
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

$workSpaceName=$arraydata.workspaceName

$sku=$arraydata.sku

$retentionInDays=$arraydata.retentionInDays


 New-AzResourceGroupDeployment -name $deploymentName -ResourceGroupName $resourceGroup -TemplateFile $tempFilePath -workspaceName $workSpaceName -sku $sku -retentionInDays $retentionInDays -Verbose
       