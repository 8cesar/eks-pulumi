[CmdletBinding()]

param
(
    [string] $ElasticUrl = 'https://b9a4cfd069234e66be0168c8f9198087.westeurope.azure.elastic-cloud.com:9243',
    [string] $User = 'florin-test',
    [string] $Pass = 'EV656Hh4dSUG6ysf'
)

$WatchesPath = (Split-Path -Parent $MyInvocation.MyCommand.Path) + '\watches\'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ElasticApiBase64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $User, $Pass)))
$FileList = (Get-ChildItem -Path $WatchesPath -Recurse -Exclude ('endpoints', 'queries')).Name

$RegisteredWatches = (Invoke-RestMethod `
        -Method GET `
        -Uri ($ElasticUrl + '/_watcher/_query/watches') `
        -Headers @{Authorization = "Basic $ElasticApiBase64AuthInfo" } `
        -ContentType 'application/json' `
        -Body (@{size = 9999 } | ConvertTo-Json)).watches

# if there is a registered watch not in $FileList, delete registered watch
foreach ($RegisteredWatch in $RegisteredWatches) {
    if ($RegisteredWatch._id -notin $FileList) {
        Write-Host hello $RegisteredWatch
    }
}

# foreach ($File in $FileList) {
#     # only works if both watch types have unique file names
#     $FilePath = (Get-ChildItem $WatchesPath -Filter $File -Recurse).FullName
#     $WatchName = [io.path]::GetFileNameWithoutExtension($File)


#     # Invoke-RestMethod `
#     #     -Method PUT `
#     #     -Uri ($ElasticUrl + '/_watcher/watch/' + $WatchName) `
#     #     -Headers @{Authorization = "Basic $ElasticApiBase64AuthInfo" } `
#     #     -ContentType 'application/json' `
#     #     -Body (Get-Content -Path $FilePath)
# }
