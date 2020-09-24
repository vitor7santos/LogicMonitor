#retrieving required properties
$deviceName = "##system.displayname##"
$username = "##wmi.user##"
$password = "##wmi.pass##"
$secpw = ConvertTo-SecureString $password -AsPlainText -Force
$cred  = New-Object Management.Automation.PSCredential ($username, $secpw)

$scriptToExecute =
{
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
    # END FUNCTION AREA

    $get_tasks = Get-ScheduledTask | Where State -ne "Disabled" | Select TaskName,TaskPath

    foreach ($task in $get_tasks) {
        $task_name = $task.TaskName
        $task_path = $task.TaskPath
        $wildvalue = SpecialCharacterCheck($task_name)

		# output the instance discovery value(s)
		write "${wildvalue}##${task_name}######auto.TaskPath=${task_path}"
    }
}

# check if wmi.user/pass retrieved value(s)
if ($username -and $password) {
    # if yes, impersonate the user in question
    $result = Invoke-Command -ScriptBlock $scriptToExecute -ComputerName "${deviceName}" -credential $cred
    write $result
}else {
    # if not, tries the test anyway (using the actual user that collector runs with)
    $result = Invoke-Command -ScriptBlock $scriptToExecute -ComputerName "${deviceName}"
    write $result
}