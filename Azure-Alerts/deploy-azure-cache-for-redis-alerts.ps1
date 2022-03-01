param(

[String]$JsonFile, 
[String]$alertGroupRegr,

$AzureResourceGroup = 'Redis',
$processname = 'parameters'
)
$templatefile =  '\templates\alerts\azureCacheForRedis.json'
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
$redisName=$arraydata.redisName
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


New-AzResourceGroupDeployment -name $deployment -ResourceGroupName $resourceGroup[$i] -TemplateFile $tempFilePath -AlertGroupName $alertGroupName[$i] -alertGroupRegr $alertGroupRegr -redisName $redisName[$i] -alertSeverity $alertSeverity[$i] -evaluationFrequency $evaluationFrequency[$i] -windowSize  $windowSize[$i]`
-metricName $metricName[$i]`
-monitname $monitname[$i]`
-operator $operator[$i]`
-threshold $threshold[$i]`
-timeAggregation $timeAggregation[$i]`
-teamName $teamName[$i] -Verbose
}