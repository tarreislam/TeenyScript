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

Func _ConsoleWrite($sText, $c, $p1 = "", $p2 = "", $p3 = "", $p4 = "", $p5 = "")
	Local Static $fHandle = FileOpen("logs\console.log", 1);$FO_APPEND
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


Func isEmpty($str)
	Return StringRegExp($str, "^\s*$")
EndFunc   ;==>isEmpty

Func escapeForwardSlash($str)
	Return StringReplace($str, "/", "\/")
EndFunc   ;==>escapeForwardSlash

#Region File info snipplets


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
#EndRegion

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
