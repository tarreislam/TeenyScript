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
#cs
				~ Semantic Versioning 2.0.0 ~
	Given a version number MAJOR.MINOR.PATCH, increment the:

	MAJOR version when you make incompatible API changes,
	MINOR version when you add functionality in a backwards-compatible manner, and
	PATCH version when you make backwards-compatible bug fixes.
	Additional labels for pre-release and build metadata are available as extensions to the MAJOR.MINOR.PATCH format.
#ce
Func _TS_Project_VCS($oProject, $hParent = 0); This is used when compiling, running or editing a project related TS script
	Local $cVer = StringRegExp($_TS_AppVer, "(\d+)\.(\d+)\.(\d+)", 3); TeenyScript version
	Local $tVer = StringRegExp($oProject.teenyscript_TS_AppVer, "(\d+)\.(\d+)\.(\d+)", 3); Project version
	If Not IsArray($tVer) Then Return MsgBox($MB_ICONWARNING, $_TS_AppTitle, StringFormat("Warning! Failed to find TeenyScript version from the project '%s'. Check your config", $oProject.name), $hParent)
	Local $c_major = $cVer[0], $c_minor = $cVer[1], $c_patch = $cVer[2]
	Local $t_major = $tVer[0], $t_minor = $tVer[1], $t_patch = $tVer[2]
	Local $majorDiff = $t_major - $c_major
	Local $minorDiff = $t_minor - $c_minor
	Local $patchDiff = $t_patch - $c_patch
	Local $sText

	If $majorDiff > 0 Then
		$sText = "Incompatible API changes has been made to the project, this version of TeenyScript may not be able to parse this project properly"
	ElseIf $majorDiff < 0 Then
		$sText = "Incompatible API changes has been made to TeenyScript, this version of the project may not be parsed properly"
	EndIf

	; Major diff is detected, either way it will be incompatible
	If Abs($majorDiff) > 0 Then
		Return _TS_Project_VCS_DisplayErr($oProject, $sText, $hParent, 1)
	EndIf

	; Minor diff, will only generate a ConsoleWrite
	if $minorDiff > 0  Then
		Return _TS_Project_VCS_DisplayErr($oProject, "New functionality may cause errors since your version of TeenyScript is lesser than the project's", 0, 2)
	EndIf

	; patch diff, spare yourself some time and get the latest updates of a script
	If $patchDiff > 0 and Not Abs($majorDiff) and Not Abs($minorDiff) then
		Return _TS_Project_VCS_DisplayErr($oProject, "Patchfixes has been made to the project, this may cause errors since your version of TeenyScript is lesser than the project's", 0, 3)
	EndIf

	Return True
EndFunc

Func _TS_Project_VCS_DisplayErr($oProject, $sText, $hParent = 0, $iCode = 0)
	$sText = StringFormat("Warning! your version of TeenyScript (%s) is diffrent from the project '%s' version (%s). %s.", _
	$_TS_AppVer, _
	$oProject.name, _
	$oProject.teenyscript_TS_AppVer, _
	$sText)
	If $hParent Then
		MsgBox($MB_ICONERROR, $_TS_AppTitle, $sText, 0, $hParent)
	EndIf
	$ConsoleWrite($sText, "r")
	$ConsoleWrite("Navigate to https://github.com/tarreislam/TeenyScript/releases to find a suitable release for this script", "g")
	Return SetError($iCode, 0, 0)
EndFunc

