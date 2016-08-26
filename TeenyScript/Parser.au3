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

	Local Const $aNew_ts_2_au3_File = _TS_ParseFile($sFileName, $sFileName);Returns [0] = Full file path, [1] = Parsed content of file(s)
	If _TS_Error() Then Return False; This is nuff

	; this error may not be needed
	;If _TS_Error() Then Return _TS_SetError(3, 0, 0, "_TS_ParseFile failed to parse '%s'", $sFileName)

	Local $aFileInfo = getFromFilepath_all_asArray($aNew_ts_2_au3_File[0]); C:\x\x\x.ts.au3
	$aFileInfo[1] = StringRegExpReplace($aFileInfo[1], "(.*)\.ts", "$1")

	; ~ New file name c:\x\x.ts -> c:\x\x.au3 (Actual file)
	Local Const $sAu3FileName = StringFormat("%s\%s.au3", $aFileInfo[0], $aFileInfo[1])

	; Create the new file
	Local const $fHandle = FileOpen($sAu3FileName, $FO_OVERWRITE)
	if $fHandle == -1 Then Return _TS_SetError(4, 0, 0, "Failed to open '%s' for '$FO_OVERWRITE'", $sAu3FileName); Failed to open filehandle with Append \overwrite
	; Append Opt options
	; if $opt....
	; Append LazyLoded content if we are using AO
	If $_resource_bLazyLoad Then
		FileWrite($fHandle, $_TS_LazyLoadedContent)
	EndIf
	FileWrite($fHandle, $aNew_ts_2_au3_File[1]); [1] = parsed content
	FileWriteLine($fHandle, $_resource_ffDebug); Write the DEBUG data (ONLY on RUN)
	FileClose($fHandle)

	Local $aRet = [$sAu3FileName, $sFileName]

	Return $aRet
EndFunc


;$sPrevFileName is so we can get the relative path for includes working correctly
Func _TS_ParseFile(Const $sFileName, $sPrevFileName = False)
	; Just for _TS_Error (nothing else)
	$_resource_curFileNameDISPLAY = StringRegExpReplace($sFileName, "\\{2,}", "")

	; Rec file search for @Interface (NAME.interface.ts.au3)  (Should not be included, only read into TS memory)
	; Rec file search for @Interface (NAME.interface.ts.au3)  (Should not be included, only read into TS memory)
	; Rec file search for @Interface should be done seperatly. This is only for actual TS code (YES)
	; Rec file search for @Interface should be done seperatly. This is only for actual TS code (YES)


	; Get file content and replace CRLF with LF
	Local $sCurrentFileBuffer = StringReplace(FileRead($sFileName), @CRLF, @LF)


	; Save #DEBUG if THE this is the first iteration (We can check that by looking if $sFilename and $sPrevFilename is the same)
	If $sFileName == $sPrevFileName Then
		$_resource_sExecFile = $sFileName
		Local $aRe_TS_Debug = StringRegExp($sCurrentFileBuffer, $re_TS_Debug, 3)
		If IsArray($aRe_TS_Debug) Then $_resource_ffDebug =  $aRe_TS_Debug[0]
	EndIf

	; Look for #includes
	_TS_Compose_Include_Rec($sCurrentFileBuffer, $sFileName, $sPrevFilename)


	; ~ Create resources used to compile ~
	Local Const $sFilenameAsBinary = StringToBinary($sFileName); Full file path
	; Alias namespace storage
	Local $aAliasUsage[1] = [0]
	; Get the namesapce for this file
	Local Const $oNamespace = _TS_getNamespace($sCurrentFileBuffer); Should be for each file before loop so we capture the correct namespace

	; Parse nested function
	Local $aRes = _TS_parseFuncStructure($sFileName, $sCurrentFileBuffer, True)

	_TS_Compose($aRes, $aAliasUsage, $sFilenameAsBinary, $oNamespace)

	; ONly return at input file
	If $sFileName == $sPrevFileName Then
		_TS_Compose_Macro_nameSpaces(); This will be done on the fully content created not including #DEBUG
		Local $aRet = [$sFileName, $_resource_ffBuffer]; Input filename (The Main fil3)
		Return $aRet
	EndIf
