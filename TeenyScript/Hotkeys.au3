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
Func _TS_HOTKEY_RUN()

	Local $aFile = _TS_YeahDnoWhatThisShouldbeNamed();[0] = $sAu3FileName, [1] = $sTsFileName
	If Not IsArray($aFile) Then Return False

	_Scite_runFile($aFile[0], $aFile[1]); Bör inte vara här? Denna funktion ska ba baba

	If Not FileDelete($aFile[0]) Then MsgBox($MB_ICONERROR, $_TS_AppTitle, StringFormat("Failed to remove the file '%s', it may be used by some other process?", $aFile[0]))
EndFunc

Func _TS_HOTKEY_BUILD_AU3()

	Local $aFile = _TS_YeahDnoWhatThisShouldbeNamed();[0] = $sAu3FileName, [1] = $sTsFileName
	If Not IsArray($aFile) Then Return False

	$ConsoleWrite("Conversion from '%s' to '%s' was successful!", "g", $aFile[1], $aFile[0])
EndFunc

Func _TS_HOTKEY_BUILD_EXE()

	Local $aFile = _TS_YeahDnoWhatThisShouldbeNamed();[0] = $sAu3FileName, [1] = $sTsFileName
	If Not IsArray($aFile) Then Return False


	; Check if project file is found3d
	Local $sProjectIniFile = StringFormat($_TS_Project_FilePatt, getFromFilepath_basedir($aFile[0]))
	If FileExists($sProjectIniFile) Then
		$ConsoleWrite("Found TS.project.ini, now compiling with options", "g")

		Local Const $getFromFilepath_basedir = getFromFilepath_basedir(_SciTe_getOpenFileName())
		Local Const $_TS_ProjectFile = StringFormat($_TS_Project_FilePatt, $getFromFilepath_basedir)
		Local Const $oProjectSettings = _TS_Project_getSettings($_TS_ProjectFile, $getFromFilepath_basedir)

		_SciTe_compileFile($aFile[0], _
		$oProjectSettings.dir, _
		$oProjectSettings.icon, _
		$oProjectSettings.arch, _
		$oProjectSettings.name, _
		$oProjectSettings.ver, _
		$oProjectSettings.copyright, _
		$oProjectSettings.type)

	Else
		_SciTe_compileFile($aFile[0])
	EndIf

	If Not FileDelete($aFile[0]) Then MsgBox($MB_ICONERROR, $_TS_AppTitle, StringFormat("Failed to remove the file '%s', it may be used by some other process?", $aFile[0]))
EndFunc

Func _TS_HOTKEY_SET_OPT()
	GuiOpt_Main()
EndFunc

Func _TS_HOTKEY_Exit()
	OnAutoItExitUnRegister("_TS_Exit_Auto"); Remove destructor
	_Scite_SendMessage() ; Clear Output pane "IDM_CLEAROUTPUT"
	$ConsoleWrite("%s closed by user @ %s:%s:%s", "r", $_TS_AppTitle, @HOUR, @MIN, @SEC)
	Exit
EndFunc

Func _TS_HotkeyManager($bEnable = True)


	For $i = 1 to $_SCITE_HotkeyCollectionKeys[0]

		If $bEnable Then
			HotKeySet($_SCITE_HotkeyCollectionKeys[$i], $_SCITE_HotkeyCollectionFunctNames[$i])
		Else
			HotKeySet($_SCITE_HotkeyCollectionKeys[$i])
		EndIf
	Next

EndFunc