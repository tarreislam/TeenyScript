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

	Local $aFile = _TS_YeahDnoWhatThisShouldbeNamed();[0] = $sAu3FileName, [1] $sAu3Filename_tmp, [2] = $sTsFileName, [3] = $oProject
	If Not IsArray($aFile) Then Return False
	Local Const $sAu3FileName = $aFile[0]
	Local Const $sAu3Filename_tmp = $aFile[1]
	Local Const $sTsFileName = $aFile[2]
	Local Const $oProject = $aFile[3]

	If IsObj($oProject) Then _TS_Project_VCS($oProject)

	; display da file
	_Scite_runFile($sAu3FileName, $sTsFileName)

EndFunc

Func _TS_HOTKEY_BUILD_AU3()

	Local $aFile = _TS_YeahDnoWhatThisShouldbeNamed();[0] = $sAu3FileName, [1] $sAu3Filename_tmp, [2] = $sTsFileName, [3] = $oProject
	If Not IsArray($aFile) Then Return False
	Local Const $sAu3FileName = $aFile[0]
	Local Const $sAu3Filename_tmp = $aFile[1]
	Local Const $sTsFileName = $aFile[2]
	Local Const $oProject = $aFile[3]

	If IsObj($oProject) Then _TS_Project_VCS($oProject); Run Version Control System

	$ConsoleWrite("Conversion from '%s' -> '%s' was successful!", "g", $sTsFileName, $sAu3FileName)

EndFunc

Func _TS_HOTKEY_BUILD_EXE()

	Local $aFile = _TS_YeahDnoWhatThisShouldbeNamed();[0] = $sAu3FileName, [1] $sAu3Filename_tmp, [2] = $sTsFileName, [3] = $oProject
	If Not IsArray($aFile) Then Return False
	Local Const $sAu3FileName = $aFile[0]
	Local Const $sAu3Filename_tmp = $aFile[1]
	Local Const $sTsFileName = $aFile[2]
	Local Const $oProject = $aFile[3]



	If IsObj($oProject) Then
		$ConsoleWrite("Found %s, compiling with options", "g", $_TS_Project_Ts_PROJECT_INI)
		_TS_Project_VCS($oProject); Run Version Control System

		; Check if we going to build a launcher
		If $oProject.includeLauncher == "True" Then
			_TS_Project_createLauncher($oProject)
		EndIf

		_SciTe_compileFile($sAu3Filename_tmp, _
		$oProject.dir, _
		False, _
		$oProject.icon, _
		$oProject.arch, _
		$oProject.name, _
		$oProject.ver, _
		$oProject.copyright, _
		$oProject.type)
	Else
		; Copy file and parse then delete if we dont have project settings
		FileCopy($sAu3Filename_tmp, $sAu3FileName, $FC_OVERWRITE)
		_SciTe_compileFile($sAu3FileName)
		FileDelete($sAu3FileName)
	EndIf

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