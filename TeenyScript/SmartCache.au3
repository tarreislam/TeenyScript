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
#include <FileConstants.au3>

;sFilePath, dateChanged, sFileData
Global $_SMARTCACHE_RESOURCE = [[0]], $_SMARTCACHE_FILE_STATE = Null, $_SMARTCACHE_FILE_ID = Null, $_SMARTCACHE_PERFECT_CACHE = False
Global Enum $_SMARTCACHE_FILE_NOT_CACHED, $_SMARTCACHE_FILE_MODIFIED, $_SMARTCACHE_FILE_CACHED, $_SMARTCACHE_FILE_DELETED


; If we use lazyload or not
Func _SmartCache_lazyLoad()
	For $i = 1 To $_SMARTCACHE_RESOURCE[0][0]
		If $_SMARTCACHE_RESOURCE[$i][3] Then Return True ; Whenever at least 1 file has lazyload, we toggle yes
	Next
	Return False
EndFunc



Func _SmartCache_add(ByRef $sFilePath, ByRef $sData, ByRef $bLazyLoad)
	$_SMARTCACHE_RESOURCE[0][0]+=1
	ReDim $_SMARTCACHE_RESOURCE[$_SMARTCACHE_RESOURCE[0][0] + 1][4]
	$_SMARTCACHE_RESOURCE[$_SMARTCACHE_RESOURCE[0][0]][0] = $sFilePath
	$_SMARTCACHE_RESOURCE[$_SMARTCACHE_RESOURCE[0][0]][1] = FileGetTime($sFilePath, $FT_MODIFIED, $FT_STRING)
	$_SMARTCACHE_RESOURCE[$_SMARTCACHE_RESOURCE[0][0]][2] = $sData
	$_SMARTCACHE_RESOURCE[$_SMARTCACHE_RESOURCE[0][0]][3] = $bLazyLoad
	; Reset state
	$_SMARTCACHE_FILE_STATE = Null
	$_SMARTCACHE_FILE_ID = Null
EndFunc

; Update a previous chached data, and returns the new data
Func _SmartCache_update(ByRef $sFilePath, ByRef $sData, ByRef $bLazyLoad)
	$_SMARTCACHE_RESOURCE[$_SMARTCACHE_FILE_ID][0] = $sFilePath
	$_SMARTCACHE_RESOURCE[$_SMARTCACHE_FILE_ID][1] = FileGetTime($sFilePath, $FT_MODIFIED, $FT_STRING)
	$_SMARTCACHE_RESOURCE[$_SMARTCACHE_FILE_ID][2] = $sData
	$_SMARTCACHE_RESOURCE[$_SMARTCACHE_FILE_ID][3] = $bLazyLoad
	; Reset state
	$_SMARTCACHE_FILE_STATE = Null
	$_SMARTCACHE_FILE_ID = Null
EndFunc

Func _SmartCache_hasPerfectCache(ByRef $sFilePath, ByRef $sBaseDir); The file bein parsed has also be in the cluster
	Local $hits = 0, $scope_hits = 0

	For $i = 1 To $_SMARTCACHE_RESOURCE[0][0]
		; Parse files only in our scope scope_total has to be the same as HITS for this to work

		Local $sCurFile = $_SMARTCACHE_RESOURCE[$i][0]
		if StringInStr($sCurFile, $sBaseDir) Then
			$scope_hits+=1
			If $_SMARTCACHE_RESOURCE[$i][1] == FileGetTime($sCurFile, $FT_MODIFIED, $FT_STRING) Then $hits+=1; perfect hit
		EndIf

	Next

	$_SMARTCACHE_PERFECT_CACHE = $scope_hits == $hits And $scope_hits > 0
	Return $_SMARTCACHE_PERFECT_CACHE
EndFunc
; Delete
Func _SmartCache_remove()
	If $_SMARTCACHE_FILE_ID Then
		$_SMARTCACHE_RESOURCE[0][0]-=1
		_ArrayDelete($_SMARTCACHE_RESOURCE, $_SMARTCACHE_FILE_ID)
		; Reset state
		$_SMARTCACHE_FILE_STATE = Null
		$_SMARTCACHE_FILE_ID = Null
	EndIf
EndFunc

Func _SmartCache_getFileStatus(ByRef $sFilePath)
	if not FileExists($sFilePath) Then
		$_SMARTCACHE_FILE_STATE = $_SMARTCACHE_FILE_DELETED
		Return False
	EndIf
	Local $lazyLoadDream = False; prevent on\off toggle
	For $i = 1 To $_SMARTCACHE_RESOURCE[0][0]

		If $_SMARTCACHE_RESOURCE[$i][0] == $sFilePath Then

			$_SMARTCACHE_FILE_ID = $i; Save id

			If FileGetTime($sFilePath, $FT_MODIFIED, $FT_STRING) <> $_SMARTCACHE_RESOURCE[$i][1] Then
				$_SMARTCACHE_FILE_STATE = $_SMARTCACHE_FILE_MODIFIED
				Return True
			Else
				$_SMARTCACHE_FILE_STATE = $_SMARTCACHE_FILE_CACHED
				Return True
			EndIf
		EndIf
	Next
	$_SMARTCACHE_FILE_STATE = $_SMARTCACHE_FILE_NOT_CACHED
	Return False
EndFunc

Func _SmartCache_getCachedData(ByRef $sData)
	$sData = $_SMARTCACHE_RESOURCE[$_SMARTCACHE_FILE_ID][2]
	; Reset state
	$_SMARTCACHE_FILE_STATE = Null
	$_SMARTCACHE_FILE_ID = Null
EndFunc

Func _SmartCache_resetCache(); For options, give the user some powah
	_Array_Empty($_SMARTCACHE_RESOURCE)
	$_SMARTCACHE_FILE_STATE = Null
	$_SMARTCACHE_FILE_ID = Null
EndFunc