:: ------------------------------------
:: iCue Terminator v1.0
:: ------------------------------------
:: github.com/ldstein/icue-terminator
:: ------------------------------------

@echo off

:: Max attempts to check for iCue
set MAX_ATTEMPTS=12

:: Seconds between attempts
set CYCLE_INTERVAL=5

:: Once iCue is found, seconds to wait before terminating
set TERMINATE_PAUSE=10

set COUNTER=0

if "%1" equ "--cycle" (
	goto :Check_iCue_Running	
) else (
	taskkill /f /t /im icue.exe
)

exit /b

:Check_iCue_Running
tasklist /fi "ImageName eq icue.exe" /fo csv 2>NUL | find /I "icue.exe">NUL

if "%ERRORLEVEL%"=="0" (
   echo iCue detected. Terminating in %TERMINATE_PAUSE% seconds...
   timeout /t %TERMINATE_PAUSE%   
   taskkill /f /t /im icue.exe
   exit /b
)

if %COUNTER% lss %MAX_ATTEMPTS% (
    set /a COUNTER=COUNTER+1
	echo Attempt #%COUNTER%/%MAX_ATTEMPTS% - iCue not running, checking again in %CYCLE_INTERVAL% seconds
	timeout /t %CYCLE_INTERVAL%
	goto :Check_iCue_Running
)

exit /b