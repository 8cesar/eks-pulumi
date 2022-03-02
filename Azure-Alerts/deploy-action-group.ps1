param(

[String]$parameterfile ,

[String]$JsonFile = "gfxprod.param.json"  , 

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

$alertName=$arraydata.alertName

$emailAddress=$arraydata.emailAddress

$logAppReceiver=$arraydata.logAppReceiver


for ($i =0; $i -le $arraydata.GetUpperBound(0); $i++){


$deployment = ("$deploymentName" + "$i")

$notPresent = Get-AzResourceGroup -Name $resourceGroup[$i] -ErrorVariable notPresent -ErrorAction 0

if ($notPresent){

        New-AzResourceGroupDeployment -name $deployment -ResourceGroupName $resourceGroup[$i] -TemplateFile $tempFilePath -alertGroupName $alertGroupName[$i] -alertName $alertName[$i] -emailAddress $emailAddress[$i] -logAppReceiver $logAppReceiver[$i] -Verbose 

    }
        else
    {

        Write-Host "Resource Group doestnt exsist check your parameters or configuration: " $resourceGroup[$i] 

    }

}
