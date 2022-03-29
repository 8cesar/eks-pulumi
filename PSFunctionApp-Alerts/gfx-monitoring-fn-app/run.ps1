param($Timer)

$processname = "parameters"
$paramsFile = ".\parameters.json"
$data =@()
$data += Get-Content -Raw -path $paramsFile  | ConvertFrom-Json 

$alertType = "ServiceBusSubscription"
$alerts=$data.$processname.$AlertType

foreach ($alert in $alerts){
    Select-AzSubscription -SubscriptionId $alert.subscription
    $sub = Get-AzServiceBusSubscription -ResourceGroupName $alert.resourceGroup -Namespace $alert.serviceBusNamespace -Topic $alert.serviceBusTopic -Name $alert.serviceBusSubscrition
    if ($sub.CountDetails.ActiveMessageCount -gt $alert.threshold)
    {
      sendAlertTo -Team $alert.teamName -Text $alert.text
  }
}