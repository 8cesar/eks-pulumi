param(

[String]$JsonFile, 
[String]$alertGroupRegr,

$AzureResourceGroup = 'ServiceBus',
$processname = 'parameters'
)
# templates and parameters
$templatefileIncDimensions = '\templates\alerts\serviceBusNamespaceIncDimensions.json'
$templatefile =  '\templates\alerts\serviceBusNamespace.json'
$parameterfile = '\parameters\'+$JsonFile
$scriptPath = split-path -parent $MyInvocation.MyCommand.Path
$tempFilePath = $scriptPath + "$templatefile"
$tempFilePathIncDimensions = $scriptPath + "$templatefileIncDimensions"
$scriptPath = split-path -parent $MyInvocation.MyCommand.Path
$paramFilePath = $scriptPath + "$parameterfile"
$dimensionsFile = '\templates\alerts\dimensions.json'
$dimensionsPath = $scriptPath + "$dimensionsFile"

# get the content
$data =@()
$data += Get-Content -Raw -path $paramFilePath  | ConvertFrom-Json 
$deploymentName=$AzureResourceGroup #can be added date and number
$arraydata=$data.$processname.$AzureResourceGroup
$resourceGroup=$arraydata.resourceGroup
$alertGroupName=$arraydata.alertGroupName
$seviceBusName=$arraydata.seviceBusName
$alertSeverity=$arraydata.alertSeverity
$evaluationFrequency=$arraydata.evaluationFrequency
$windowSize=$arraydata.windowSize
$metricName=$arraydata.metricName
$monitname=$arraydata.monitname
$operator=$arraydata.operator
$threshold=$arraydata.threshold
$timeAggregation=$arraydata.timeAggregation
$teamName=$arraydata.teamName
$dimensionsName = $arraydata.dimensionsName
$dimensionsOperator = $arraydata.dimensionsOperator
$dimensionsValues = $arraydata.dimensionsValues

for ($i =0; $i -le $arraydata.GetUpperBound(0); $i++){


    # deployment
    # check the parametars if dimensions exists
    if ($dimensionsName[$i]) {

        # json converter changes the type and [] will be missing once dimensions json is injected which is mandatory for ARM temaplate.
        [System.Collections.ArrayList]$dimensions = Get-Content $dimensionsPath | ConvertFrom-Json
    
        # create a list and then remove one member will do the trick
        $dimensions.RemoveAt(1)
    
        # change the properties
        $tempFile = Get-Content $tempFilePath | ConvertFrom-Json   
        $tempFile.resources.properties.criteria.allOf | Add-Member -MemberType NoteProperty -Name dimensions -Value $dimensions -Force
        $tempFile.resources.properties.criteria.allOf.dimensions[0].name = $dimensionsName[$i]
        $tempFile.resources.properties.criteria.allOf.dimensions[0].operator = $dimensionsOperator[$i]
        $tempFile.resources.properties.criteria.allOf.dimensions[0].values.SetValue($dimensionsValues[$i], 0)
    
        #convert to json and clear /u0022 caracters
        $newArm = $tempFile | ConvertTo-Json -Depth 100 | % { [System.Text.RegularExpressions.Regex]::Unescape($_) }
        #phizical file is mandarory
        $newArm | Out-File -FilePath $tempFilePathIncDimensions
        # deployment
        $deployment = ("$deploymentName" + "dimensions" + "$i")
        New-AzResourceGroupDeployment -name $deployment -ResourceGroupName $resourceGroup[$i] -TemplateFile $tempFilePathIncDimensions -alertGroupName $alertGroupName[$i] -alertGroupRegr $alertGroupRegr -seviceBusName $seviceBusName[$i] -alertSeverity $alertSeverity[$i] -evaluationFrequency $evaluationFrequency[$i] -windowSize  $windowSize[$i]`
            -metricName $metricName[$i]`
            -monitname $monitname[$i]`
            -dimensionsValues $dimensionsValues[$i]`
            -operator $operator[$i]`
            -threshold $threshold[$i]`
            -timeAggregation $timeAggregation[$i]`
            -teamName $teamName[$i] -Verbose
    }

    else {
        $deployment = ("$deploymentName" + "$i")
        New-AzResourceGroupDeployment -name $deployment -ResourceGroupName $resourceGroup[$i] -TemplateFile $tempFilePath -alertGroupName $alertGroupName[$i] -alertGroupRegr $alertGroupRegr -seviceBusName $seviceBusName[$i] -alertSeverity $alertSeverity[$i] -evaluationFrequency $evaluationFrequency[$i] -windowSize  $windowSize[$i]`
            -metricName $metricName[$i]`
            -monitname $monitname[$i]`
            -operator $operator[$i]`
            -threshold $threshold[$i]`
            -timeAggregation $timeAggregation[$i]`
            -teamName $teamName[$i] -Verbose
    }
 }