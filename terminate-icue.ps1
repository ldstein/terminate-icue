param(    
    [switch]$pluginhost
)

$retriesRemaining = 24
$retryInterval    = 5
$minRunningTime   = 20
$processName      = "icue.exe"
$processBaseName  = (New-Object System.IO.FileInfo($processName)).BaseName

if ($pluginhost) 
{
	$processName = "icuedevicepluginhost.exe"
}

function checkIsRunning()
{
	$process = Get-Process $processBaseName -ErrorAction SilentlyContinue | Select-Object -First 1
	
	if ($process) {
		
		$delay       = 0
		$runningTime = (New-TimeSpan -Start $process.StartTime).TotalSeconds
		
		Write-Host "$processName has been running for $runningTime seconds"
		
		if ($runningTime -lt $minRunningTime) {
			$delay = $minRunningTime - $runningTime
		}
		
		Write-Host "$processName is running, terminating in $delay`s..."
		Start-Sleep -s $delay
		taskkill /f /t /im $processName
		
	} else {
		$retriesRemaining--
		
		if ($retriesRemaining -gt 0) {
			Write-Host "$processName not running, retrying in $retryInterval`s. (Retries remaining: $retriesRemaining)"
			Start-Sleep -s $retryInterval
			checkIsRunning;	
		} else {
			Write-Host "Max retries reached, giving up"
		}
	}
}

checkIsRunning;