Func _TS_Project_createNewproject($oProject, $sNewProjectTargetDir, $hParent = 0)
	If Not FileExists($sNewProjectTargetDir) Then
		MsgBox($MB_ICONWARNING, $_TS_AppTitle, StringFormat("Unable to find folder '%s'", $sNewProjectTargetDir), 0, $hParent)
		Return SetError(1, 0, 0)
	EndIf

	; Check if prev file exists
	If FileExists(StringFormat("%s\%s", $sNewProjectTargetDir, $_TS_Project_Ts_PROJECT_INI)) Or FileExists(StringFormat("%s\%s", $sNewProjectTargetDir, $oProject.project.main_file)) Then
		Local Const $MsgBox = MsgBox($MB_ICONWARNING + $MB_YESNO, $_TS_AppTitle, "A TS project was detected at this directory, would you like to OVERWRITE and continue?", 0, $hParent)
		If $MsgBox == $IDNO Then
			_TS_AbortedByUser($hParent)
			Return SetError(2, 0, 0)
		EndIf
	EndIf

	; Attempt to copy content
	If Not _DirCopyContent($oProject.dir, $sNewProjectTargetDir, $hParent) Then Return SetError(3, @error, 0)

	; Remove write protection
	If Not FileSetAttrib($oProject.dir, "-R", $FT_RECURSIVE) Then
		MsgBox($MB_ICONWARNING, $_TS_AppTitle, StringFormat("Failed to remove write protection on '%s'", $oProject.dir), 0, $hParent)
		Return SetError(4, 0, 0)
	EndIf

	; Add the current TS version to the project
	IniWrite(StringFormat($_TS_Project_FilePatt, $sNewProjectTargetDir), "teenyscript", "_TS_AppVer", $_TS_AppVer)

	; Open main_file of project (if it exists)
	If Not $oProject.project.main_file Then
		MsgBox($MB_ICONWARNING, $_TS_AppTitle, StringFormat("No main_file defined for project '%s' @ '%s'", $oProject.project.name, $oProject.project.dir), 0, $hParent)
		ShellExecute($sNewProjectTargetDir)
		Return SetError(5, 0, 0)
	EndIf

	_Scite_OpenFile(StringFormat("%s\%s", $sNewProjectTargetDir, $oProject.project.main_file))
	Return True
EndFunc

Func _TS_Project_getProjectCollection(); Returns array of object, (string) .dir and (object) .project
	Local $aRet[1] = [0]
	$_FileListToArrayRec = _FileListToArrayRec($_TS_Project_Template_Dir, $_TS_Project_Ts_PROJECT_INI & "||BackUp",$FLTAR_FILES, $FLTAR_RECUR, $FLTAR_NOSORT, $FLTAR_FULLPATH)
	For $i = 1 To $_FileListToArrayRec[0]
		Local $oRet = _AutoItObject_Create()
		_AutoItObject_AddProperty($oRet, "project", $ELSCOPE_PUBLIC, _TS_Project_getSettings($_FileListToArrayRec[$i], False, False))
		_AutoItObject_AddProperty($oRet, "dir", $ELSCOPE_PUBLIC, getFromFilepath_basedir($_FileListToArrayRec[$i]))
		_Array_Push($aRet, $oRet)
	Next
	Return $aRet
EndFunc

Func _TS_Project_getSettings($_TS_ProjectFile, $getFromFilepath_basedir = False, $bParseMacro = True)
	If Not FileExists($_TS_ProjectFile) Then Return Null
	Local Const $main_file = IniRead($_TS_ProjectFile, "main", "main_file", False)
	Local Const $main_name = IniRead($_TS_ProjectFile, "main", "name", "Unkown")
	Local Const $main_ver = IniRead($_TS_ProjectFile, "main", "ver", "Unkown")
	Local Const $main_copyright = IniRead($_TS_ProjectFile, "main", "copyright", "Unkown")
	; parse directory macros
	Local Const $build_arch = IniRead($_TS_ProjectFile, "build", "arch", "32")
	Local Const $build_includeLauncher = IniRead($_TS_ProjectFile, "build", "includeLauncher", "False")
	Local Const $teenyscript_TS_AppVer = IniRead($_TS_ProjectFile, "teenyscript", "_TS_AppVer", False)
	Local $build_dir, $build_icon

	If $bParseMacro Then
		If Not $getFromFilepath_basedir Then Return MsgBox($MB_ICONWARNING, "", "$getFromFilepath_basedir may not be False to parse macros...")
		$build_dir = _TS_Project_parseMacrostring(IniRead($_TS_ProjectFile, "build", "dir", "Unkown"),$build_arch, $main_name, $main_ver, $getFromFilepath_basedir)
		$build_icon = _TS_Project_parseMacrostring(IniRead($_TS_ProjectFile, "build", "icon", "Unkown"),$build_arch, $main_name, $main_ver, $getFromFilepath_basedir)
	Else
		$build_dir = IniRead($_TS_ProjectFile, "build", "dir", "Unkown")
		$build_icon = IniRead($_TS_ProjectFile, "build", "icon", "Unkown")
	EndIf

	Local Const $build_type = IniRead($_TS_ProjectFile, "build", "type", "gui")

	Local $oRet = _AutoItObject_Create()
	; Main
	_AutoItObject_AddProperty($oRet, "main_file", $ELSCOPE_PUBLIC, $main_file)
	_AutoItObject_AddProperty($oRet, "name", $ELSCOPE_PUBLIC, $main_name)
	_AutoItObject_AddProperty($oRet, "ver", $ELSCOPE_PUBLIC, $main_ver)
	_AutoItObject_AddProperty($oRet, "copyright", $ELSCOPE_PUBLIC, $main_copyright)
	; Build
	_AutoItObject_AddProperty($oRet, "dir", $ELSCOPE_PUBLIC, $build_dir)
	_AutoItObject_AddProperty($oRet, "icon", $ELSCOPE_PUBLIC, $build_icon)
	_AutoItObject_AddProperty($oRet, "arch", $ELSCOPE_PUBLIC, $build_arch)
	_AutoItObject_AddProperty($oRet, "type", $ELSCOPE_PUBLIC, $build_type)
	_AutoItObject_AddProperty($oRet, "includeLauncher", $ELSCOPE_PUBLIC, $build_includeLauncher)

	; VCS
	_AutoItObject_AddProperty($oRet, "teenyscript_TS_AppVer", $ELSCOPE_READONLY, $teenyscript_TS_AppVer)
	_AutoItObject_AddProperty($oRet, "teenyscript_TS_ProjectFile", $ELSCOPE_READONLY, $_TS_ProjectFile)

	Return $oRet
