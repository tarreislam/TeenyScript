@Namespace Main

; Main function
$Main = Func(ByRef $CmdLine)

	; Handle CmdLine
	If $CmdLine[0] > 0 Then

		Exit
	EndIf

	; Else
	ConsoleWrite("Unnamed console application")


EndFunc($CmdLine)