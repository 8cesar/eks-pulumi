﻿param(

[String]$JsonFile, 
[String]$alertGroupRegr,

$AzureResourceGroup = 'Connections',
$processname = 'parameters'
)

$templatefile =  '\templates\alerts\connection.json'
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
$connectionName=$arraydata.connectionName
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


New-AzResourceGroupDeployment -name $deployment -ResourceGroupName $resourceGroup[$i] -TemplateFile $tempFilePath -alertGroupName $alertGroupName[$i] -alertGroupRegr $alertGroupRegr -connectionName $connectionName[$i] -alertSeverity $alertSeverity[$i] -evaluationFrequency $evaluationFrequency[$i] -windowSize  $windowSize[$i]`
-metricName $metricName[$i]`
-monitname $monitname[$i]`
-operator $operator[$i]`
-threshold $threshold[$i]`
-timeAggregation $timeAggregation[$i]`
-teamName $teamName[$i] -Verbose
}