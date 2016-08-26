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
#include <Array.au3>

Func _Array_Create(ByRef $a, $s = 0)
	ReDim $a[$s]
	$a[0] = $s + 1
EndFunc   ;==>_Array_Create

Func _Array_ToString(ByRef $a, $d = "|")
	If Not IsArray($a) Then
		ConsoleWrite("! _Array_ToString used with non array" & @CRLF)
		Return False
	EndIf

	Local $s
	for $i = 1 to $a[0]
		$s &= $a[$i] & $d
	Next
	Return $s
EndFunc

Func _Array_Push(ByRef $a, $v)
	If Not IsArray($a) Then
		ConsoleWrite("! _Array_Push used with non array" & @CRLF)
		Return False
	EndIf

	ReDim $a[$a[0] + 2]
	$a[$a[0] + 1] = $v
	$a[0] += 1
	Return $a[0]
EndFunc   ;==>_Array_Push

Func _Array_Empty(ByRef $a)

	If Not IsArray($a) Then
		ConsoleWrite("! _Array_Create used with non array" & @CRLF)
		Return False
	EndIf

	ReDim $a[1]
	$a[0] = 0
EndFunc   ;==>_Array_Empty

Func _Array_Remove(ByRef $a, $v)
	If Not IsArray($a) Then
		ConsoleWrite("! _Array_Remove used with non array" & @CRLF)
		Return False
	EndIf

	If $v < 1 Or $v > $a[0] Then
		ConsoleWrite("! _Array_Remove $Array is out of bounds" & @CRLF)
		Return False
	EndIf

	$a[$v] = Null

	Local $aa[$a[0]]

	For $i = 1 To $v - 1
		$aa[$i] = $a[$i]
	Next

	For $i = $v + 1 To $a[0]
		$aa[$i - 1] = $a[$i]
	Next

	$aa[0] = $a[0] - 1
	$a = $aa

	Return True
EndFunc   ;==>_Array_Remove
