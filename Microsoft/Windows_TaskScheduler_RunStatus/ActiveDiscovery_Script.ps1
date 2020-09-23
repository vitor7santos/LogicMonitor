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

# get scheuled task(s) that aren't Disabled
$get_tasks = Get-ScheduledTask | Where State -ne "Disabled" | Select TaskName,TaskPath

# iterate the results & output those
foreach ($task in $get_tasks) {
    $task_name = $task.TaskName
	$task_path = $task.TaskPath
	$wildvalue = SpecialCharacterCheck($task_name)

	# output data
	write "${wildvalue}##${task_name}######auto.TaskPath=${task_path}"
}

Exit 0;