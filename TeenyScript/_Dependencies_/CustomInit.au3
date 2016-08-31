; TeenyScript MISC for Private methods (Yeah this will eventually MOVE but i dare not to change any code in AutoitObject yet....)
Global Const $ELSCOPE_ = $ELSCOPE_PUBLIC
#include-once
Global Const $_TS_FULL_SCRIPT_PATH = @ScriptDir & '\' & @ScriptName
Global Enum $_TS_IGNORE, $_TS_CONSOLE, $_TS_MSGBOX
Global $_TS_bErrorNotify ; This will act as default error-out
Global $_TS_LastErrMsg
#Region Error
; Error monitoring
Global $_TS_oError

; Set default based on script-mode
If Not @Compiled Then
	$_TS_bErrorNotify = $_TS_CONSOLE
Else
	$_TS_bErrorNotify = $_TS_MSGBOX
EndIf

Func _TS_ErrorNotify($c)
	Local $tPrev = $_TS_bErrorNotify ; Store prev enum
	If $c == $_TS_IGNORE Then
		$_TS_oError = Null
		$_TS_oError = ObjEvent("AutoIt.Error", "__NoErr")
	Else
		$_TS_oError = ObjEvent("AutoIt.Error", "_TS_ErrFunc")
	EndIf
	$_TS_bErrorNotify = $c

	Return $tPrev
EndFunc   ;==>_TS_ErrorNotify


Func _TS_ErrFunc($_TS_oError)
	Local const $Line = $_TS_oError.scriptline, $Code = _TS_GetLineCode($Line), $Help = _Ts_GetHelp($Code)

	;Get the relative line number based on the file

	; Read backwards untill we find the ;TS_DEBUG
	Local $fHandle = FileOpen($_TS_FULL_SCRIPT_PATH, 0)
	Local $pos = $_TS_oError.scriptline

	While $pos > 0
		Local $cur = FileReadLine($fHandle, $pos)
		; Look for TsDebug comment
		Local $aTry = StringRegExp($cur, ";\TS_DEBUG\=(.*):(.*):(.*):(.*)", 3)
		if IsArray($aTry) Then ExitLoop
		$pos-=1; Go backwards to look for refrences
	WEnd
	FileClose($fHandle)

	Local Const $TS_DEBUG_Filepath = $aTry[0]
	Local Const $TS_DEBUG_Namespace = $aTry[1]
	Local Const $TS_DEBUG_Funcname = $aTry[2]
	Local Const $TS_DEBUG_FuncParams = $aTry[3]
	Local Const $TS_DEBUG_Line = _TS_Debug_GetLine($TS_DEBUG_Filepath, $Code); Search for the file in .ts code

	; Poor choice of name, i know, im working at 20 things at a time
	Local Const $Line2Use = ($TS_DEBUG_Line > 0 ? StringFormat("On Line: %d", $TS_DEBUG_Line) : "Unid Line number")

	Local $_TS_LastErrMsg = '!' & @TAB & StringFormat("COM Error In '%s'. @  %s/$%s = Func(%s) %s", $TS_DEBUG_Filepath, $TS_DEBUG_Namespace, $TS_DEBUG_Funcname, $TS_DEBUG_FuncParams, $Line2Use) & @CRLF & _
			'> ' & @TAB & '~ Code: ' & $Code & @CRLF & _
			'> ' & @TAB & '~ Reason: ' & $_TS_oError.windescription & _ ;Sometains contains a @CR|*LF
			'+ ' & @TAB & '~ Problem: ' & $Help & _
			'+ ' & @TAB & '~ Click below to goto error' & @CRLF & _
			StringFormat('"%s"(%d) : error: %s', $TS_DEBUG_Filepath, $TS_DEBUG_Line, $_TS_oError.windescription) & _
			'! ' & @TAB & 'COM Error End...' & @CRLF & @CRLF

	Switch $_TS_bErrorNotify
		Case $_TS_IGNORE

		Case $_TS_CONSOLE
			ConsoleWrite($_TS_LastErrMsg & @CRLF)
		Case $_TS_MSGBOX
			MsgBox(0, "TeenyScript Com error Handler", $_TS_LastErrMsg)
	EndSwitch

	Return
EndFunc   ;==>_TS_ErrFunc

Func _TS_Debug_GetLine($sFilePath, Const $lookFor)
	Local $aHaystack = StringSplit(FileRead($sFilePath), @CR)
	For $line = 1 To $aHaystack[0]
		If StringInStr($aHaystack[$line], $lookFor) Then Return $line
	Next
	Return 0
EndFunc   ;==>_TS_Debug_GetLine

; So we can retrive the piece of code name of our com error and displya it SHOULD ONLY WORK WHEN NOT COMPILED!
Func _TS_GetLineCode($Line)
	Return StringStripWS(FileReadLine($_TS_FULL_SCRIPT_PATH, $Line), 1)
EndFunc   ;==>_TS_GetLineCode

; This will help us determine what could have cause the line to trigger an error
Func _Ts_GetHelp($Code)
	Local $solution = "", $try

	; Look for reserved names from TS
	$try = StringRegExp($Code, "(?i)(.*).(__(?:parent)__)", 3)
	If IsArray($try) Then
		$solution &= "It seems like you are trying to access the " & $try[1] & " property which may only be used within TS-Classes and its children, please go and check the origin of '" & $try[0] & "' and make sure it is a TS-Class or owns the property" & @CRLF
	EndIf

	; Look for reserved names in AutoitObject
	Local Const $AoReservedProps = "__params__|__name__|__propcall__|__bridge__|__error__|__result__"
	$try = StringRegExp($Code, "(?i)(.*).(" & $AoReservedProps & ")", 3)
	If IsArray($try) Then
		$solution &= "You are trying to access a AutoitObject reserved property '" & $try[1] & "' near " & $try[0] & ", which cannot be overwritten by a list or a TS-Class property, reserved properties for AutoitObject are: "& $AoReservedProps & @CRLF
	EndIf

	If $solution == "" Then $solution = "No solution detected..." & @CRLF
	Return $solution
EndFunc   ;==>_Ts_GetHelp

Func __NoErr()

EndFunc   ;==>__NoErr
#EndRegion Error
Func __CI_ShutdownAO()
	_AutoItObject_Shutdown(False)
EndFunc   ;==>__CI_ShutdownAO
#Region AutoitObject startup
_TS_ErrorNotify($_TS_bErrorNotify)
_AutoItObject_Startup()
OnAutoItExitRegister("__CI_ShutdownAO")
#EndRegion AutoitObject startup
