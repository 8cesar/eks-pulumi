 <#

 .SYNOPSIS
    Create JSON parameter file for ARM templates
 
 .DESCRIPTION
    The script.....

 .PARAMETER FirstParameter
        Description of each of the parameters.

 #>

 [CmdletBinding()]
 
 param(
	
	[Object]
    $AlertData,
    
    [Object]
    $ServiceBusData = @(),
    
    [Object]
    $WebAppData = @(),
    
    [Object]
    $AppNameData = @(),
    
    [Object] 
    $SqlNameData = @(),

    [Object] 
    $ResourceGroupData = @(),

    [string]
    $ResourceGroupAlertG = "gfx-monitoring-rg",
    
    [string]
    $AlertGroupName = "monitoringSB",
    
    [string]
    $AlertName = "devops-emailSB",
    
    [string]
    $Email = "devops@greenflux.com",
     
    [string]
    $SubscriptionID = "8ecd2896-3c7d-4d67-b0d4-4ed11c393bad",
     
    [string]
    $SubscriptionName = "gfxprod",

    ##Service bus metric parameters
    $Sbseverity = 2,

    $SbMetrics = "ServerErrors",

    $SBmonitname = "server errors1", 
              
    $SBoperator = "GreaterThan", 
                
    $SBthreshold = 10,
            
    $SBtimeAggregation = "Total",

	##SQL server metric parameters

    $sqlseverity =1,
   
    $SQbMetrics = "storage_percent",

    $SQLmonitname = "Data space used percent",
                        
    $SQLoperator = "GreaterThan",
                      
    $SQLthreshold = 90,
                      
    $SQLtimeAggregation = "Maximum",
   
    ##Web app metric parameters
   
    $WeAppbMetrics = "Http5xx",

    $WebAppmonitname = "Http Server Errors",
               
    $WebAppoperator = "GreaterThan",
           
    $WebAppthreshold = 10,
               
    $WebApptimeAggregation = "Total",
   
    ##app plan metric parameters

    $AppNameMetrics = "MemoryPercentage",

    $AppNamemonitname = "Memory percent 80", 
                
    $AppNameoperator = "GreaterThan", 
                
    $AppNamethreshold = 80,
                
    $AppNametimeAggregation = "Average"

)

$Date=Get-Date -format "dd-MM-yyyy"

$ParamFileNAme = $SubscriptionName+".param_$Date.json"

Select-AzSubscription -Subscription $SubscriptionID

Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

# if need to deploy by resource group names you have to add data in data array for parameter $ResourceGroupData

if ($ResourceGroupData.Count -eq 0) {


$RgNames = Get-AzResourceGroup | Select-Object ResourceGroupName

        } 
        
            else {

        $RgNames = $ResourceGroupData 

        }

$AlertData += (

    [pscustomobject]@{
        
        resourceGroup = $ResourceGroupAlertG 
        
        alertGroupName = $AlertGroupName
        
        alertName = "$AlertName"
        
        email = "$Email"
        
        }
     
    )