EndFunc

Func _TS_Project_setSettings($_TS_ProjectFile, _
	$main_name, _
	$main_ver, _
	$main_copyright, _
	$build_arch, _
	$build_dir, _
	$build_icon, _
	$build_type, _
	$build_includeLauncher, _
	$bUpdateTSver = False)
	If Not FileExists($_TS_ProjectFile) Then Return Null

	IniWrite($_TS_ProjectFile, "main", "name", $main_name)
	IniWrite($_TS_ProjectFile, "main", "ver", $main_ver)
	IniWrite($_TS_ProjectFile, "main", "copyright", $main_copyright)
	IniWrite($_TS_ProjectFile, "build", "arch", $build_arch)
	IniWrite($_TS_ProjectFile, "build", "dir", $build_dir)
	IniWrite($_TS_ProjectFile, "build", "icon", $build_icon)
	IniWrite($_TS_ProjectFile, "build", "type", $build_type)
	IniWrite($_TS_ProjectFile, "build", "includeLauncher", $build_includeLauncher)

	If $bUpdateTSver Then IniWrite($_TS_ProjectFile, "teenyscript", "_TS_AppVer", $_TS_AppVer)
	Return False
EndFunc


Func _TS_Project_parseMacrostring($sString, $build_arch, $main_name, $main_ver, $project_dir)
	$sString = StringReplace($sString, "%main.name%", $main_name)
	$sString = StringReplace($sString, "%main.ver%", $main_ver)
	$sString = StringReplace($sString, "%build.arch%", $build_arch)
	Return StringReplace($sString, "%project.dir%", $project_dir)
EndFunc

Func _TS_Project_createLauncher($oProject); Creates a file used

	; Create our bogus file
	Local $sNewFile = StringFormat("%s\launcher.au3", $oProject.dir)

	; Replace macros from our launcher.au3
	Local $sFileContent = StringReplace($_TS_Project_LazyLoaded_Template, "%project.name%", $oProject.name)
	$sFileContent = StringReplace($sFileContent, "%teenyscript._TS_AppVer%", $_TS_AppVer)

	; Write the new data
	Local Const $fHandle = FileOpen($sNewFile, $FO_OVERWRITE)
	FileWrite($fHandle, $sFileContent)
	FileClose($fHandle)

	; Compile the new file
	_SciTe_compileFile($sNewFile, $oProject.dir, $oProject.name, $oProject.icon, "32", "TeenyScript Launcher", $_TS_AppVer, $_TS_AppTitle)

	;  Cleanup
	FileDelete($sNewFile)

EndFunc