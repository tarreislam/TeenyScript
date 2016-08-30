#cs
	MIT License

	Copyright (c) 2016 Tariqul Islam
	http://teenyscript.tarre.nu/
	https://www.autoitscript.com/forum/profile/65348-tarretarretarre/
	https://github.com/tarreislam

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
#ce
#include-once

Func _Scite_OpenFile($sFilepath)
	RunWait(StringFormat('%s "%s"', $_AU3_SCITE_EXE, StringReplace($sFilepath, "\", "\\")))
EndFunc

Func _SciTe_getOpenFileName()
	Return StringRegExpReplace(WinGetTitle($_SCITE_HWND), $re_SciTE_TSpath, "")
EndFunc   ;==>_SciTe_getOpenFileName

Func _SciTe_runFile($sFile, $sDisplayFile)
	Local Const $timer = _SciTe_SexyTimePassedRauR_START("Running '%s' %s", $sDisplayFile, (isEmpty($_resource_CmdLine) ? 'without params' : 'with params: '& $_resource_CmdLine))
	RunWait(StringFormat('%s "%s" %s', $_AU3_EXE, $sFile, $_resource_CmdLine), "", Default, $STDIN_CHILD)
	_SciTe_SexyTimePassedRauR($timer)
EndFunc   ;==>_SciTe_runFile


Func _SciTe_compileFile($sFile, $cmdLine_OUT = False, $cmdLine_ICON = False, $cmdLine_ARCH = "32", $cmdLine_ProjectName = False, $cmdLine_ProjectVersion = $_TS_AppVer, $cmdLine_Copyright = @UserName, $cmdLine_Type = "gui")

	If $cmdLine_ARCH == "96" Then
		_SciTe_compileFile($sFile, $cmdLine_OUT, $cmdLine_ICON, "32", $cmdLine_ProjectName, $cmdLine_ProjectVersion, $cmdLine_Copyright, $cmdLine_Type)
		_SciTe_compileFile($sFile, $cmdLine_OUT, $cmdLine_ICON, "64", $cmdLine_ProjectName, $cmdLine_ProjectVersion, $cmdLine_Copyright, $cmdLine_Type)
		Return True
	EndIf

	$cmdLine_OUT = $cmdLine_OUT ? StringFormat("%s\%s_x%d.exe", $cmdLine_OUT, $cmdLine_ProjectName, $cmdLine_ARCH) : $cmdLine_OUT

	Local Const $timer = _SciTe_SexyTimePassedRauR_START("Compiling '%s' -> '%s'", $sFile, ($cmdLine_OUT ? $cmdLine_OUT : StringReplace($sFile, ".au3", ".exe") ))

	;What program to use
	Local $program = $cmdLine_ARCH == "32" ? $_AU3_AU2EXE : $_AU3_AU2EXE_64

	$filedescription = $cmdLine_ProjectName ? StringFormat(' /FILEDESCRIPTION "%s"', $cmdLine_ProjectName) : ""
	$originalFilename = StringFormat(' /originalfilename "%s_x%d.exe"', $cmdLine_ProjectName, $cmdLine_ARCH)
	$cmdLine_OUT = $cmdLine_OUT ? StringFormat(' /OUT "%s"', $cmdLine_OUT) : ""
	$cmdLine_ICON = $cmdLine_ICON ? StringFormat(' /ICON "%s"', $cmdLine_ICON) : ""
	$cmdLine_ARCH = $cmdLine_ARCH <> "32" ? StringFormat(' /x%d', $cmdLine_ARCH) : ""
	$cmdLine_ProjectName = $cmdLine_ProjectName ? StringFormat(' /PRODUCTNAME "%s"', $cmdLine_ProjectName) : ""
	$cmdLine_ProjectVersion = $cmdLine_ProjectVersion ? StringFormat(' /PRODUCTVERSION "%s"', $cmdLine_ProjectVersion) : ""
	$cmdLine_Copyright = $cmdLine_Copyright ? StringFormat(' /legalcopyright "%s"', $cmdLine_Copyright) : ""
	; @autoitver : $_TS_AppVer
	$fileversion = StringFormat(' /fileversion "%s"', $_TS_AppVer)

	$ConsoleWrite("Compiling using: '%s'", "g", $program)
	RunWait(StringFormat('%s /IN "%s"%s%s%s%s%s%s%s%s%s /%s', $program, $sFile, $cmdLine_OUT, _
	$cmdLine_ICON, _
	$cmdLine_ARCH, _
	$cmdLine_ProjectName, _
	$cmdLine_ProjectVersion, _
	$cmdLine_Copyright, _
	$filedescription, _
	$originalFilename, _
	$fileversion, _
	$cmdLine_Type), "", Default, $STDIN_CHILD)
	_SciTe_SexyTimePassedRauR($timer)

	Return True
EndFunc   ;==>_SciTe_compileFile

; Send commands to SciTE while its running (Shoutout to Jos @ AutoitScript forum)
Func _Scite_SendMessage($sCmd = "menucommand:420")
    Local $Scite_hwnd = WinGetHandle("DirectorExtension")
    Local $WM_COPYDATA = 74
    Local $CmdStruct = DllStructCreate('Char[' & StringLen($sCmd) + 1 & ']')
    DllStructSetData($CmdStruct, 1, $sCmd)
    Local $COPYDATA = DllStructCreate('Ptr;DWord;Ptr')
    DllStructSetData($COPYDATA, 1, 1)
    DllStructSetData($COPYDATA, 2, StringLen($sCmd) + 1)
    DllStructSetData($COPYDATA, 3, DllStructGetPtr($CmdStruct))
    DllCall('User32.dll', 'None', 'SendMessage', 'HWnd', $Scite_hwnd, _
            'Int', $WM_COPYDATA, 'HWnd', 0, _
            'Ptr', DllStructGetPtr($COPYDATA))
EndFunc   ;==>SendSciTE_Command



Func _SciTe_SexyTimePassedRauR_START($sText, $p1 = "", $p2 = "", $p3 = "")
	$ConsoleWrite($sText, "b", $p1, $p2, $p3)
	ConsoleWrite(@CRLF)
	Return TimerInit()
EndFunc   ;==>_SciTe_SexyTimePassedRauR_START

Func _SciTe_SexyTimePassedRauR(Const $timer)
	Local $timerDiff = TimerDiff($timer), $iVal = 0, $sEnding = ""
	If $timerDiff < 1000 Then
		$sEnding = "milliseconds"
		$iVal = $timerDiff
	ElseIf $timerDiff > 999 And $timerDiff < 60000 Then
		$sEnding = "seconds"
		$iVal = Round($timerDiff / 1000, 2)
	ElseIf $timerDiff > 59999 Then
		$sEnding = "minutes"
		$iVal = StringFormat("%d:%d", Round($timerDiff / 60000), Round(Mod($timerDiff, 60000) / 1000, 2))
	EndIf
	$ConsoleWrite("End ~%s %s.", "b", $iVal, $sEnding)
	ConsoleWrite(@CRLF)
EndFunc   ;==>_SciTe_SexyTimePassedRauR
