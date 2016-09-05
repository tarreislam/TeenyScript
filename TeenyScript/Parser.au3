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
Func _TS_YeahDnoWhatThisShouldbeNamed();[0] = $sAu3FileName, [1] = $sFileName
	_TS_HotkeyManager(False)
	Local Const $try = _TS_Compile(_SciTe_getOpenFileName())

	If _TS_Error() Then
		_TS_HotkeyManager(True)
		Return _TS_DisplayError()
	EndIf

	_TS_HotkeyManager(True)
	Return $try
EndFunc

; This should only save the file in _ALL_ cases
Func _TS_Compile($sFileName);[0] = $sAu3FileName, [1] = $sFileName

	_TS_ResetError(); Reset prev set errors

	If Not StringRegExp($sFileName, $re_TS_fileExt) Then Return _TS_SetError(1, 0, 0, "'%s' does not qualify with the %s file extension '.ts.au3'", $sFileName, $_TS_AppTitle); Not a valid Ts.au3 extension (Or not saved)
	If Not FileExists($sFileName) Then Return _TS_SetError(2, 0, 0, "The file '%s' does not exist", $sFileName); File does not exist

	; Reset resources
	_TS_ResetResources()

	; Get the TS > Au3 converted data
	; check if we have PURFECT data

	; This is our execution dir
	$_resource_sExecFile = getFromFilepath_basedir($sFileName)
	_SmartCache_hasPerfectCache($sFileName, $_resource_sExecFile)

	; Load ness info
	Local $aFileInfo = getFromFilepath_all_asArray($sFileName); C:\x\x\x.ts.au3
	Local $getFromFilepath_basedir = $aFileInfo[0]
	$aFileInfo[1] = StringRegExpReplace($aFileInfo[1], "(.*)\.ts", "$1")

	; ~ New file name c:\x\x.ts -> c:\x\x.au3 (Actual file) (If we need to open dir)
	Local Const $sAu3FileName = StringFormat("%s\%s.au3", $getFromFilepath_basedir, $aFileInfo[1]); The destination of the file when we are compiling to .au3
	Local Const $sAu3FileName_TMP = StringFormat("%s\%s.au3", @TempDir, $aFileInfo[1]); The file used when we are running and using cache
	Local Const $_TS_ProjectFile = StringFormat($_TS_Project_FilePatt, $getFromFilepath_basedir)
	Local $oProject = _TS_Project_getSettings($_TS_ProjectFile, $getFromFilepath_basedir)

	; if not perfect cache
	If Not $_SMARTCACHE_PERFECT_CACHE Then
		_TS_Namespace_GetAll($_resource_sExecFile); Get all namespaces
		Local Const $aNew_ts_2_au3_File = _TS_ParseFile($sFileName, $sFileName);Returns [0] = Full file path, [1] = Parsed content of file(s)
		If _TS_Error() Then Return False; This is nuff
		; Create the new file (If not on full cache spree)

		Local const $fHandle = FileOpen($sAu3FileName_TMP, $FO_OVERWRITE)
		if $fHandle == -1 Then Return _TS_SetError(4, 0, 0, "Failed to open '%s' for '$FO_OVERWRITE'", $sAu3FileName_TMP); Failed to open filehandle with Append \overwrite
		; Append Opt options
		; if $opt....
		; Append LazyLoded content if we are using AO
		If $_resource_bLazyLoad Then
			FileWrite($fHandle, $_TS_LazyLoadedContent)
		EndIf
		FileWrite($fHandle, $_resource_ffBuffer);
		FileWriteLine($fHandle, $_resource_ffDebug); Write the DEBUG data (ONLY on RUN)
		FileClose($fHandle)
	EndIf

	Local $aRet = [$sAu3FileName, $sAu3FileName_TMP, $sFileName, $oProject]
	Return $aRet
EndFunc

