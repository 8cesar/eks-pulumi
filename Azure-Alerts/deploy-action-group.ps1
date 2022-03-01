param(

[String]$parameterfile ,

[String]$JsonFile  , 

[String]$AzureResourceGroup = 'ActionGroup',

[String]$processname = 'parameters'
)

$templatefile =  '\templates\azure-monitoring-resources\actionGroup.json'
$parameterfile = '\parameters\'+$JsonFile

$scriptPath = split-path -parent $MyInvocation.MyCommand.Path

$tempFilePath = $scriptPath + "$templatefile"

$scriptPath = split-path -parent $MyInvocation.MyCommand.Path

$paramFilePath = $scriptPath + "$parameterfile"

$timestamp=Get-Date -Format MM/dd/yy-

$deploymentName=$AzureResourceGroup # +"-"+$timestamp  #can be added date and number

$data =@()

$data += Get-Content -Raw -path $paramFilePath  | ConvertFrom-Json 

$arraydata=$data.$processname.$AzureResourceGroup

$resourceGroup=$arraydata.resourceGroup

$alertGroupName=$arraydata.alertGroupName

$AlertName1=$arraydata.AlertName1

$email=$arraydata.email

$LogAppReceiver=$arraydata.LogAppReceiver


for ($i =0; $i -le $arraydata.GetUpperBound(0); $i++){


$deployment = ("$deploymentName" + "$i")

$notPresent = Get-AzResourceGroup -Name $resourceGroup[$i] -ErrorVariable notPresent -ErrorAction 0

if ($notPresent){

        New-AzResourceGroupDeployment -name $deployment -ResourceGroupName $resourceGroup[$i] -TemplateFile $tempFilePath -AlertGroupName $alertGroupName[$i]-AlertName1 $AlertName1[$i] -email $email[$i] -LogAppReceiver $LogAppReceiver[$i] -Verbose 

    }
        else
    {

        Write-Host "Resource Group doestnt exsist check your parameters or configuration: " $resourceGroup[$i] 

    }

}
