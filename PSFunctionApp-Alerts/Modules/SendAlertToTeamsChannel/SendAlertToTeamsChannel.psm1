function addMsgBodyAndSend {
    param (
        $TextMsg,
        $Uri
    )

    $body = '{"text":"msg text"}'
    $body = ConvertFrom-Json $body
    $body.text = $TextMsg
    $body = ConvertTo-Json $body
    
    Invoke-RestMethod -Method Post -ContentType 'Application/Json' -Body $body -Uri $Uri
}
function sendAlertTo{
    param(
        $Team, 
        $Text
    )
    switch ($Team){
    "DevOps" {
        addMsgBodyAndSend -TextMsg $Text -Uri 'https://outlook.office.com/' + '$(watcherWebhookTeamDevOps)'
    }
    "Severity0" {
        addMsgBodyAndSend -TextMsg $Text -Uri 'https://outlook.office.com/' + '$(watcherWebhookSeverity0)'
    }
    "Severity1" {
        addMsgBodyAndSend -TextMsg $Text -Uri 'https://outlook.office.com/' + '$(watcherWebhookSeverity1)'
    }
    "Billing" {
        addMsgBodyAndSend -TextMsg $Text -Uri 'https://outlook.office.com/' + '$(watcherWebhookTeamBilling)'
    }
    "ChargeAssist" {
        addMsgBodyAndSend -TextMsg $Text -Uri 'https://outlook.office.com/' + '$(watcherWebhookTeamChargeAssist)'
    }
    "ChargeStation" {
        addMsgBodyAndSend -TextMsg $Text -Uri 'https://outlook.office.com/' + '$(watcherWebhookTeamChargeStation)'
    }
    "Integration" {
        addMsgBodyAndSend -TextMsg $Text -Uri 'https://outlook.office.com/' + '$(watcherWebhookTeamIntegration)'
    }
    "Portal" {
        addMsgBodyAndSend -TextMsg $Text -Uri 'https://outlook.office.com/' + '$(watcherWebhookTeamPortal)'
    }
    "SmartCharging" {
        addMsgBodyAndSend -TextMsg $Text -Uri 'https://outlook.office.com/' + '$(watcherWebhookTeamSmartCharging)'
    }
    }
}

Export-ModuleMember -Function 'sendAlertTo'
