[CmdletBinding()]
 
 param(
   
    [string]
    $Location,
    
    [string]
    $alertGroupRegr

)

Get-AzResourceGroup -name $alertGroupRegr -ErrorVariable notPresent -ErrorAction SilentlyContinue

if ($notPresent) {

    New-AzResourceGroup -Name $alertGroupRegr -Location $Location
}

