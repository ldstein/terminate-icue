::::::::::::::::::::::::::::::::::::::::::::
:: Elevation Script Source: https://winaero.com/how-to-auto-elevate-a-batch-file-to-run-it-as-administrator/
::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::
:: Automatically check & get admin rights V2
::::::::::::::::::::::::::::::::::::::::::::
@echo off
CLS
REM ECHO.
REM ECHO =============================
REM ECHO Running Admin shell
REM ECHO =============================

:init
setlocal DisableDelayedExpansion
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
ECHO.
ECHO **************************************
ECHO Invoking UAC for Privilege Escalation
ECHO **************************************

ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
ECHO args = "ELEV " >> "%vbsGetPrivileges%"
ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
ECHO Next >> "%vbsGetPrivileges%"
ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
"%SystemRoot%\System32\WScript.exe" "%vbsGetPrivileges%" %*
exit /B

:gotPrivileges
setlocal & pushd .
cd /d %~dp0
if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

::::::::::::::::::::::::::::
::START
::::::::::::::::::::::::::::
REM Run shell as admin (example) - put here code as you like
REM ECHO %batchName% Arguments: %1 %2 %3 %4 %5 %6 %7 %8 %9

set TASK_NAME="Terminate iCue"
set TASK_XML="%~dp0task_config.xml"
set TASK_COMMAND="%~dp0terminate-icue.bat --cycle"

call :Show_Menu
exit /b

:Show_Menu
echo ===========================
echo Terminate iCue v1.0
echo ===========================
echo Select an option:
echo.
echo [1] Run Terminate iCue at login
echo [2] OR Run Terminate iCue Plugin Host at login
echo [3] Don't run Terminate iCue at login
echo [4] Disable Corsair background services (conserves battery)
echo [5] Enable Corsair background services
echo [6] Exit Setup
echo.
set /p Input=Enter 1, 2, 3, 4, 5 or 6:

if "%Input%" equ "1" (
    call :Remove_Task
	call :Install_Task terminate-icue.vbs
	call :Setup_Complete
	exit /b
)
if "%Input%" equ "2" (
    call :Remove_Task
	call :Install_Task terminate-icue-plugin-host.vbs
	call :Setup_Complete
	exit /b
)
if "%Input%" equ "3" (
	call :Remove_Task
	call :Setup_Complete
	exit /b
)
if "%Input%" equ "4" (
	call :Deactive_Corsair_Services
	call :Setup_Complete
	exit /b
)
if "%Input%" equ "5" (
	call :Activate_Corsair_Services
	call :Setup_Complete
	exit /b
)
if "%Input%" equ "6" (
	exit /b
)

echo --------------------------
echo Invalid Option
echo --------------------------
pause
cls
call :Show_Menu
exit /b

:Setup_Complete
echo --------------------------
echo Setup Complete
echo --------------------------
pause
cls
call :Show_Menu
exit /b

:Install_Task

powershell -command "&{"^
	"$name = 'Terminate iCue';"^
	"$desc = 'Waits for iCue to load then terminates it';"^
	"$userName = (Get-CimInstance -ClassName Win32_ComputerSystem).Username;"^
	"$workingDir = '%~dp0' ;"^
	"$arguments = \"%1\"; "^
	"$action = New-ScheduledTaskAction -Execute 'wscript.exe' -Argument $arguments -WorkingDirectory $workingDir;"^
	"$trigger = New-ScheduledTaskTrigger -AtLogon -User $username;"^
	"$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries;"^
	"$registered = Register-ScheduledTask -Action $action -RunLevel Highest -Trigger $trigger -TaskName $name -Description $desc -Settings $settings;"^
	"if ($registered) { Write-Host \"Created Task $name\" }"^
	"else { Write-Host \"Failed to create Task $name\" };"^
	"}"

exit /b


:Remove_Task
powershell -command "&{"^
	"$taskName = 'Terminate iCue';"^
	"$taskExists = Get-ScheduledTask | Where-Object {$_.TaskName -eq $taskName };"^
	"if ($taskExists){ "^
	"    Unregister-ScheduledTask -ErrorVariable unregisterTaskError -TaskName $taskName -Confirm:$false; "^
	"    if ($unregisterTaskError) { Write-Host \"Failed to remove Task $taskName\"} "^
	"    else { Write-Host \"Removed Task $taskName\" } "^
	"}"^
	"}"

exit /b

:Activate_Corsair_Services
call :Activate_Service CorsairGamingAudioConfig
call :Activate_Service CorsairMSIPluginService
call :Activate_Service CorsairLLAService
call :Activate_Service CorsairService
exit /b

:Deactive_Corsair_Services
call :Deactivate_Service CorsairGamingAudioConfig
call :Deactivate_Service CorsairMSIPluginService
call :Deactivate_Service CorsairLLAService
call :Deactivate_Service CorsairService
exit /b

:Activate_Service
:: Enable Startup
sc config %1 start= auto

:: Start service if it isn't running
for /F "tokens=3 delims=: " %%H in ('sc query %1 ^| findstr "        STATE"') do (
	if /I "%%H"=="STOPPED" (
		net start %1 /y		
	)
)

exit /b

:Deactivate_Service
:: Stop service if it is running
for /F "tokens=3 delims=: " %%H in ('sc query %1 ^| findstr "        STATE"') do (
	if /I "%%H"=="RUNNING" (
		net stop %1 /y		
	)
)

:: Disable startup
sc config %1 start= disabled
exit /b

:Stop_Service
for /F "tokens=3 delims=: " %%H in ('sc query %1 ^| findstr "        STATE"') do (
	if /I "%%H"=="RUNNING" (
		net stop %1 /y		
	)
)
exit /b