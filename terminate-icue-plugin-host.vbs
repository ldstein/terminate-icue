command = "powershell.exe -executionpolicy bypass -nologo -nologo -file terminate-icue.ps1 -pluginhost" 
set shell = CreateObject("WScript.Shell") 
shell.Run command,0