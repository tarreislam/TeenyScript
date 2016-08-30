#NoTrayIcon
; -
; - A 32 bit .exe that determines the user's architecture and opens the most suitable file
; -
If @CPUArch == "X64" Then
	If FileExists("%project.name%_x64.exe") Then
		Run("%project.name%_x64.exe")
	Else
		MsgBox(16, "TeenyScript Launcher %teenyscript._TS_AppVer%", "Could not start '%project.name%_x64.exe'. The file does not exist", 15)
	EndIf
Else
	If FileExists("%project.name%_x32.exe") Then
		Run("%project.name%_x32.exe")
	Else
		MsgBox(16, "TeenyScript Launcher %teenyscript._TS_AppVer%", "Could not start '%project.name%_x32.exe'. The file does not exist", 15)
	EndIf
EndIf