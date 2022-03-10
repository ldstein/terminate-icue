command = "powershell.exe -executionpolicy bypass -nologo -nologo -file terminate-icue.ps1" 
set shell = CreateObject("WScript.Shell") 
shell.Run command,0