foreach ($ResourceGroup in $RgNames) {

    $ResourceGroup = $($ResourceGroup.ResourceGroupName)

# get service bus

    $ServiceBusList = Get-AzServiceBusNamespace -ResourceGroupName $ResourceGroup | Select-Object Name

        foreach ($ServiceBus in $ServiceBusList) {

            $ServieBusName  = $($ServiceBus.name)

            $ServiceBusData += (

            [pscustomobject]@{
            
                resourceGroup = $ResourceGroup
                
                seviceBusName = $ServieBusName
                
                alertGroupName = "monitoringSB"
                 
                alertSeverity = $Sbseverity
                
                evaluationFrequency = "PT1M"
                
                windowSize = "PT5M"
                
                metricName = $SbMetrics
                
                monitname = $SBmonitname 
                
                operator = $SBoperator
                
                threshold = $SBthreshold
                
                timeAggregation = $SBtimeAggregation
				
				teamName = "devops"
                
                }
    
            )

        }
        
    # get web app

    $WebAppList = Get-AzWebApp -ResourceGroupName $ResourceGroup  | Select-Object Name
 
        foreach ($WebApp in $WebAppList) {

            $WebAppName = $($WebApp.name)

            $WebAppData += (

            [pscustomobject]@{
            
                resourceGroup = $ResourceGroup
                
                WebAppName = $WebAppName
                
                alertGroupName = "monitoringSB" 
                
                alertSeverity = 3 
                
                evaluationFrequency = "PT15M"
                
                windowSize = "PT1H" 
                
                metricName = $WeAppbMetrics
                
                monitname = $WebAppmonitname 
                
                operator = $WebAppoperator
                
                threshold = $WebAppthreshold
                
                timeAggregation = $WebApptimeAggregation
				
				teamName = "devops"
                
                }                               
            
            )             
        
        }

    #get Application plan
    
    $AppList = Get-AzAppServicePlan -ResourceGroupName $ResourceGroup  | Select-Object Name

        foreach ($App in $AppList) {
            
            $AppName = $($App.name)

            $AppNameData += (

            [pscustomobject]@{
            
                resourceGroup = $ResourceGroup 
                
                serverfarmName = $AppName
                
                alertGroupName = "monitoringSB" 
                
                alertSeverity = 3 
                
                evaluationFrequency = "PT15M" 
                
                windowSize = "PT1H"
                
                metricName = $AppNameMetrics 
                
                monitname = $AppNamemonitname 
                
                operator = $AppNameoperator
                
                threshold = $AppNamethreshold
                
                timeAggregation = $AppNametimeAggregation
				
				teamName = "devops"

                }
     
            )

        }

    # get Azure SQL

    $SqlServerlist = Get-AzSqlServer -ResourceGroupName $ResourceGroup

        foreach ($SqlServer in $SqlServerList) {
   
            $SqlServerName  = $($SqlServer.Servername)         
            
            $SqlDatabaseList = Get-AzSqlDatabase -ServerName $SqlServerName -ResourceGroupName $ResourceGroup | Select-Object DatabaseName

                foreach ($SqlDatabase in $SqlDatabaseList) {
            
                    $SqlDatabaseName = $($SqlDatabase.DatabaseName)

                    $SqlNameData += (

                    [pscustomobject]@{
                    
                        resourceGroup = $ResourceGroup
                        
                        sqlServerName = $SqlServerName
                        
                        sqlDbName = $SqlDatabaseName
                        
                        alertGroupName = "monitoringDB" 
                        
                        alertSeverity = $sqlseverity
                        
                        evaluationFrequency = "PT1M"
                        
                        windowSize = "PT5M"
                        
                        metricName = $SQbMetrics
                        
                        monitname = $SQLmonitname
                        
                        operator = $SQLoperator
                        
                        threshold = $SQLthreshold 
                        
                        timeAggregation = $SQLtimeAggregation
						
						teamName = "devops"
                        
                        }
     
                   )
  
              }

        }

    }
            
  Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "false"

 @{t=""} | ConvertTo-Json > .\$ParamFileName
    
  Add-Content .\$ParamFileName '{'   

  Add-Content .\$ParamFileName '"parameters": {'

  Add-Content .\$ParamFileName '"ActionGroup": ['

  $AlertData | ConvertTo-Json >> .\$ParamFileName

  Add-Content .\$ParamFileName '],'

  Add-Content .\$ParamFileName '"ServiceBus" :['
  
  $ServiceBusData | ConvertTo-Json >> .\$ParamFileName

  Add-Content .\$ParamFileName '],'

  Add-Content .\$ParamFileName '"WebServices" :'

  $WebAppData | ConvertTo-Json >> .\$ParamFileName

  Add-Content .\$ParamFileName ','

  Add-Content .\$ParamFileName '"AppservicePLan1" :'
  
  $AppNameData | ConvertTo-Json >> .\$ParamFileName

  
  Add-Content .\$ParamFileName ','
  Add-Content .\$ParamFileName '"AzureSQLDatabase" :'

  $SqlNameData | ConvertTo-Json >> .\$paramFileNAme

  Add-Content .\$ParamFileName '}'
  Add-Content .\$ParamFileName '}'