;$sPrevFileName is so we can get the relative path for includes working correctly
Func _TS_ParseFile(ByRef $sFileName, $sPrevFileName = False)

	$sCurrentFileBuffer = FileRead($sFileName)

	; Remove one line commetns and comments blocks (This has to be done before the CRLF replacement, else it bugs out :(
	$sCurrentFileBuffer = StringRegExpReplace($sCurrentFileBuffer, $re_Comment_OneLine, '\1')

	Local $sCurrentFileBuffer = StringReplace(FileRead($sFileName), @CRLF, @LF)
	Local $sCurFileBuffer = ""; each file's data

	; if THE this is the first iteration (We can check that by looking if $sFileName and $sPrevFilename is the same)
	If $sFileName == $sPrevFileName Then

		Local $aRe_TS_Debug = StringRegExp($sCurrentFileBuffer, $re_TS_Debug, 3)
		If IsArray($aRe_TS_Debug) Then $_resource_ffDebug =  $aRe_TS_Debug[0] ; Save #DEBUG
	EndIf

	; Look for #includes before continuing parsing
	_TS_Compose_Include_Rec($sCurrentFileBuffer, $sFileName, $sPrevFilename, $sCurFileBuffer)

	; Use smartcache, to set\get file content to memory
	_SmartCache_getFileStatus($sFileName)

	Switch $_SMARTCACHE_FILE_STATE
		Case $_SMARTCACHE_FILE_NOT_CACHED, $_SMARTCACHE_FILE_MODIFIED

			; Remove comment blocks #cs #ce
			$sCurrentFileBuffer = StringRegExpReplace($sCurrentFileBuffer, $re_Comment_Block, "")

			; Regular namespace (Dont save to global)
			Local $oNamespace = _TS_File_Namespace_get($sCurrentFileBuffer, $sFileName, False); This will run for EVERY file
			; Alias namespaces
			Local $aAliasNamespaces  = _TS_Func_getNamespaceAlias($sCurrentFileBuffer); new (Should be unique for each file) ; This will run for EVERY file


			If _TS_Error() Then Return

			Local $oPrev = Null
			$_resource_iFileId+=1;Incr file id
			_TS_Compose($sCurrentFileBuffer, $oPrev, $oNamespace, $sFileName, $aAliasNamespaces, $sCurFileBuffer) ; Null parent + izGlobal
			_TS_File_setNamespace_global($sCurFileBuffer); Go thru all namespaces and replace them for this file ( All namespaces catched on first file)

			Switch $_SMARTCACHE_FILE_STATE
				Case $_SMARTCACHE_FILE_NOT_CACHED
					_SmartCache_add($sFileName, $sCurFileBuffer, $_resource_bLazyLoad)
				Case $_SMARTCACHE_FILE_MODIFIED
					_SmartCache_update($sFileName, $sCurFileBuffer, $_resource_bLazyLoad)
			EndSwitch

		Case $_SMARTCACHE_FILE_CACHED
		_SmartCache_getCachedData($sCurFileBuffer)
	EndSwitch

	; Save complete file
	$_resource_ffBuffer &= $sCurFileBuffer
	$sCurFileBuffer = ""; reset for the current file

	; Update lazyload when file is complete
	If $sFileName == $sPrevFileName Then
		$_resource_bLazyLoad = _SmartCache_lazyLoad(); Update lazyload
	EndIf
EndFunc

; For recursive parsing with (#include x)
Func _TS_Compose_Include_Rec(Const $sCurrentFileBuffer, ByRef $sFileName, $sPrevFileName, ByRef $sCurFileBuffer)
	Local $aRe_TS_Include = StringRegExp($sCurrentFileBuffer, $re_TS_Include, 3)

		if IsArray($aRe_TS_Include) Then
			;Get info about the filepath
			Local Const $sFileNameInfo = getFromFilepath_all_asArray($sFileName)
			Local Const $sFileName_relative_path = $sFileNameInfo[0], $sFileName_actual_name = $sFileNameInfo[1], $sFileName_actual_ext = $sFileNameInfo[2]

			For $i = 0 To UBound($aRe_TS_Include) - 1 Step +2
				Local $aRe_TS_CurFile = StringReplace($aRe_TS_Include[$i], "/", "\"); Bcuz we allow forward slashes for includes, we get punished
				Local $aRe_TS_CurExt = $aRe_TS_Include[$i + 1]
				;MsgBox(0,0,$aRe_TS_CurFile & @CRLF & $sFileName_relative_path)


				Switch $aRe_TS_CurExt
					Case '.au3'
						; Determine similar POP but only on the actual name this time
						;If StringLeft($aRe_TS_CurFile, 1) == "\" Then $aRe_TS_CurFile = StringRegExpReplace($aRe_TS_CurFile, "(.*)\\.*", "$1")
						;MsgBox(0,"What we goin 4",getFromFilepath_basedir($sPrevFileName) & @CRLF & $sFileName & @CRLF &  $sFileName_relative_path& @CRLF &$aRe_TS_CurFile)
						if FileExists(StringFormat("%s\%s", $_AU3_INCLUDE_DIR, $aRe_TS_CurFile)) Then
							; Include as it is (No sub dir)
							$sCurFileBuffer &= StringFormat($_TS_Debug, StringFormat("%s\%s", $_AU3_INCLUDE_DIR, $aRe_TS_CurFile), "Unkown", "Unkown", "Unkown") & @CRLF & _
							StringFormat("#Include <%s>", $aRe_TS_CurFile) & @CRLF

						ElseIf FileExists(StringFormat("%s\%s", $sFileName_relative_path, $aRe_TS_CurFile)) Then
							;Include with relative dir from the file that is bein run
							Local $sRelativePathAu3 = StringReplace($sFileName_relative_path & "\", "\" & getFromFilepath_basedir($sPrevFileName), "")

							$sCurFileBuffer &= StringFormat($_TS_Debug, StringFormat("%s\%s", $sFileName_relative_path, $aRe_TS_CurFile), "Unkown", "Unkown", "Unkown")  & @CRLF & _
							StringFormat("#Include <%s%s>", $sRelativePathAu3, $aRe_TS_CurFile) & @CRLF
						Else
							Return _TS_SetError(2, 0, 0, "The file '%s' was not found in @ScriptDir\... or in Au3\Includes\...", $aRe_TS_CurFile)
						EndIf
						ContinueLoop;
					Case '.ts'
						; Determine if we are going to POP the last directory (ONLY TS since they r accesed through their full path).

						Local $prevDirTry = StringRegExp($aRe_TS_CurFile, "^([\\]{1,2})", 3)
						Local $aRe_TS_CurFile_TS

						If IsArray($prevDirTry) Then
							Switch $prevDirTry[0]
								Case "\"
									$aRe_TS_CurFile_TS = StringFormat("%s\%s.au3", getFromFilepath_basedir($sFileName_relative_path), $aRe_TS_CurFile)
								Case "\\"
									$aRe_TS_CurFile_TS = StringFormat("%s\%s.au3", $_resource_sExecFile, $aRe_TS_CurFile)
							EndSwitch
						Else
							$aRe_TS_CurFile_TS = StringFormat("%s\%s.au3", $sFileName_relative_path, $aRe_TS_CurFile)
						EndIf

						If StringLeft($aRe_TS_CurFile, 1) == "\" Then
							; Will pop the last dir "\" since no (filename.ext) is given
							$aRe_TS_CurFile_TS = StringFormat("%s\%s.au3", getFromFilepath_basedir($sFileName_relative_path), $aRe_TS_CurFile)
						Else
							$aRe_TS_CurFile_TS = StringFormat("%s\%s.au3", $sFileName_relative_path, $aRe_TS_CurFile)
						EndIf

						; Parse the file. Will always use the parent relative path. (Yeah, it will support include of include etc
						If Not FileExists($aRe_TS_CurFile_TS) Then Return _TS_SetError(3, 0, 0, "The %s file '%s' was not found", $_TS_AppTitle, $aRe_TS_CurFile_TS)
						_TS_ParseFile($aRe_TS_CurFile_TS, $sFileName); Passing the current as "Previous"
						If _TS_Error() Then Return _TS_SetError(4, 0, 0, "(Recursive) Unable to parse the file '%s'", $aRe_TS_CurFile_TS)
					Case Else
						If $aRe_TS_CurExt == '*.ts' Or $aRe_TS_CurExt == '**.ts' Then

							;Prev dir recur (Gör samma med den över BROR /DullI@ZZ)

							Local $prevDirTry = StringRegExp($aRe_TS_CurFile, "^([\\]{1,2})", 3)
							Local $_FileListToArrayRec_sPath

							if IsArray($prevDirTry) Then
								Switch $prevDirTry[0]
									Case "\"; Just go to prev dir
										$_FileListToArrayRec_sPath = getFromFilepath_basedir($sFileName_relative_path) & getFromFilepath_basedir($aRe_TS_CurFile)

									Case "\\"; Go to exec dir
										$_FileListToArrayRec_sPath = $_resource_sExecFile & StringTrimLeft(getFromFilepath_basedir($aRe_TS_CurFile), 1)
								EndSwitch
							Else
								$_FileListToArrayRec_sPath = StringFormat("%s\%s", $sFileName_relative_path, getFromFilepath_basedir($aRe_TS_CurFile))
							EndIf

							Local $_FileListToArrayRec = _FileListToArrayRec($_FileListToArrayRec_sPath, "*.ts.au3||BackUp", $FLTAR_FILES, ($aRe_TS_CurExt == '*.ts' ? $FLTAR_NORECUR : $FLTAR_RECUR), $FLTAR_NOSORT, $FLTAR_FULLPATH)


							If @error Then
								Switch @error
									Case 1
										Return _TS_SetError(5, 0, 0, "The folder '%s' is empty or does not exist", $sFileName_relative_path)

									Case 9
										Return _TS_SetError(7, 0, 0, "The folder '%s' does not contain any files or folders", $sFileName_relative_path)
								EndSwitch
							Else
								For $j = 1 To $_FileListToArrayRec[0]

									;If current file is the same as the previous then an endless loop has happend
									if $_FileListToArrayRec[$j] == $sPrevFileName Then Return _TS_SetError(7, 0 ,0, "_FileListToArrayRec Endless loop detected '%s' == '%s', aborting...", $_FileListToArrayRec[$j], $sPrevFileName)
									_TS_ParseFile($_FileListToArrayRec[$j], $sFileName)
									If _TS_Error() Then ExitLoop
								Next
							EndIf
						EndIf
						; ** och * här..
				EndSwitch
			Next
		EndIf
EndFunc

; ~ All End-of-func-hell Features. lists, enahnchments, arrays, you name it, that should be here. all kind of parameters can be thrown in here for  stuff
Func _TS_Compose_Features(ByRef $oCur, ByRef $aAliasNamespaces, ByRef $oNamespace, ByRef $oPrev, ByRef $sCurFileBuffer)
	; Array Enhanchments
	_TS_Compose_Arrays($oCur)
	; For In Enhanchments
	_TS_Compose_For_In($oCur)

	; Self::
	_TS_Func_setNamespace_self($oCur)
	; Closures
	_TS_Compose_Closure($oCur, $sCurFileBuffer)
	; Set alias namespaces
	_TS_Func_setNamespaceAlias_local($oCur, $aAliasNamespaces)
	; @Methodname, @Methodparams, @Namespace
	_TS_Compose_Macro_Misc($oCur, $oNamespace)
	; { Lists }
	_TS_Compose_Lists($oCur)
	; Heredoc (<<<) ... (>>>)
	_TS_Compose_Heredoc($oCur)
EndFunc

#Region Features

#Region Au3 Enhancements

; Mixed array enhanc
Func _TS_Compose_Arrays(ByRef $oCur)
	; They can all share the same counter
	Local $i = 0
	; ~ Ez array
	; Return [1,2,3,5]
	$oCur.content = StringRegExpReplace($oCur.content, $re_array_ezArray, StringFormat("Local $%s = $1" & @CRLF & "Return $%s", $_name_ezArray & $i, $_name_ezArray & $i))

	; Func([1,2,3])
	Do
		$oCur.content = StringRegExpReplace($oCur.content, $re_array_ezArrayClosure, StringFormat("Local $%s = $2" & @CRLF & "$1$%s$3", $_name_ezArray & $i, $_name_ezArray & $i), 0)
		$i+=1
	Until Not @extended

EndFunc

; ~ For X IN (Y) enanch
Func _TS_Compose_For_In(ByRef $oCur)

	; For $x in ~mixed~ Enhancement
	Local $i = 0
	Do
		$oCur.content = StringRegExpReplace($oCur.content, $re_Au3Enhancement_ForIn, StringFormat("Local Const $%s = $2" & @CRLF & "For $1 In $%s", $_name_Au3Enhancement_ForIn & $i, $_name_Au3Enhancement_ForIn & $i))
		$i+=1
	Until Not @extended

EndFunc

#EndRegion

#Region Closures
Func _TS_Compose_Closure(ByRef $oCur, ByRef $sCurFileBuffer); $gg.test(func() .... (EndFunc))
	Local $aRe_func_closure = StringRegExp($oCur.content, $re_func_closure, 3), $aRe_func_closure_len = UBound($aRe_func_closure), $sClosureFuncs, $sClosureName

	if Not $aRe_func_closure_len Then Return

	For $i = 0 To $aRe_func_closure_len - 1 Step +3
		$sClosureName = StringFormat("%s%d", $_name_Closure, $_resource_clousreCount)
		$_resource_clousreCount+=1

			$sClosureFuncs &= StringFormat("Func %s(%s)", $sClosureName, $aRe_func_closure[$i + 1]) & @CRLF & _
			$aRe_func_closure[$i + 2] & @CRLF & _
			"EndFunc" & @CRLF

			$oCur.content = StringRegExpReplace($oCur.content, $re_func_closure, StringFormat("$1 %s", $sClosureName), 1)
	Next
	; Append to ffBuffer (Si seniorita)
	$sCurFileBuffer &= $sClosureFuncs
EndFunc
#EndRegion Closures

#Region Heredoc
Func _TS_Compose_Heredoc(ByRef $oCur); (<<<)....(>>>>)
	Local $aRe_heredoc_content = StringRegExp($oCur.content, $re_heredoc_content, 3)

	If IsArray($aRe_heredoc_content) Then
		For $i = 0 to UBound($aRe_heredoc_content) - 1
			Local $Cur = StringReplace($aRe_heredoc_content[$i], "'", '"'), $aNewCnt = ""
			; Fix the inString variables \".*\"
			$Cur = StringRegExpReplace($Cur, $re_heredoc_variables, '" & $1 & "')
			; Parse the string as we want
			Local $aEodCnt = StringSplit($Cur, @LF)


			For $y = 1 To $aEodCnt[0]
				Local $content = $aEodCnt[$y]
				If $y = $aEodCnt[0] Then
					$aNewCnt &= $content
				Else
					$aNewCnt &= $content & " & @CRLF & "
				EndIf
			Next

			; Replace it with our new data
			$oCur.content = StringRegExpReplace($oCur.content, $re_heredoc_content, $aNewCnt, 1)
		Next
	EndIf

EndFunc
#EndRegion

#Region Macro related
Func _TS_Compose_Macro_Misc(ByRef $oCur, ByRef $oNamespace); @Methodparams @Namespace, @Extends etc...
	$oCur.content = StringRegExpReplace($oCur.content, $re_macro_getNamespace, StringFormat("'%s'", $oNamespace.raw))
	$oCur.content = StringRegExpReplace($oCur.content, $re_macro_getMethodName, StringFormat("'%s'", $oCur.cleanName))
	$oCur.content = StringRegExpReplace($oCur.content, $re_macro_getMethodParams, StringFormat("'%s'", $oCur.params))
	If $oCur.isClass Or $oCur.isExtension Then
		Local Const $aRe_macro_useExtension = StringRegExp($oCur.content, $re_macro_useExtension, 3)
		If IsArray($aRe_macro_useExtension) Then
			; Detect if namespaced are used or not
			If isEmpty($aRe_macro_useExtension[0]) Then
				$oCur.content = StringRegExpReplace($oCur.content, $re_macro_useExtension, StringFormat("$$2($%s)", $_name_AOClass))
			Else
				$oCur.content = StringRegExpReplace($oCur.content, $re_macro_useExtension, StringFormat("$1$$2($%s)", $_name_AOClass))
			EndIf
		EndIf
	EndIf
EndFunc
#EndRegion

#Region _TS_Compose_Lists_*

Func _TS_Compose_Lists(ByRef $oCur); {}
	; Brand new list
	Local $aRe_list_create = StringRegExp($oCur.content, $re_list_create, 3), $aRe_list_create_len = UBound($aRe_list_create)

	For $i = 0 To $aRe_list_create_len - 1 Step + 2
		; Check if are going to MultiAssign from this creation
		Local $sListBuffer = _TS_Compose_Lists_MultiAssignByContent($oCur, $aRe_list_create[$i], $aRe_list_create[$i + 1])
		; Do the actual replace after we parse each inner value so we dont get OOP (Out of position)
		$oCur.content = StringRegExpReplace($oCur.content, $re_list_create, "$$1 = _AutoItObject_Create()" & $sListBuffer, 1)
	Next

	; Set
	Local $aRe_list_set = StringRegExp($oCur.content, $re_list_set, 3), $aRe_list_set_len = UBound($aRe_list_set)
	Local $Re2Use = ""
	For $i = 0 To $aRe_list_set_len - 1 Step + 3
		Local $identifier = $aRe_list_set[$i]
		Local $Key = $aRe_list_set[$i + 1]
		Local $Val = $aRe_list_set[$i + 2]

		; Throw error if KEY is containing bogus stuff
		If Not StringRegExp(StringRegExpReplace($Key, '\"(.*)\"', "$1"), $re_parseErr_listKey) Then
			Return _TS_SetError(1, 0, 0, "[_TS_Compose_Lists]: %s, Error parsing list key '%s'. List keys may only contain a-z, 0-9 and _ or $Variables", _TS_Func_TraceCurRefs($oCur), $Key)
		EndIf

		If StringRegExp($identifier, "\.") Then ; Detect $var.etc and create a fake var
			Local $fakeVar = $_name_List & $i
			$Re2Use = "" & _
			StringFormat("Local $%s = $%s", $fakeVar, $aRe_list_set[$i]) & @CRLF & _
			StringFormat("_AutoItObject_AddProperty($%s, $2, $ELSCOPE_PUBLIC, $3)", $fakeVar)
		Else
			$Re2Use = "_AutoItObject_AddProperty($$1, $2, $ELSCOPE_PUBLIC, $3)" ; Default
		EndIf

		$oCur.content = StringRegExpReplace($oCur.content, $re_list_set, $Re2Use, 1)

	Next
	; Get (the one with execute)
	; We go through each and one. so we can translate $list{"key"} to "$list.key", but keep $list{$key} as "Execute('$list.' & $key)"
	Local $aRe_list_get = StringRegExp($oCur.content, $re_list_get, 3), $aRe_list_get_len = UBound($aRe_list_get), $re2Use = ""

	For $i = 0 to $aRe_list_get_len - 1 Step + 2

		Local $key = $aRe_list_get[$i + 1]

		If Not StringRegExp(StringRegExpReplace($Key, '\"(.*)\"', "$1"), $re_parseErr_listKey) Then
			Return _TS_SetError(1, 0, 0, "[_TS_Compose_Lists]: %s, Error parsing list key '%s'. List keys may only contain a-z, 0-9 and _ or $Variables", _TS_Func_TraceCurRefs($oCur), $Key)
		EndIf
		; Check if key has to start with " and end with "
		Local $ciS = StringRegExp($key, "^(?:(?:" & '\"' & "|\')(.*)(?:" & '\"' & "|\'))", 3)

		; This will help us not use Execute on signle strings
		if IsArray($ciS) Then
			$re2Use = "$$1." & $ciS[0]
		Else
			$re2Use = "Execute('$$1.' & $2)"
		EndIf

		$oCur.content = StringRegExpReplace($oCur.content, $re_list_get, $re2Use, 1)
	Next

	; Indicate that we need AutoitObject
	If $aRe_list_create_len Or $aRe_list_set_len Or $aRe_list_get_len Then $_resource_bLazyLoad = True
EndFunc

; ~ Will create the structure of a listview
Func _TS_Compose_Lists_MultiAssignByContent(ByRef $oCur, ByRef $name, ByRef $content);
	If Not StringLen($content) Then Return ""
	Local $aRe_list_createKeyval = StringRegExp($content, $re_list_multiAssign, 3)
	Local $sListBuffer = ""

	For $j = 0 To UBound($aRe_list_createKeyval) - 1 Step +2
		Local $Key = $aRe_list_createKeyval[$j]
		Local $Val = $aRe_list_createKeyval[$j + 1]
		 ;Throw error if KEY is containing bogus stuff
		 If Not StringRegExp(StringRegExpReplace($Key, '\"(.*)\"', "$1"), $re_parseErr_listKey) Then
			 Return _TS_SetError(1, 0, 0, "[_TS_Compose_Lists_MultiAssignByContent]: %s, Error parsing list key '%s'. List keys may only contain a-z, 0-9 and _ or $Variables", _TS_Func_TraceCurRefs($oCur), $Key)
		 EndIf

		$sListBuffer &= @CRLF & StringFormat("_AutoItObject_AddProperty($%s, %s, $ELSCOPE_PUBLIC, %s)", $name, $Key, $Val)
	Next

	Return $sListBuffer
EndFunc
#EndRegion _TS_Compose_Lists_*

#EndRegion

#Region Namespace related
; internal (cus DRY)
Func _TS_Namespace_Parse(ByRef $aRe_macro_setNamespace, ByRef $sFileName)

	if IsArray($aRe_macro_setNamespace) Then
		Local $raw = $aRe_macro_setNamespace[0]

		Local $clean = StringReplace($raw, "/", "_") & "_"

		; look for, replace with, raw, filepath, clean
		Local $aResource = [$raw & "::$", "$" & $clean, $raw, $sFileName, $clean]
		Return $aResource
	EndIf

	Return Null

EndFunc
; Grab _ALL_ namespaces and check for errors, before the actual parse begings
Func _TS_Namespace_GetAll(ByRef $sInitDir); should only be done when _FIRST_ file is messed with (sExecDir pref)
	$_FileListToArrayRec = _FileListToArrayRec($sInitDir, "*.ts.au3||Backup", $FLTAR_FILES, $FLTAR_RECUR, $FLTAR_NOSORT,$FLTAR_FULLPATH)

	For $i = 1 To $_FileListToArrayRec[0]
		Local $sFileName = $_FileListToArrayRec[$i]
		Local $sFileContent = StringReplace(FileRead($sFileName), @CRLF, @LF)

		Local $aRe_macro_setNamespace = StringRegExp($sFileContent, $re_macro_setNamespace, 3)

		Local $_TS_Namespace_Parse = _TS_Namespace_Parse($aRe_macro_setNamespace, $sFileName); Grab finished namespace content

		; Check if namespace is already defined
		if IsArray($_TS_Namespace_Parse) Then
			; Check if namespace implementation was OK
			If StringRegExp($sFileContent, $re_macro_setNamespace) Then
				If Not StringRegExp(StringLeft(StringRegExpReplace($sFileContent, "\n+|\h+", ""), 10), $re_macro_getNamespace) Then
					_TS_SetError(1, 0, 0, "[_TS_ParseFile] Namespace needs to be assigned first @ '%s'", $sFileName)
				EndIf
			EndIf

			For $j = 1 To $_resource_aNamespaces[0]
				Local $c = $_resource_aNamespaces[$j]
				If $_TS_Namespace_Parse[2] == $c[2] Then Return _TS_SetError(1, 0, 0, "[_TS_Namespace_GetAll] The Namespace '%s' in '%s' is also defined in the file '%s' ", $_TS_Namespace_Parse[2], $sFileName, $c[3])
			Next
			;Push namespace usage to global resource
			_Array_Push($_resource_aNamespaces, $_TS_Namespace_Parse)
		EndIf
	Next

EndFunc

; ~ Get namespace from current file (Does not save anything) (Should access array later, but im so tierd and really wanna release this)
Func _TS_File_Namespace_get(ByRef $sFileBuffer, ByRef $sFileName, $bSaveGlobal = False); $bSave = push to global array of namespaces
	Local $aRe_macro_setNamespace = StringRegExp($sFileBuffer, $re_macro_setNamespace, 3)
	Local $oRet = _AutoitObject_Create(), $clean = "", $raw = ""; Store raw and good namespace
	Local $_TS_Namespace_Parse = _TS_Namespace_Parse($aRe_macro_setNamespace, $sFileName)

	If IsArray($_TS_Namespace_Parse) Then
		$raw = $_TS_Namespace_Parse[2]; raw (NOT look for)
		$clean = $_TS_Namespace_Parse[4]; clean (NOT replace with)
	EndIf

	; Return the current namespace for this file (Classes etc)
	_AutoitObject_AddProperty($oRet, "raw", $ELSCOPE_PUBLIC, $raw)
	_AutoitObject_AddProperty($oRet, "clean", $ELSCOPE_PUBLIC, $clean)

	Return $oRet
EndFunc

; Will look for all global namespaces and replace them (This does not affect Namespace aliases)
Func _TS_File_setNamespace_global(ByRef $desired_buffer)

	Local $curNamespaceStorage

	For $i = 0 To $_resource_aNamespaces[0]
		$curNamespaceStorage = $_resource_aNamespaces[$i]
		If IsArray($curNamespaceStorage) Then; For functions without namespaces
			Local $lookFor = $curNamespaceStorage[0], $replaceWith = $curNamespaceStorage[1]
			$desired_buffer = StringReplace($desired_buffer, $lookFor, $replaceWith)
		EndIf
	Next

EndFunc
; ~ Looks for @Use X in Y in Namespace scope, but replaces localy _ONLY_
Func _TS_Func_getNamespaceAlias(ByRef $sFileBuffer)
	Local $aRe_macro_useNamespace = StringRegExp($sFileBuffer, $re_macro_useNamespace, 3), $aRe_macro_useNamespace_len = UBound($aRe_macro_useNamespace)
	Local $aAliasNamespaces[1] = [0]

	If $aRe_macro_useNamespace_len Then
		;$sFileBuffer = StringRegExpReplace($sFileBuffer, $re_macro_useNamespace, ""); Not needed

		Local $lookFor, $replaceWith

		For $i = 0 To $aRe_macro_useNamespace_len - 1 Step + 2
			; This is a expensive regex.
			$lookFor = StringFormat("([^\/])%s::\$", $aRe_macro_useNamespace[$i + 1])
			$replaceWith = StringFormat("$1%s::$", $aRe_macro_useNamespace[$i])

			Local $aMatchArr = [$lookFor, $replaceWith]
			_Array_Push($aAliasNamespaces, $aMatchArr); now needs regexreplace instead of stringreplace

		Next
	EndIf

	Return $aAliasNamespaces

EndFunc

; ~ Set the namespace locally (dosent even have to be done here, it just is here atm)
Func _TS_Func_setNamespaceAlias_local(ByRef $oCur, ByRef $aAliasNamespaces); After treatment
	For $i = 1 To $aAliasNamespaces[0]
		Local $cur = $aAliasNamespaces[$i]
		Local $lookFor = $cur[0], $replaceWith = $cur[1]

		$oCur.content = StringRegExpReplace($oCur.content, $lookFor, $replaceWith)
	Next
EndFunc

; ~ Almost the same as @Use x In y, but only converts it to the current Namespace Self::$uDiiig?
Func _TS_Func_setNamespace_self(ByRef $oCur)
	; Throw error if no namespace

	If StringRegExp($oCur.content, $re_parseErr_self) And isEmpty($oCur.oNamespace.Raw) Then
		Return _TS_SetError(1, 0, 0, "[_TS_Func_setNamespace_self] self:: cannot be used when not working under a @Namespace", _TS_Func_TraceCurRefs($oCur, $oCur.cleanName))
	EndIf
	$oCur.content = StringRegExpReplace($oCur.content, $re_keyword_setNamspaceSelf, StringFormat("%s::$1", $oCur.oNamespace.Raw))
EndFunc
#EndRegion

; Strukturerar upp alla funktioner. Allt annat får en egen loop
;TS_DEBUG=A:A:A:A
Func _TS_Compose($sFileBuffer, ByRef $oPrev, ByRef $oNamespace, ByRef $sFileName, ByRef $aAliasNamespaces, ByRef $sCurFileBuffer)
	If _TS_Error() Then Return False; Abort operation if error is set. This is placed here to prevent unneccesary executions
	; Grab one layer
	Local $aParents = _TS_Func_GetNested($sFileBuffer), $oCur

	For $i = 1 To $aParents[0]
		; Current Parent
		$oCur = $aParents[$i]

		; Assign current's parent
		$oCur.parent = $oPrev

		; Assign some refs
		$oCur.sFileName = $sFileName
		$oCur.oNamespace = $oNamespace

		; If not in hierarchy hell. we are in the global scope
		$oCur.IsGlobal = Not IsObj($oPrev)


		; Grab children from current
		Local $oChildrenOfCur = _TS_Func_GetNested($oCur.content)

		; Get name Hierarchy so we can properly nest the function names according to its parent
		Local $sParentFunctionNamePrefix = $_name_Function & "_" & $_resource_iFileId & "_" & _TS_Func_GetNameHierarchy($oPrev)
		; ezy as ABC
		Local $sContent = "", $sContentSuffix = "", $sContentPrefix = ""

		; How to handle content with children
		If $oChildrenOfCur[0] > 0 Then
			; If class, we dont touch the .content . They will be forced to use the constructor
			If $oCur.isClass Or $oCur.isExtension Then
				_TS_Func_Compose_Class_Extension_Construct($oCur, $oChildrenOfCur, $sContent, $sParentFunctionNamePrefix)
			Else
				; Since its not a class. StringRegexpReplace is used.
				$sContent &= StringRegExpReplace($oCur.content, $re_func_getNested, StringFormat("Local $2 %s%s_$3$7", $sParentFunctionNamePrefix, $oCur.cleanName))
				_TS_Compose_Features($oCur, $aAliasNamespaces, $oNamespace, $oPrev, $sCurFileBuffer)
			EndIf

		Else ; No children. Just run the feature method
			_TS_Compose_Features($oCur, $aAliasNamespaces, $oNamespace, $oPrev, $sCurFileBuffer)
			$sContent &= $oCur.content

		EndIf

		;/*
		;|--------------------------------------------------------------------------
		;| FinalFunctionx
		;|--------------------------------------------------------------------------
		;|
		;|	Adjusts parameters for nested functions according to their respective -
		;|	function
		;|
		;*/
		Local $final_params = ""; We dont want to change the p

		; ~ Constructors (Has to be before param modification)
		If $oCur.isConstructor Then
			; ~ Inherit params from parent
			$oCur.params = $oPrev.C_params
			; ~ Always return $_TS_ObjectName when declared as a constructor
			$sContentSuffix = StringFormat("Return $%s", $_TS_ObjectName)
		EndIf

		; ~ Class's
		If IsObj($oPrev) and $oPrev.isClass Then
			If Not isEmpty($oCur.params) Then
				$oCur.params = StringFormat("$%s, %s", $_TS_ObjectName, $oCur.params)
			Else
				$oCur.params = StringFormat("$%s", $_TS_ObjectName)
			EndIf
		EndIf


		; ~ Extensions
		If $oCur.isExtension Then
			If Not isEmpty($oCur.params) Then
				$oCur.params = StringFormat("$%s, %s", $_name_AOClass, $oCur.params)
			Else
				$oCur.params = StringFormat("$%s", $_name_AOClass)
			EndIf
		EndIf

		;/*
		;|--------------------------------------------------------------------------
		;| FinalFunction_parseClass
		;|--------------------------------------------------------------------------
		;|
		;|	Adds the AutoitObject to our regular AutoitFunction, both pre and after.
		;|	This also parses the constructor (if used)
		;|
		;*/

		If $oCur.isClass Then
			; ~ Parse properties and return a refrence array
			Local $aPropertyRefArray = _TS_Func_Compose_classProperties($oCur, $sContent)

			$sContentPrefix &= "" & _
					StringFormat('Local Const $%s = _AutoItObject_Class()', $_name_AOClass) & @CRLF & _
					StringFormat('Local Const $%s = %s', $_name_AOProperties, _TS_Func_getPropertyRefArray($aPropertyRefArray)) & @CRLF & _
					StringFormat('Local Const $%s = %s', $_name_AOMethods, _TS_Func_getMethodRefArray($oChildrenOfCur)) & @CRLF & _
					StringFormat('$%s.AddProperty("__Properties__", $ELSCOPE_READONLY, $%s)', $_name_AOClass, $_name_AOProperties) & @CRLF & _
					StringFormat('$%s.AddProperty("__Methods__", $ELSCOPE_READONLY, $%s)', $_name_AOClass, $_name_AOMethods) & @CRLF & _
					StringFormat('$%s.AddProperty("__Parent__", $ELSCOPE_PRIVATE, %s)', $_name_AOClass, (IsObj($oPrev) and $oPrev.isClass ? "$" & $_TS_ObjectName : 'NULL')) & @CRLF & _
					StringFormat('$%s.AddProperty("__cName__", $ELSCOPE_READONLY, "%s")', $_name_AOClass, $oCur.cleanName) & @CRLF & _
					StringFormat('$%s.AddProperty("__Namespace__", $ELSCOPE_READONLY, "%s")', $_name_AOClass, $oNamespace.raw)

			;|--------------------------
			;| Check if we are assigning this class with a constructor
			;|--------------------------
			If IsObj($oCur.oConstructor) Then
				Local $sStrippedParams = ""
				Local $aStrippedParams = StringRegExp($oCur.C_params, "(?i)\$" & $re_AcceptedVarName, 3)
				If IsArray($aStrippedParams) Then
					$sStrippedParams = _ArrayToString($aStrippedParams, ",")
				EndIf
				$sContentSuffix = StringFormat("Return $%s.Object.%s(%s)", $_name_AOClass, $oCur.oConstructor.CleanName, $sStrippedParams)
			Else
				$sContentSuffix = StringFormat("Return $%s.Object", $_name_AOClass)
			EndIf
		EndIf

		; Create the au3 function ($sContentPrefix, $sContent and $sContentSuffix are now FINAL
		Local $sFinalFunction = ($oCur.isGlobal ? StringFormat("Global Const $%s%s = %s%s%s", $oNamespace.clean, $oCur.cleanName, $sParentFunctionNamePrefix, $oCur.cleanName, $oCur.endFuncContent) & @CRLF : "") & _
				StringFormat("Func %s%s(%s)", $sParentFunctionNamePrefix, $oCur.cleanName, $oCur.params) & @CRLF & _
				$sContentPrefix & @CRLF & _
				$sContent & @CRLF & _
				$sContentSuffix & @CRLF & _
				"EndFunc" & @CRLF

			$sCurFileBuffer &= StringFormat($_TS_Debug, $sFileName, $oNamespace.raw, $oCur.cleanName, $oCur.paramsRaw) & @CRLF & $sFinalFunction

		; Go deeper in da file
		_TS_Compose($oCur.content, $oCur, $oNamespace, $sFileName, $aAliasNamespaces, $sCurFileBuffer)
	Next
	; Here i want to replace aliases?

EndFunc   ;==>_TS_Compose

; ~ Return the methods of our beloved children
Func _TS_Func_getMethodRefArray(ByRef $oChildrenOfCur)
	Local $sRet = StringFormat("[[%s,'Scope','Name','Parameters']", $oChildrenOfCur[0])
	if $oChildrenOfCur[0] == 0 Then Return "Null"
	For $i = 1 To $oChildrenOfCur[0]
		Local $item = $oChildrenOfCur[$i]
		$sRet &= StringFormat(",[%d,'%s','%s','%s']", $i, $item.keyword, $item.cleanName, StringReplace($item.params, "'", '"'))
	Next
	Return $sRet & "]"
EndFunc   ;==>_TS_Func_getMethodRefArray

; ~ Return the properties of the class
Func _TS_Func_getPropertyRefArray(ByRef $aPropertyRefArray)
	Local $aPropertyRefArray_len = UBound($aPropertyRefArray)
		if Not $aPropertyRefArray_len Then Return "Null";
		Local $sRet = StringFormat("[[%d,'Scope','Name','Default']", $aPropertyRefArray_len/3)

		Local $x = 1
		For $i = 0 To $aPropertyRefArray_len - 1 Step +3
			Local $cur = $aPropertyRefArray[$i]
			$sRet &= StringFormat(",[%d, '%s', '%s', '%s']", $x , $aPropertyRefArray[$i], $aPropertyRefArray[$i + 1], StringReplace($aPropertyRefArray[$i + 2], "'", '"'))
			$x+=1; since step +3 on $i
		Next

		Return $sRet & "]"
EndFunc

; ~ Will give proper content and information about classes, extensions and class-constructs
Func _TS_Func_Compose_Class_Extension_Construct(ByRef $oCur, ByRef $oChildrenOfCur, ByRef $sContent, ByRef $sParentFunctionNamePrefix)
	For $j = 1 To $oChildrenOfCur[0]
		Local $item = $oChildrenOfCur[$j], $item_scope = "$ELSCOPE_PUBLIC" ; Alias for the children of current x

		;|--------------------------
		;| Determine scope for class member
		;|--------------------------

		Switch $item.keyword
			Case "@Private"
				$item_scope = "$ELSCOPE_PRIVATE"
				$item.keyword = "Private" ; for MethodRef only (instead of stringregexpreplace)
			Case "@Public"
				$item_scope = "$ELSCOPE_PUBLIC"
				$item.keyword = "Public"
			Case "@Readonly"
				Return _TS_SetError(1, 0, 0, "[_TS_Func_Compose_Class_Extension_Construct]: %s may not utilize the '%s' keyword", _TS_Func_TraceCurRefs($oCur, $item.cleanName), $item.keyword)
			Case Else
				$item.keyword = "Public"
		EndSwitch

		;|--------------------------
		;| Check if child is a constructor
		;|--------------------------
		If $item.isConstructor And Not IsObj($oCur.oConstructor) Then

			If $oCur.isExtension Then
				; Throw TS error (May only be used within a class)
				Return _TS_SetError(2, 0, 0, "[_TS_Func_Compose_Class_Extension_Construct]: %s may only be used in a class function", _TS_Func_TraceCurRefs($oCur, $item.cleanName))
			EndIf

			If Not isEmpty($item.params) Then
				; Throw TS error (Params are inherited from the class)
				Return _TS_SetError(3, 0, 0, "[_TS_Func_Compose_Class_Extension_Construct]: %s may not be assigned with parameters, since they are inherited from the parent class function", _TS_Func_TraceCurRefs($oCur, $item.cleanName))
			EndIf

			If $item_scope <> "$ELSCOPE_PUBLIC" Then
				; Throw TS error (Must be public)
				Return _TS_SetError(4, 0, 0, "[_TS_Func_Compose_Class_Extension_Construct]: %s may only utilize the @Public keyword, '@%s' given", _TS_Func_TraceCurRefs($oCur, $item.cleanName), $item.keyword)
			EndIf

			; Save current $item to $oCurs constructor
			$oCur.oConstructor = $item

		ElseIf $item.isConstructor and IsObj($oCur.oConstructor) Then
			; Throw TS error (dupe constructor)
			Return _TS_SetError(5, 0, 0, "[_TS_Func_Compose_Class_Extension_Construct]: %s failed to assign construcor, since it already exists as '%s'", _TS_Func_TraceCurRefs($oCur, $item.cleanName), $oCur.oConstructor.CleanName)
		EndIf

		$sContent &= StringFormat("$%s.AddMethod('%s', '%s%s_%s', %s)", $_name_AOClass, $item.cleanName, $sParentFunctionNamePrefix, $oCur.cleanName, $item.cleanName, $item_scope) & @CRLF
	Next
EndFunc

; ~ Assign class and extension properties ( 80% from 1.x.x)
Func _TS_Func_Compose_classProperties(ByRef $oCur, ByRef $sContent); Also works on extensions

	Local $aProperties = StringRegExp($oCur.content, $re_func_properties, 3), $aProperties_len = UBound($aProperties)

	if Not $aProperties_len Then Return False

	Local $sRet, $sCur

	; [0] = @Type, [1] = $this.name, [2] value
	For $i = 0 To $aProperties_len - 1 Step + 3
		Local $sType = $aProperties[$i], $skey = $aProperties[$i + 1], $skeyNew, $sValue = $aProperties[$i + 2]

		Local $aRe_array_ClassProp = StringRegExp($sValue, $re_array_ClassProp, 3)
		Local $aRe_list_ClassProp = StringRegExp($sValue, $re_list_ClassProp, 3)

		If IsArray($aRe_array_ClassProp) Then ; If array
			; Alter Skey for this step
			$skeyNew = "a_" & $skey
			$sCur = "" & _
			StringFormat("Local $%s = %s", $skeyNew, $aRe_array_ClassProp[0]) & @CRLF & _
			StringFormat("$%s.AddProperty('$2',$ELSCOPE_$1, $a_$2)", $_name_AOClass)
		ElseIf IsArray($aRe_list_ClassProp) Then; If list
			; Alter Skey for this step
			$skeyNew = "o_" & $skey
			Local $listContent = _TS_Compose_Lists_MultiAssignByContent($oCur, $skeyNew, $aRe_list_ClassProp[0])
			if StringLen($listContent) Then
				$sCur  = "" & _
				StringFormat("Local $%s = %s", $skeyNew, '_AutoItObject_Create()') & _
				$listContent & @CRLF & _
				StringFormat("$%s.AddProperty('%s',$ELSCOPE_%s,$%s)",$_name_AOClass, $skey, $sType, $skeyNew)
			Else
				$sCur = StringFormat("$%s.AddProperty('%s',$ELSCOPE_%s,%s)",$_name_AOClass, $skey, $sType, '_AutoItObject_Create()')
			EndIf

		Else
			$sCur = StringFormat("$%s.AddProperty('%s',$ELSCOPE_%s,%s)", $_name_AOClass, $skey, $sType, $sValue)
		EndIf

		$sRet &= $sCur & @CRLF
	Next

	; Append to content
	$sContent &= $sRet

	Return $aProperties
EndFunc

; ~ Get previous names from hierarchy hell
Func _TS_Func_getNameHierarchy($oPrev); Dont pass $oPrev as byref
	If Not IsObj($oPrev) Then Return ""
	Local $a[1] = [0]
	While IsObj($oPrev)
		; push
		_Array_Push($a, $oPrev.cleanName)
		; Next
		$oPrev = $oPrev.parent
	WEnd
	; Reverse if there is more than 1 element
	If $a[0] > 1 Then
		_ArrayReverse($a, 1)
		; Paste str
		Return _ArrayToString($a, "_", 1) & "_"
	Else
		Return $a[1] & "_"
	EndIf
EndFunc   ;==>_TS_Func_GetNameHierarchy

; Where the error occured
Func _TS_Func_TraceCurRefs($oCur, $sMethodName = Null); Dont pass $oCur as byref
	Local $a[1] = [0], $sRet
	Local $oCopyofCur = $oCur; yeahhh. for filename etc
	$sMethodName = Not $sMethodName ? $oCopyofCur.cleanName : $sMethodName

	While IsObj($oCur)
		; Push
		_Array_Push($a, $oCur.cleanName)
		; Next
		$oCur = $oCur.parent
	WEnd
	; Reverse if there is more than 1 element
	If $a[0] > 1 Then
		_ArrayReverse($a, 1)
		; Paste str
		$sRet = _ArrayToString($a, "/", 1)
	ElseIf $a[0] > 1 Then
		$sRet = "/" & $a[1]
	EndIf

	Return StringFormat("'%s' @ '%s%s::$%s'", $oCopyofCur.sFilename, $oCopyofCur.oNamespace.raw, $sRet, $sMethodName)
EndFunc
; Get first layer of nested functions
Func _TS_Func_getNested($sFileBuffer)
	; Grab loz metodoz
	Local $StringRegExp = StringRegExp($sFileBuffer, $re_func_getNested, 4)
	Local $aRet[1] = [0]
	If IsArray($StringRegExp) Then
		For $i = 0 To UBound($StringRegExp) - 1
			Local $cur = $StringRegExp[$i]
			_Array_Push($aRet, _TS_Func_GetNested_TranslateToObj($cur))
		Next
		Return $aRet
	EndIf
	Return $aRet
EndFunc   ;==>_TS_Func_GetNested

; Convert $re_func_getNested result array to Object
Func _TS_Func_getNested_TranslateToObj(ByRef $a)
	Local $oRet = _AutoItObject_Create()
	; Regular
	_AutoItObject_AddProperty($oRet, "parent", $ELSCOPE_PUBLIC, Null)
	_AutoItObject_AddProperty($oRet, "keyword", $ELSCOPE_PUBLIC, $a[1]) ; Did not exist before
	_AutoItObject_AddProperty($oRet, "dirtyName", $ELSCOPE_PUBLIC, $a[2]) ; was [1]
	_AutoItObject_AddProperty($oRet, "cleanName", $ELSCOPE_PUBLIC, $a[3]) ; was [2]
	_AutoItObject_AddProperty($oRet, "params", $ELSCOPE_PUBLIC, $a[4]) ; was [3]
	_AutoItObject_AddProperty($oRet, "paramsRaw", $ELSCOPE_READONLY, $a[4]) ; was [3] (Just for Debug)
	_AutoItObject_AddProperty($oRet, "content", $ELSCOPE_PUBLIC, $a[5]) ; was [4]
	_AutoItObject_AddProperty($oRet, "endFuncContent", $ELSCOPE_PUBLIC, $a[7]) ; was [5] (Yes, was 5, now its 7, Welcome to Regex HELL)

	; QTadds
	_AutoItObject_AddProperty($oRet, "isClass", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oRet, "isExtension", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oRet, "isConstructor", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oRet, "isGlobal", $ELSCOPE_PUBLIC, False)

	; antiheadache
	_AutoItObject_AddProperty($oRet, "sFileName", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oRet, "oNamespace", $ELSCOPE_PUBLIC, Null)

	; QTaddzzz
	_AutoItObject_AddProperty($oRet, "oConstructor", $ELSCOPE_PUBLIC, Null);
	_AutoItObject_AddProperty($oRet, "C_params", $ELSCOPE_PUBLIC, Null) ;4 bugtest

	; Check if class, constructor or extension (only class + ext is superiouir, the constructor is self-made-millionaireee)
	Local Const $isSuperiour = StringRegExp($a[4], $re_TS_parameter, 3) ; $a was [3]

	If IsArray($isSuperiour) Then
		$_resource_bLazyLoad = True
		Switch $isSuperiour[0]
			Case "class"
				$oRet.isClass = 1
			Case "extension"
				$oRet.isExtension = 1
			Case "construct"
				$oRet.isConstructor = 1
		EndSwitch
		$oRet.params = $isSuperiour[1]
		$oRet.C_params = $isSuperiour[1]
	EndIf

	Return $oRet
EndFunc   ;==>_TS_Func_GetNested_TranslateToObj
