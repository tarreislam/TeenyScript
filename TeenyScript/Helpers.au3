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
Global $ConsoleWrite = _ConsoleWrite
Global Enum $STR_PAD_LEFT, $STR_PAD_MID, $STR_PAD_RIGHT
Global Const $_TS_Project_Console_log_dir = @ScriptDir & "\logs"

Func _ConsoleWrite($sText, $c, $p1 = "", $p2 = "", $p3 = "", $p4 = "", $p5 = "")
	Local Static $fHandle = FileOpen(StringFormat("%s\console.log", $_TS_Project_Console_log_dir), $FO_APPEND + $FO_CREATEPATH)
	Switch $c
		Case "r"; Red
			$c = "!"
		Case "g"; Green
			$c = "+"
		Case "b"; blue
			$c = ">"
		Case "o"; Orange
			$c = "-"
		Case Else

	EndSwitch
	Local $s = $c & @TAB & StringFormat($sText, $p1, $p2, $p3, $p4, $p5) & @CRLF
	FileWrite($fHandle, $s)
	Return ConsoleWrite($s)
EndFunc

; Will copy the content of a whole directory, instead of just the folder
Func _DirCopyContent($sSourceDir, $sTargetDir, $hParent = 0)
	If Not FileExists($sSourceDir) Then
		MsgBox($MB_ICONWARNING, "", StringFormat("The source directory '%s' does not exist", $sSourceDir), 0, $hParent)
		Return SetError(1, 0, 0)
	EndIf
	If Not FileExists($sTargetDir) Then
		MsgBox($MB_ICONWARNING, "", StringFormat("The target directory '%s' does not exist", $sTargetDir), 0, $hParent)
		Return SetError(2, 0, 0)
	EndIf

	Local $_FileListToArrayRec = _FileListToArrayRec($sSourceDir, "*", $FLTAR_FILESFOLDERS, $FLTAR_RECUR, $FLTAR_NOSORT, $FLTAR_RELPATH)
	For $i = 1 To $_FileListToArrayRec[0]
		Local $cSource = StringFormat("%s\%s", $sSourceDir, $_FileListToArrayRec[$i])
		Local $cTarget = StringFormat("%s\%s", $sTargetDir, $_FileListToArrayRec[$i])
		Switch FileGetAttrib($cSource)
			Case "D"; Create target directory if source is a directory
				If Not DirCreate($cTarget) Then
					MsgBox($MB_ICONWARNING, "", "An error occured while creating the directory: " & $cTarget, 0, $hParent)
					Return SetError(3, 0, 0)
				EndIf
			Case Else; File
				If Not FileCopy($cSource, $cTarget, $FC_OVERWRITE) Then
					MsgBox($MB_ICONWARNING, "", StringFormat("An error occured while copying the file '%s' to '%s'", $cSource, $cTarget), 0, $hParent)
					Return SetError(4, 0, 0)
				EndIf
		EndSwitch
	Next
	Return True
EndFunc

; From https://www.autoitscript.com/autoit3/docs/functions/FileGetSize.htm
;ResourceGetSize, dir or file. dosent matter
Func _rGetSize($sFileName)
	Local $iBytes
	If FileGetAttrib($sFileName) == "D" Then
		$iBytes = DirGetSize($sFileName)
	Else
		$iBytes = FileGetSize($sFileName)
	EndIf
    Local $iIndex = 0, $aArray = ['bytes', 'KB', ' MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']
    While $iBytes > 1023
        $iIndex += 1
        $iBytes /= 1024
    WEnd
    Return StringFormat("%d %s", Round($iBytes), $aArray[$iIndex])
EndFunc   ;==>ByteSuffix

#Region File info snipplets
Func isEmpty($str)
	Return StringRegExp($str, "^\s*$")
EndFunc   ;==>isEmpty

Func escapeForwardSlash($str)
	Return StringReplace($str, "/", "\/")
EndFunc   ;==>escapeForwardSlash

Func getFromFilepath_basedir($sPath); (c:\path\to)\filename.ext (Will POP the last DIR if no (file.ext) exists
	Return StringRegExpReplace($sPath, "(.*)\\.*", "$1")
EndFunc

Func getFromFilepath_filename($sPath); c:\path\to\(filename.etc).ext
	Return StringRegExpReplace($sPath, ".*\\(.*)\..*", "$1")
EndFunc

Func getFromFilepath_filename_DotStripped($sPath); c:\path\to\(filename).etc.ext
	Return StringRegExpReplace($sPath, ".*\\([^.]*)\..*", "$1")
EndFunc

Func getFromFilepath_ext($sPath); c:\path\to\filename.etc.(ext)
	Return StringRegExpReplace($sPath, ".*\.(.+)", "$1")
EndFunc

Func getFromFilepath_all_asArray($sPath); (c:\path\to)\(filename.etc).(ext)
	Local $aRet = StringRegExp($sPath, "(.*)\\(.*)\.(.*)", 3)
	Return $aRet;[0] = filpath without ending slash, [1] = filename including DOTS, [2] = extension (Excluding dots)
EndFunc

Func getRandomString($len, $fill = False)
	Local $ret = ""
	For $i = 1 To $len
		If $fill == False Then
			$ret &= "_" & Chr(Random(65, 90, 1))
		Else
			$ret &= $fill
		EndIf
	Next
	Return $ret
EndFunc   ;==>rString


Func STR_PAD($str, $direction = $STR_PAD_RIGHT, $MaxWidth = 47, $fill = "#")
	$str = StringSplit($str, "")
	Local Const $str_len = $str[0]
	Local $sRet = ""

	Switch $direction
		Case $STR_PAD_LEFT
			Local $str_new_pos = ($str_len - $MaxWidth)
			Local $x = 1
			For $i = 1 To $MaxWidth
				If $i >= $str_new_pos And $x <= $str_len Then
					$sRet &= $str[$x]
					$x+=1
				Else
					$sRet &= $fill
				EndIf
			Next
		Case $STR_PAD_MID
			Local $str_new_pos = Round(($MaxWidth - $str_len)/2)
			Local $x = 1
			For $i = 1 To $MaxWidth
				If $i >= $str_new_pos And $x <= $str_len Then
					$sRet &= $str[$x]
					$x+=1
				Else
					$sRet &= $fill
				EndIf
			Next
		Case $STR_PAD_RIGHT
			For $i = 1 To $MaxWidth
				If $i <= $str_len Then
					$sRet &= $str[$i]
				Else
					$sRet &= $fill
				EndIf
			Next
	EndSwitch

	Return $sRet
EndFunc
#EndRegion
