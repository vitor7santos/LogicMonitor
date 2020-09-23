$accessId = "wEAALnM59V4Mq4ZIubWy" 
$accessKey = "-I+Ia]K~58vG+rQEp59pr^qHf-MXV4ey4VX--}zj"
$company = "alphaserveit"
$deviceId = 1051

# FUNCTION AREA
function SpecialCharacterCheck() {
	# According to LM the Wildvalue(s) can't contain several characters
	# -> https://www.logicmonitor.com/support/logicmodules/datasources/active-discovery/script-active-discovery
	# Replacing  ['=',':','\','#','space'] characters

    Param(
        [Parameter(position = 0, Mandatory = $true)]
        [string]$wildvalue
    )
    #iterate through the $password in order to find possible reserved characters
    #WIKI -> https://tools.ietf.org/html/rfc3986#section-2.2
    if ($wildvalue -match '\='){
        #replace the '@' for its actual encoding representation
        $wildvalue = $wildvalue -replace '\=', ''
    }
    if ($wildvalue -match '\:'){
        #replace the '@' for its actual encoding representation
        $wildvalue = $wildvalue -replace '\:', ''
    }
    if ($wildvalue -match '\\'){
        #replace the '@' for its actual encoding representation
        $wildvalue = $wildvalue -replace '\\', ''
    }
    if ($wildvalue -match '\#'){
        #replace the '@' for its actual encoding representation
        $wildvalue = $wildvalue -replace '\#', ''
    }
    if ($wildvalue -match '\ '){
        #replace the '@' for its actual encoding representation
        $wildvalue = $wildvalue -replace '\ ', ''
    }
    if ($wildvalue -match '\.'){
        #replace the '@' for its actual encoding representation
        $wildvalue = $wildvalue -replace '\.', ''
    }
	Return $wildvalue
}

function Send-Request() {
    Param(
        [Parameter(position = 0, Mandatory = $true)]
        [string]$path,
        [Parameter(position = 1, Mandatory = $false)]
        [string]$httpVerb = 'GET',
        [Parameter(position = 2, Mandatory = $false)]
        [string]$queryParams,
        [Parameter(position = 3, Mandatory = $false)]
        [PSObject]$data
    )
    # Use TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    <# Construct URL #>
    $url = "https://$company.logicmonitor.com/santaba/rest$path$queryParams"
    <# Get current time in milliseconds #>
    $epoch = [Math]::Round((New-TimeSpan -start (Get-Date -Date "1/1/1970") -end (Get-Date).ToUniversalTime()).TotalMilliseconds)
    <# Concatenate Request Details #>
    $requestVars = $httpVerb + $epoch + $data + $path
    <# Construct Signature #>
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = [Text.Encoding]::UTF8.GetBytes($accessKey)
    $signatureBytes = $hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($requestVars))
    $signatureHex = [System.BitConverter]::ToString($signatureBytes) -replace '-'
    $signature = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($signatureHex.ToLower()))
    <# Construct Headers #>
    $auth = 'LMv1 ' + $accessId + ':' + $signature + ':' + $epoch
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", $auth)
    $headers.Add("Content-Type", 'application/json')
    $headers.Add("X-version", '2')
    <# Make request & retry if failed due to rate limiting #>
    $Stoploop = $false
    do {
        try {
            <# Make Request #>
            $response = Invoke-RestMethod -Uri $url -Method $httpVerb -Body $data -Header $headers
            $Stoploop = $true
        } catch {
            switch ($_) {
                { $_.Exception.Response.StatusCode.value__ -eq 429 } {
                    Write-Host "Request exceeded rate limit, retrying in 60 seconds..."
                    Start-Sleep -Seconds 60
                    $response = Invoke-RestMethod -Uri $url -Method $httpVerb -Body $data -Header $headers
                }
                { $_.Exception.Response.StatusCode.value__ } {
                    Write-Host "Request failed, not as a result of rate limiting"
                    # Dig into the exception to get the Response details.
                    # Note that value__ is not a typo.
                    Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
                    Write-Host "StatusDescription:" $_.Exception.Response.StatusCode
                    $_.ErrorDetails.Message -match '{"errorMessage":"([\d\S\s]+)","errorCode":(\d+),'
                    Write-Host "LM ErrorMessage" $matches[1]
                    Write-Host "LM ErrorCode" $matches[2]
                    $response = $null
                    $Stoploop = $true
                }
                default {
                    Write-Host "An Unknown Exception occurred:"
                    Write-Host $_ | Format-List -Force
                $response = $null
                $Stoploop = $true
            }
        }
    }
} While ($Stoploop -eq $false)
Return $response
}
# END FUNCTION AREA

