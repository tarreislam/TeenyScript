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
Global $_Scite_DeleteThisFile = ""

Func _Scite_Adlib_Delete()
	If FileExists($_Scite_DeleteThisFile) Then FileDelete($_Scite_DeleteThisFile)
	AdlibUnRegister("_Scite_Adlib_Delete")
EndFunc

Func _Scite_OpenFile($sFilepath)
	RunWait(StringFormat('%s "%s"', $_AU3_SCITE_EXE, StringReplace($sFilepath, "\", "\\")))
EndFunc

Func _SciTe_getOpenFileName(); bein lazy feels good sometimes
	If $_HWND == $_SUBLIME_HWND Then Return StringRegExpReplace(WinGetTitle($_HWND), $re_Sublime_TSpath, "")
	Return StringRegExpReplace(WinGetTitle($_HWND), $re_SciTE_TSpath, "")
EndFunc   ;==>_SciTe_getOpenFileName

Func _SciTe_runFile($sInputFile, $sDisplayFile, $delete_at_runtime = False)
	Local Const $timer = _SciTe_SexyTimePassedRauR_START("Running '%s' %s", $sDisplayFile, (isEmpty($_resource_CmdLine) ? 'without params' : 'with params: '& $_resource_CmdLine))
	$_Scite_DeleteThisFile = $sInputFile
	If $delete_at_runtime Then AdlibRegister("_Scite_Adlib_Delete", 1500)
	RunWait(StringFormat('%s "%s" %s', $_AU3_EXE, $sInputFile, $_resource_CmdLine), "", Default, $STDIN_CHILD)
	_SciTe_SexyTimePassedRauR($timer)
EndFunc   ;==>_SciTe_runFile

Func _SciTe_compileFile($sInputFile, $sOutputDir = False, $sFileName = False, $cmdLine_ICON = False, $cmdLine_ARCH = "32", $cmdLine_ProjectName = False, $cmdLine_ProjectVersion = False, $cmdLine_Copyright = @UserName, $cmdLine_Type = "gui")

	If $cmdLine_ARCH == "96" Then
		_SciTe_compileFile($sInputFile, $sOutputDir, $sFileName, $cmdLine_ICON, "32", $cmdLine_ProjectName, $cmdLine_ProjectVersion, $cmdLine_Copyright, $cmdLine_Type)
		_SciTe_compileFile($sInputFile, $sOutputDir, $sFileName, $cmdLine_ICON, "64", $cmdLine_ProjectName, $cmdLine_ProjectVersion, $cmdLine_Copyright, $cmdLine_Type)
		Return True
	EndIf

	; Determine what au2exe to use
	Local Const $program = $cmdLine_ARCH == "32" ? $_AU3_AU2EXE : $_AU3_AU2EXE_64

	; The filename without extension
	Local Const $sFilenameNoExt = Not $sFileName ? StringFormat("%s_x%d", $cmdLine_ProjectName, $cmdLine_ARCH) : $sFileName

	; The new output filed
	Local Const $sOutputFile = StringFormat("%s\%s.exe", $sOutputDir, $sFilenameNoExt)

	; Prepare parameters for Au2exe
	Local Const $Au2exe_param_in = StringFormat(' /in "%s"', $sInputFile), _
	$Au2exe_param_out = $sOutputDir ? StringFormat(' /out "%s"', $sOutputFile) : "", _
	$Au2exe_param_icon = $cmdLine_ICON ? StringFormat(' /icon "%s"', $cmdLine_ICON) : "", _
	$Au2exe_param_arch = $cmdLine_ARCH <> "32" ? StringFormat(' /x%s', $cmdLine_ARCH) : "", _
	$Au2exe_param_productname = $cmdLine_ProjectName ? StringFormat(' /productname "%s"', $cmdLine_ProjectName) : "", _
	$Au2exe_param_productversion = $cmdLine_ProjectVersion ? StringFormat(' /productversion "%s"', $cmdLine_ProjectVersion) : "", _
	$Au2exe_param_legalcopyright = StringFormat(' /legalcopyright "%s"', isEmpty($cmdLine_Copyright) ? @UserName : $cmdLine_Copyright), _
	$Au2exe_param_type = StringFormat(' /%s', $cmdLine_Type), _
	$Au2exe_param_filedescription = StringFormat(' /filedescription "%s"', $sFilenameNoExt), _
	$Au2exe_param_originalfilename = StringFormat(' /originalfilename "%s.exe"', $sFilenameNoExt)
	$Au2exe_param_fileversion = StringFormat(' /fileversion "%s"', $_TS_AppVer)

	; Build the au2exe string
	Local $Au2Exe_fullStr = StringFormat("%s%s%s%s%s%s%s%s%s%s%s%s", _
	$program, _
	$Au2exe_param_in, _
	$Au2exe_param_out, _
	$Au2exe_param_icon, _
	$Au2exe_param_arch, _
	$Au2exe_param_productname, _
	$Au2exe_param_productversion, _
	$Au2exe_param_legalcopyright, _
	$Au2exe_param_type, _
	$Au2exe_param_filedescription, _
	$Au2exe_param_originalfilename, _
	$Au2exe_param_fileversion)

	; Run Au2Exe
	Local Const $timer = _SciTe_SexyTimePassedRauR_START("Compiling '%s' -> '%s'", $sInputFile, ($sOutputDir ? $sOutputFile : StringReplace($sInputFile, ".au3", ".exe")))
	RunWait($Au2Exe_fullStr, "", Default, $STDIN_CHILD)
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
