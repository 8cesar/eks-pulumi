param(

[String]$JsonFile, 
[String]$alertGroupRegr,

$AzureResourceGroup = 'Synapse',
$processname = 'parameters'
)
$templatefile =  '\templates\alerts\synapseWorkspace.json'
$parameterfile = '\parameters\'+$JsonFile

$scriptPath = split-path -parent $MyInvocation.MyCommand.Path
$tempFilePath = $scriptPath + "$templatefile"

$scriptPath = split-path -parent $MyInvocation.MyCommand.Path
$paramFilePath = $scriptPath + "$parameterfile"

$data =@()

$data += Get-Content -Raw -path $paramFilePath  | ConvertFrom-Json 

$deploymentName=$AzureResourceGroup #can be added date and number

$arraydata=$data.$processname.$AzureResourceGroup

$resourceGroup=$arraydata.resourceGroup
$alertGroupName=$arraydata.alertGroupName
$synapseName=$arraydata.synapseName
$alertSeverity=$arraydata.alertSeverity
$evaluationFrequency=$arraydata.evaluationFrequency
$windowSize=$arraydata.windowSize
$metricName=$arraydata.metricName
$monitname=$arraydata.monitname
$operator=$arraydata.operator
$threshold=$arraydata.threshold
$timeAggregation=$arraydata.timeAggregation
$teamName=$arraydata.teamName

for ($i =0; $i -le $arraydata.GetUpperBound(0); $i++){



$deployment = ("$deploymentName" + "$i")

# TO FIX: $resourceGroup[$i] can mean either the first string in an array or the first char in a string, if arraydata.length == 1
# You can cast it: [array]$resourceGroup=$arraydata.resourceGroup
# By default, PowerShell variables are loosely typed (i.e. can store any object type)
New-AzResourceGroupDeployment -name $deployment -ResourceGroupName $resourceGroup[$i] -TemplateFile $tempFilePath -alertGroupName $alertGroupName[$i] -alertGroupRegr $alertGroupRegr -synapseName $synapseName[$i] -alertSeverity $alertSeverity[$i] -evaluationFrequency $evaluationFrequency[$i] -windowSize  $windowSize[$i]`
-metricName $metricName[$i]`
-monitname $monitname[$i]`
-operator $operator[$i]`
-threshold $threshold[$i]`
-timeAggregation $timeAggregation[$i]`
-teamName $teamName[$i] -Verbose
}