EndFunc


; For recursive parsing with (#include x)
Func _TS_Compose_Include_Rec(Const $sCurrentFileBuffer, Const $sFileName, $sPrevFileName = False)
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
							$_resource_ffBuffer &= ";TS_COM_DEBUG:" & $aRe_TS_CurFile & @CRLF & _
							StringFormat("#Include <%s>", $aRe_TS_CurFile) & @CRLF


						ElseIf FileExists(StringFormat("%s\%s", $sFileName_relative_path, $aRe_TS_CurFile)) Then
							;Include with relative dir from the file that is bein run
							Local $sRelativePathAu3 = StringReplace($sFileName_relative_path & "\", "\" & getFromFilepath_basedir($sPrevFileName), "")

							$_resource_ffBuffer &= ";TS_COM_DEBUG:" & $sRelativePathAu3 & @CRLF & _
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
									$aRe_TS_CurFile_TS = StringFormat("%s\%s.au3", getFromFilepath_basedir($_resource_sExecFile), $aRe_TS_CurFile)
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
										$_FileListToArrayRec_sPath = getFromFilepath_basedir($_resource_sExecFile) & getFromFilepath_basedir($aRe_TS_CurFile)
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

Func _TS_Compose(ByRef $outer, ByRef $aAliasUsage, Const $sFilenameAsBinary, Const $oNamespace)

	If IsArray($outer) Then

		For $y = 1 To $outer[0]
			Local $inner = $outer[$y], $aMethods, $aProperties

			If IsArray($inner) Then
				Local $item = $inner[1]


				; Look for alias namespaces (Will be matchet against all detected namespaces l8r
				If $item.isGlobal Then
					_TS_Compose_Macro_UseInAs($item, $aAliasUsage)
				EndIf

				; Assign the new name as Binary with the full file path so we do not get any colission
				$item.sFileName_STH = StringFormat("%s%s", $_name_Function, $sFilenameAsBinary);

				; This does both Superiors and non-class
				$aMethods = _TS_Compose_Methods($item)

				;How we handle superior-only stuff
				if _TS_IsSuperior($item) Then
					; Fix the class properties
					$aProperties = _TS_Compose_classProperties($item)

					; Append magic properties for metods and properties
					_TS_Compose_MagicProperties($item, $aMethods, $aProperties)
				EndIf

				; Parse Heredoc
				_TS_Compose_Heredoc($item)

				; Parse list related
				_TS_Compose_Lists($item)

				; Parse closures (will append to $_resource_ffBuffer)
				_TS_Compose_Closure($item)

				; Misc
				_TS_Compose_Macro_Misc($item, $oNamespace)

				; Always last (will append to $_resource_ffBuffer)
				_TS_Compose_finalFunction($item, $oNamespace)

				;Recur next
				_TS_Compose($inner[2], $aAliasUsage, $sFilenameAsBinary, $oNamespace)
			EndIf
		Next
		;
		_TS_Compose_Macro_UseInAs_AT($aAliasUsage)

		Return $outer[0]
	EndIf
	Return 0
EndFunc


#Region Features

Func _TS_Compose_Methods(ByRef $item)
	Local $z = $_resource_sFuncCount + 1, $sAO_MetodName = "", $aMethods = StringRegExp($item.content, $re_func_getNested, 4), $aMethods_len = UBound($aMethods)

	If Not $aMethods_len Then Return False

	For $i = 0 to $aMethods_len - 1
		; Read only, wont modify shieeet
		Local $aMethods_cur = $aMethods[$i], $sMethod_Property = $aMethods_cur[1], $sMethod_dirtyName = $aMethods_cur[2], $sMethod_cleanName = $aMethods_cur[3], $sMethod_params = $aMethods_cur[4], $sMethod_endFuncStuff = $aMethods_cur[7]

		If _TS_IsSuperior($item) Then
			; Check if any prop is given
			Local $ELSCOPE_X = "$ELSCOPE_PUBLIC"; Default is public

			Switch $sMethod_Property
				Case "@Private"
					$ELSCOPE_X = "$ELSCOPE_PRIVATE"
				Case "@Public"
					$ELSCOPE_X = "$ELSCOPE_PUBLIC"
			EndSwitch

			$sAO_MetodName = StringFormat('$%s.AddMethod("%s", "%s_%d", %s)', $_name_AOClass, $sMethod_cleanName, $item.sFileName_STH, $z, $ELSCOPE_X)

			; Check if one of these children has any constructor (Then we going to modify the current class to return the constructor name)
			; This should only work in classes (Not inclu
			Local $aRe_TS_parameter = StringRegExp($sMethod_params, $re_TS_parameter, 3)

			if IsArray($aRe_TS_parameter) Then

				If StringRegExp($aRe_TS_parameter[0], "(?i)construct") And not $item.hasConstructor Then
					;If the constructo has parameters, throw error since it will get the parents parameters.
					if Not isEmpty($aRe_TS_parameter[1]) Then Return _TS_SetError(1, 0, 0, "[_TS_Compose_Methods] Params: The constructor '%s' may not contain any parameters since they are inherited from the class @ '%s'", $sMethod_cleanName, $_resource_curFileNameDISPLAY)

					$item.hasConstructor = 1; Used in final functions
					$item.ConstructorName = $sMethod_cleanName; Name of the method assigned as a constructor.

				ElseIf StringRegExp($aRe_TS_parameter[0], "(?i)construct") And $item.hasConstructor Then

					Return _TS_SetError(2, 0, 0, "[_TS_Compose_Methods] Dupe: Constructor already set as '%s'. Cannot re-declare construct as '%s' @ '%s'", $item.ConstructorName, $sMethod_cleanName, $_resource_curFileNameDISPLAY)
				EndIf

			EndIf


		Else
			$sAO_MetodName = StringFormat("Local Const %s %s_%d%s",$sMethod_dirtyName, $item.sFileName_STH, $z, $sMethod_endFuncStuff)
		EndIf

		$item.content = StringRegExpReplace($item.content, $re_func_getNested, $sAO_MetodName, 1)
		;Increment func index
		$z+=1
	Next

	Return $aMethods
EndFunc

Func _TS_Compose_classProperties(ByRef $item); Also works on extensions

	Local $aProperties = StringRegExp($item.content, $re_func_properties, 3), $aProperties_len = UBound($aProperties)

	if Not $aProperties_len Then Return False

	Local $re2Use = ""

	; [0] = @Type, [1] = $this.name, [2] value
	For $i = 0 To $aProperties_len - 1 Step + 3
		Local $sType = $aProperties[$i]
		Local $skey = $aProperties[$i + 1]
		Local $sValue = $aProperties[$i + 2]

		Local $aRe_array_ClassProp = StringRegExp($sValue, $re_array_ClassProp, 3)
		Local $aRe_list_ClassProp = StringRegExp($sValue, $re_list_ClassProp, 3)

		If IsArray($aRe_array_ClassProp) Then ; If array
			; Alter Skey for this step
			$skey = "a_" & $skey
			$re2Use = "" & _
			StringFormat("Local $%s = %s", $skey, $aRe_array_ClassProp[0]) & @CRLF & _
			StringFormat("$%s.AddProperty('$2',$ELSCOPE_$1, $a_$2)", $_name_AOClass)
		ElseIf IsArray($aRe_list_ClassProp) Then; If list
			; Alter Skey for this step
			$skey = "o_" & $skey
			Local $listContent = _TS_Compose_Lists_MultiAssignByContent($skey, $aRe_list_ClassProp[0])
			if StringLen($listContent) Then
				$re2Use  = "" & _
				StringFormat("Local $%s = %s", $skey, '_AutoItObject_Create()') & _
				$listContent & @CRLF & _
				StringFormat("$%s.AddProperty('$2',$ELSCOPE_$1, $%s)",$_name_AOClass, $skey)
			Else
				$re2Use = StringFormat("$%s.AddProperty('$2',$ELSCOPE_$1, %s)",$_name_AOClass, '_AutoItObject_Create()')
			EndIf

		Else
			$re2Use = StringFormat("$%s.AddProperty('$2',$ELSCOPE_$1, $3)", $_name_AOClass)
		EndIf



		$item.content = StringRegExpReplace($item.content, $re_func_properties, $re2Use, 1)
	Next

	Return $aProperties
EndFunc

Func _TS_Compose_Heredoc(ByRef $item); (<<<)....(>>>>)
	Local $aRe_heredoc_content = StringRegExp($item.content, $re_heredoc_content, 3)

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
			$item.content = StringRegExpReplace($item.content, $re_heredoc_content, $aNewCnt, 1)
		Next
	EndIf

EndFunc

Func _TS_Compose_Lists(ByRef $item); {}
	$_resource_bLazyLoad = True
	; Brand new list
	Local $aRe_list_create = StringRegExp($item.content, $re_list_create, 3), $aRe_list_create_len = UBound($aRe_list_create)
	For $i = 0 To $aRe_list_create_len - 1 Step + 2

		; Check if are going to MultiAssign from this creation
		Local $sListBuffer = _TS_Compose_Lists_MultiAssignByContent($aRe_list_create[$i], $aRe_list_create[$i + 1])

		; Do the actual replace after we parse each inner value so we dont get OOP (Out of position)
		$item.content = StringRegExpReplace($item.content, $re_list_create, "$$1 = _AutoItObject_Create()" & $sListBuffer, 1)
	Next

	; Set
	Local $aRe_list_set = StringRegExp($item.content, $re_list_set, 3)
	Local $Re2Use = ""
	For $i = 0 To UBound($aRe_list_set) - 1 Step + 3
		Local $identifier = $aRe_list_set[$i]
		Local $Key = $aRe_list_set[$i + 1]
		Local $Val = $aRe_list_set[$i + 2]

		If StringRegExp($identifier, "\.") Then ; Detect $var.etc and create a fake var
			Local $fakeVar = $_name_List & $i
			$Re2Use = "" & _
			StringFormat("Local $%s = $%s", $fakeVar, $aRe_list_set[$i]) & @CRLF & _
			StringFormat("_AutoItObject_AddProperty($%s, $2, $ELSCOPE_PUBLIC, $3)", $fakeVar)
		Else
			$Re2Use = "_AutoItObject_AddProperty($$1, $2, $ELSCOPE_PUBLIC, $3)" ; Default
		EndIf

		$item.content = StringRegExpReplace($item.content, $re_list_set, $Re2Use, 1)

	Next

	; Get (the one with execute)
	; We go through each and one. so we can translate $list{"key"} to "$list.key", but keep $list{$key} as "Execute('$list.' & $key)"
	Local $aRe_list_get = StringRegExp($item.content, $re_list_get, 3), $re2Use = ""

	For $i = 0 to UBound($aRe_list_get) - 1 Step + 2

		; Check if string has to start with " and end with "
		Local $ciS = StringRegExp($aRe_list_get[$i + 1], "^(?:(?:" & '\"' & "|\')(.*)(?:" & '\"' & "|\'))", 3)

		; This will help us not use Execute on signle strings
		if IsArray($ciS) Then
			$re2Use = "$$1." & $ciS[0]
		Else
			$re2Use = "Execute('$$1.' & $2)"
		EndIf

		$item.content = StringRegExpReplace($item.content, $re_list_get, $re2Use, 1)
	Next




EndFunc

Func _TS_Compose_Macro_Misc(ByRef $item, const $oNamespace); @Methodparams @Namespace, @Extends etc...
	$item.content = StringRegExpReplace($item.content, $re_macro_getNamespace, StringFormat("'%s'", $oNamespace.raw))
	$item.content = StringRegExpReplace($item.content, $re_macro_getMethodName, StringFormat("'%s'", $item.cleanName))
	$item.content = StringRegExpReplace($item.content, $re_macro_getMethodParams, StringFormat("'%s'", $item.params))
	If _TS_IsSuperior($item) Then
		Local Const $aRe_macro_useExtension = StringRegExp($item.content, $re_macro_useExtension, 3)
		If IsArray($aRe_macro_useExtension) Then
			; Detect if namespaced are used or not
			If isEmpty($aRe_macro_useExtension[0]) Then
				$item.content = StringRegExpReplace($item.content, $re_macro_useExtension, StringFormat("$$2($%s)", $_name_AOClass))
			Else
				$item.content = StringRegExpReplace($item.content, $re_macro_useExtension, StringFormat("$1$$2($%s)", $_name_AOClass))
			EndIf
		EndIf
	EndIf
EndFunc

Func _TS_Compose_Macro_nameSpaces(); after treatment
	; Replace __ALL__ namespaces (Use as in interfaces etcetcetcetc, GloBalllYYY
	Local $curNamespaceStorage

	For $i = 0 To $_resource_aNamespaces[0]
		$curNamespaceStorage = $_resource_aNamespaces[$i]
		If IsArray($curNamespaceStorage) Then; For functions without namespaces
			Local $lookFor = $curNamespaceStorage[0], $replaceWith = $curNamespaceStorage[1]
			$_resource_ffBuffer = StringReplace($_resource_ffBuffer, $lookFor, $replaceWith)
		EndIf
	Next

EndFunc

#Region Use As In related
Func _TS_Compose_Macro_UseInAs(ByRef $item, ByRef $aAliasUsage); Before-Func-content parse ( at top only else children will will not get grabbed )
	Local $aRe_macro_useNamespace = StringRegExp($item.content, $re_macro_useNamespace, 3), $aRe_macro_useNamespace_len = UBound($aRe_macro_useNamespace)

	If $aRe_macro_useNamespace_len Then
		$item.content = StringRegExpReplace($item.content, $re_macro_useNamespace, ""); Replace after we grab for content

		Local $lookFor, $replaceWith

		For $i = 0 To $aRe_macro_useNamespace_len - 1 Step + 2
			$lookFor = StringFormat("%s/$", $aRe_macro_useNamespace[$i + 1])
			$replaceWith = StringFormat("%s/$", $aRe_macro_useNamespace[$i])

			Local $aMatchArr = [$lookFor, $replaceWith]
			_Array_Push($aAliasUsage, $aMatchArr)

		Next
	EndIf

EndFunc

Func _TS_Compose_Macro_UseInAs_AT(ByRef $aAliasUsage); After treatment
	For $i = 1 To $aAliasUsage[0]
		Local $cur = $aAliasUsage[$i]
		Local $lookFor = $cur[0], $replaceWith = $cur[1]
		$_resource_ffBuffer = StringReplace($_resource_ffBuffer, $lookFor, $replaceWith)
	Next
	_Array_Empty($aAliasUsage); Needed?
EndFunc

#EndRegion Use As In related

Func _TS_Compose_Closure(ByRef $item); $gg.test(func() .... (EndFunc))
	Local $aRe_func_closure = StringRegExp($item.content, $re_func_closure, 3), $aRe_func_closure_len = UBound($aRe_func_closure), $sClosureFuncs, $sClosureName

	if Not $aRe_func_closure_len Then Return

	For $i = 0 To $aRe_func_closure_len - 1 Step +3
		$sClosureName = StringFormat("%s%d", $_name_Closure, $_resource_clousreCount)
		$_resource_clousreCount+=1

			$sClosureFuncs &= StringFormat("Func %s(%s)", $sClosureName, $aRe_func_closure[$i + 1]) & @CRLF & _
			$aRe_func_closure[$i + 2] & @CRLF & _
			"EndFunc" & @CRLF

			$item.content = StringRegExpReplace($item.content, $re_func_closure, StringFormat("$1 %s", $sClosureName), 1)
	Next

	; Append to ffBuffer (Si seniorita)
	$_resource_ffBuffer &= $sClosureFuncs
EndFunc
#EndRegion

Func _TS_getNamespace(ByRef $content)
	Local $aRe_macro_setNamespace = StringRegExp($content, $re_macro_setNamespace, 3)
	Local $oRet = _AutoitObject_Create(), $clean = "", $raw = ""; Store raw and good namespace
	If IsArray($aRe_macro_setNamespace) Then
		StringRegExpReplace($content, $re_macro_setNamespace, ""); Remove
		; Store namespaces
		Local $raw = $aRe_macro_setNamespace[0]
		Local $clean = StringReplace($raw, "/", "_") & "_"

		Local $aResource = [$raw & "/$", "$" & $clean]
		;Push namespace usage to global resource
		_Array_Push($_resource_aNamespaces, $aResource)

	EndIf
	; Return the current namespace for this file (Classes etc)
	_AutoitObject_AddProperty($oRet, "raw", $ELSCOPE_PUBLIC, $raw)
	_AutoitObject_AddProperty($oRet, "clean", $ELSCOPE_PUBLIC, $clean)
	Return $oRet
EndFunc

Func _TS_Compose_finalFunction(ByRef $item, const $oNamespace)
	Local $SuperiorContent = ""

	; If within a class and is constructor. Then the params should be the same as the parent
	If $item.parent.isClass And $item.isConstructor Then
		$item.params = $item.parent.params
	ElseIf $item.isConstructor Then; if we try to create a constructor not using a class
		Return _TS_SetError(1, 0, 0, "[_TS_Compose_finalFunction] Not today son: the keyword 'Construct' @ %s is only avilable within classes, the parent object has the type '%s' @ '%s'", $item.cleanName, VarGetType($item.parent), $_resource_curFileNameDISPLAY)
	EndIf

	; Check if this functions parent is superior, in that case we add the _TS_Objectname (Default: $this)
	If _TS_IsParentSuperior($item) And Not $item.isExtension Then
		If Not isEmpty($item.params) Then
			$item.params = StringFormat("$%s, %s", $_TS_ObjectName, $item.params)
		Else
			$item.params = StringFormat("$%s", $_TS_ObjectName)
		EndIf
	EndIf

	; If current function is an Extension
	If $item.isExtension Then
		If StringLen($item.params) Then
			$item.params = StringFormat("$%s, %s", $_name_AOClass, $item.params)
		Else
			$item.params = StringFormat("$%s", $_name_AOClass)
		EndIf
	EndIf


	; If class clause
	If $item.isClass Then
		$SuperiorContent = "" & _
		StringFormat('Local Const $%s = _AutoItObject_Class()', $_name_AOClass) & @CRLF & _
		StringFormat('Local Const $%s = %s', $_name_AOProperties, $item.sPropertyNames) & @CRLF & _
		StringFormat('Local Const $%s = %s', $_name_AOMethods, $item.sMethodNames) & @CRLF & _
		$item.sPropertyExtraArrays & _
		StringFormat('$%s.AddProperty("__Properties__", $ELSCOPE_READONLY, $%s)', $_name_AOClass, $_name_AOProperties) & @CRLF & _
		StringFormat('$%s.AddProperty("__Methods__", $ELSCOPE_READONLY, $%s)', $_name_AOClass, $_name_AOMethods) & @CRLF & _
		StringFormat('$%s.AddProperty("__Parent__", $ELSCOPE_PRIVATE, %s)', $_name_AOClass, (Not $item.isGlobal ? "$" & $_TS_ObjectName : 'NULL')) & @CRLF & _
		StringFormat('$%s.AddProperty("__cName__", $ELSCOPE_READONLY, "%s")', $_name_AOClass, $item.cleanName) & @CRLF & _
		StringFormat('$%s.AddProperty("__Namespace__", $ELSCOPE_READONLY, "%s")', $_name_AOClass, $oNamespace.raw) & @CRLF

		; Return the class with its constructor-method as the final object.
		if $item.hasConstructor Then
			; The params passed to the class, should be passed to the constructor instantly
			$item.content &= @CRLF & StringFormat("Return $%s.Object.%s(%s)", $_name_AOClass, $item.ConstructorName, $item.params)
		Else
			;Just return the ao Class object
			$item.content &= @CRLF & StringFormat("Return $%s.Object", $_name_AOClass)
		EndIf
	EndIf

	; Add Debug stirng for detailed com error
	$_resource_ffBuffer &= StringFormat($_TS_Debug, $item.sFilename, $oNamespace.raw, $item.cleanName, $item.paramsRaw) & @CRLF
	$_resource_ffBuffer &= StringFormat("Func %s_%d(%s)", $item.sFileName_STH, $_resource_sFuncCount, $item.params) & @CRLF & _
		$SuperiorContent & _
		$item.content & @CRLF & _
		($item.isConstructor ? StringFormat("Return $%s", $_TS_ObjectName) & @CRLF : "") & _
		"EndFunc" & @CRLF & _
		($item.isGlobal ? StringFormat("Global Const $%s%s = %s_%d%s", $oNamespace.clean, $item.cleanName, $item.sFileName_STH, $_resource_sFuncCount, $item.endFuncContent) & @CRLF : "")
		$_resource_sFuncCount += 1
EndFunc

#Region Feature helpers
;Get the specified method properties and method names of a given content
Func _TS_Compose_MagicProperties(ByRef $item, ByRef $aMethods, ByRef $aProperties)

	if IsArray($aMethods) Then
		Local $aMethods_len = UBound($aMethods)
		if Not $aMethods_len Then Return Null; Do nada
		Local $sRet = StringFormat("[[%d, 'Scope','Name', 'Parameters']", $aMethods_len)

		For $i = 0 To $aMethods_len - 1
			Local $cur = $aMethods[$i]
			Local $oTmp = _TS_getFuncStructureAsObj($cur)
			$sRet &= StringFormat(",[%d, '%s', '%s', '%s']", $i + 1, (isEmpty($oTmp.keyword) ? "@Public" : $oTmp.keyword), $oTmp.cleanName, StringReplace($oTmp.params, "'", '"'))
		Next

		$sRet &= "]"
		$item.sMethodNames = $sRet
	EndIf

	if IsArray($aProperties) Then
		Local $aProperties_len = UBound($aProperties)
		if Not $aProperties_len Then Return Null; Do nada
		Local $sRet = StringFormat("[[%d, 'Scope', 'Name', 'Default']", $aProperties_len)

		For $i = 0 To $aProperties_len - 1 Step +3
			Local $cur = $aProperties[$i]

			$sRet &= StringFormat(",[%d, '%s', '%s', '%s']", $i + 1, $aProperties[$i], $aProperties[$i + 1], StringReplace($aProperties[$i + 2], "'", '"'))
		Next

		$sRet &= "]"
		$item.sPropertyNames = $sRet
	EndIf

EndFunc

Func _TS_Compose_Lists_MultiAssignByContent(ByRef $name, ByRef $content); THIS IS A SUB-FUNCTION, ONLY USED ON SOME PLACES! !!!!!!
	If Not StringLen($content) Then Return ""
	Local $aRe_list_createKeyval = StringRegExp($content, $re_list_multiAssign, 3)
	Local $sListBuffer = ""

	For $j = 0 To UBound($aRe_list_createKeyval) - 1 Step +2
		Local $Key = $aRe_list_createKeyval[$j]
		Local $Val = $aRe_list_createKeyval[$j + 1]
		$sListBuffer &= @CRLF & StringFormat("_AutoItObject_AddProperty($%s, %s, $ELSCOPE_PUBLIC, %s)", $name, $Key, $Val)
	Next

	Return $sListBuffer
EndFunc
#EndRegion
; ~ Helpers ~

Func _TS_IsParentSuperior(ByRef $item)
	If IsObj($item.parent) Then
		Return $item.parent.isClass + $item.parent.isExtension
	EndIf
	Return 0
EndFunc

Func _TS_IsSuperior(ByRef $item)
	Return $item.isClass + $item.isExtension
EndFunc


; Här får du vara så länge ;P
Func _TS_parseFuncStructure(const $sFileName, $sCurrentFileBuffer, $isGlobal = True, $oParent = Null)
	Local $outer = StringRegExp($sCurrentFileBuffer, $re_func_getNested, 4)


	If IsArray($outer) Then
		Local $aRet[1] = [0]
		Local $outer_len = UBound($outer)

		For $i = 0 To $outer_len - 1
			Local $inner = $outer[$i]

			Local $oRet = _TS_getFuncStructureAsObj($inner, $sFileName, $isGlobal, $oParent)

			Local $CHILDREN = _TS_parseFuncStructure($sFileName, $inner[5], False, $oRet); $inner was 4
			Local $aStore = [$outer_len, $oRet, $CHILDREN]
			_Array_Push($aRet, $aStore)
		Next
		Return $aRet
	EndIf

	Return False
EndFunc

Func _TS_getFuncStructureAsObj(ByRef $a, $sFileName = "", $isGlobal = True, $oParent = Null)
	Local $oRet = _AutoItObject_Create()
	; Regular
	_AutoItObject_AddProperty($oRet, "parent", $ELSCOPE_PUBLIC, $oParent)
	_AutoItObject_AddProperty($oRet, "keyword", $ELSCOPE_PUBLIC, $a[1]); Did not exist before
	_AutoItObject_AddProperty($oRet, "dirtyName", $ELSCOPE_PUBLIC, $a[2]); was [1]
	_AutoItObject_AddProperty($oRet, "cleanName", $ELSCOPE_PUBLIC, $a[3]); was [2]
	_AutoItObject_AddProperty($oRet, "params", $ELSCOPE_PUBLIC, $a[4]); was [3]
	_AutoItObject_AddProperty($oRet, "paramsRaw", $ELSCOPE_READONLY, $a[4]); was [3] (Just for Debug)
	_AutoItObject_AddProperty($oRet, "content", $ELSCOPE_PUBLIC, $a[5]); was [4]
	_AutoItObject_AddProperty($oRet, "endFuncContent", $ELSCOPE_PUBLIC, $a[7]); was [5] (Yes, was 5, now its 7, Welcome to Regex HELL)

	; QTadds
	_AutoItObject_AddProperty($oRet, "isClass", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oRet, "isExtension", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oRet, "isConstructor", $ELSCOPE_PUBLIC, 0); For the actual function as a child
	_AutoItObject_AddProperty($oRet, "isGlobal", $ELSCOPE_PUBLIC, $isGlobal)

	; Constructor/Destructorstuff (For the class when checking children)
	_AutoItObject_AddProperty($oRet, "hasConstructor", $ELSCOPE_PUBLIC, 0); Only applied afterwards when the current class has a constructor
	_AutoItObject_AddProperty($oRet, "ConstructorName", $ELSCOPE_PUBLIC, ""); Only applied afterwards when the current class has a constructor

	_AutoItObject_AddProperty($oRet, "sMethodNames", $ELSCOPE_PUBLIC, "NULL"); Array in string format with the class method data
	_AutoItObject_AddProperty($oRet, "sPropertyNames", $ELSCOPE_PUBLIC, "NULL"); Array in string format with the property names
	_AutoItObject_AddProperty($oRet, "sPropertyExtraArrays", $ELSCOPE_PUBLIC, ""); Misc added arrays we gonna use in the class
	_AutoItObject_AddProperty($oRet, "sFileName_STH", $ELSCOPE_PUBLIC, Null)

	; Misc READ ONLY stuff
	_AutoItObject_AddProperty($oRet, "sFilename", $ELSCOPE_READONLY, StringRegExpReplace($sFileName, "\\{2,}", "")); will be used for debug atm ?

	; Check if class, constructor or extension (only class + ext is superiouir, the constructor is self-made-millionaireee)
	Local Const $isSuperiour = StringRegExp($a[4], $re_TS_parameter, 3); $a was [3]

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
	EndIf


	Return $oRet
EndFunc
