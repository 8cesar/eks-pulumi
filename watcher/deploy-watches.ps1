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
$FileList = (Get-ChildItem -Path $WatchesPath).Name

# 'size' = The number of hits to return. Needs to be non-negative.
# Unfortunately, size = 0 does not return all Watches, hence we need a big number.
# https://www.elastic.co/guide/en/elasticsearch/reference/current/watcher-api-query-watches.html
$RegisteredWatches = (Invoke-RestMethod `
        -Method GET `
        -Uri ($ElasticUrl + '/_watcher/_query/watches') `
        -Headers @{Authorization = "Basic $ElasticApiBase64AuthInfo" } `
        -ContentType 'application/json' `
        -Body (@{size = 9999 } | ConvertTo-Json)).watches

# if there is a registered watch not in $FileList, delete registered watch
foreach ($RegisteredWatch in $RegisteredWatches) {
    # only works if the watch ID is the same as the filename
    if ((($RegisteredWatch._id) + '.json') -notin $FileList) {
        Write-Host hello $RegisteredWatch._id
        # Invoke-RestMethod `
        #     -Method DELETE `
        #     -Uri ($ElasticUrl + '/_watcher/watch/' + $RegisteredWatch._id) `
        #     -Headers @{Authorization = "Basic $ElasticApiBase64AuthInfo" } `
        #     -ContentType 'application/json'
    }
}

foreach ($File in $FileList) {
    $FilePath = (Get-ChildItem $WatchesPath -Filter $File -Recurse).FullName
    if ($FilePath -is [array]) {
        throw "Not all Elastic Watches have unique filenames: `n$FilePath"
    }
    $WatchName = [io.path]::GetFileNameWithoutExtension($File)

    # create watches
    # the Uri construction makes the watch ID to be the same as the filename
    Invoke-RestMethod `
        -Method PUT `
        -Uri ($ElasticUrl + '/_watcher/watch/' + $WatchName) `
        -Headers @{Authorization = "Basic $ElasticApiBase64AuthInfo" } `
        -ContentType 'application/json' `
        -Body (Get-Content -Path $FilePath)
}