# get DataSource ID (at the device level)
$httpVerb = 'GET'
$resourcePath = '/device/devices/'+$deviceId+'/devicedatasources'
$queryParams = '?filter=instanceNumber>0,dataSourceName~"Windows_TaskScheduler_RunStatus_BETA"'
$data = ''
$request = Send-Request $resourcePath $httpVerb $queryParams

$ds_id = $request.items.id # store datasource ID in a variable

# get scheuled task(s) that aren't Disabled
$get_tasks = Get-ScheduledTask | Where State -ne "Disabled" | Select TaskName,TaskPath

# iterate the results & output those
foreach ($task in $get_tasks) {
    $task_name = $task.TaskName
	$task_path = $task.TaskPath
	$wildvalue = SpecialCharacterCheck($task_name)
	# build the actual taskName for the search (taskPath+taskName)
	$task_queryName = "${task_path}${task_name}"

	# get task details (TaskResult & Num of missed runs)
	$get_taskDetails = Get-ScheduledTaskInfo -TaskName "${task_queryName}" | Select LastTaskResult,NumberOfMissedRuns

	# iterate through task details & output the value(s)
	foreach ($task_detail in $get_taskDetails){
		$task_LastResult = $task_detail.LastTaskResult # this is returning in Decimal
		$task_LastResult_hexRaw = ($task_LastResult).ToString('x') # convert into HEX
        $task_LastResult_hex = "0x"+$task_LastResult_hexRaw.ToUpper() # add 0x prefix (to look like the actual error code)
		$task_NumberOfMissedRuns = $task_detail.NumberOfMissedRuns

		# get instanceID
		$httpVerb = 'GET'
		$resourcePath = '/device/devices/'+$deviceId+'/devicedatasources/'+$ds_id+'/instances'
		$queryParams = '?filter=wildValue:"'+$wildvalue+'"&fields=id,wildValue,displayName,groupId,wildValue,customProperties'
		$data = ''
		$request = Send-Request $resourcePath $httpVerb $queryParams

		$ds_instanceId = $request.items.id # store instanceID in a variable
		$ds_instanceDisplayName = $request.items.displayName # store displayName (to use in the PUT request)
		$ds_instanceGroupId = $request.items.groupId # store groupId (to use in the PUT request)
		$ds_instanceWildValue = $request.items.wildValue # store wildValue (to use in the PUT request)

		# update Properties in the instance level
		$httpVerb = 'PUT'
		$resourcePath = '/device/devices/'+$deviceId+'/devicedatasources/'+$ds_id+'/instances/'+$ds_instanceId
		$queryParams = ''
		$data = '{"wildValue":"' + $ds_instanceWildValue + '","groupId":'+$ds_instanceGroupId+',"displayName":"'+$ds_instanceDisplayName+'","customProperties": [{"name":"TaskLastResult", "value":"'+$task_LastResult_hex+'"}]}'
		$request = Send-Request $resourcePath $httpVerb $queryParams $data

		# output the results
		write "${wildvalue}.LastTaskResult=${task_LastResult}"
		write "${wildvalue}.NumberOfMissedRuns=${task_NumberOfMissedRuns}"
	}
}

Exit 0;