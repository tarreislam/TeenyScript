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
; ~ TS related resources
Global Const $_TS_AppTitle = "TeenyScript"
Global Const $_TS_AppVer = "1.2.0";Do not edit these because they will be used for version-checking your project against the version of TS you are running and will also be compiled along with Autoits version
Global Const $_TS_FullAppTitle = StringFormat("%s %s", $_TS_AppTitle, $_TS_AppVer)
Global Const $_TS_OptFile = @ScriptDir & "\TS.opt.ini"
Global Const $_TS_TeenyScript_DIR = @ScriptDir & "\TeenyScript"
Global Const $_TS_Dependencies_Dir = $_TS_TeenyScript_DIR & "\_Dependencies_"; AutoitObject only atm
Global Const $_TS_Project_Template_Dir = $_TS_TeenyScript_DIR & "\Templates"
Global Const $_TS_Project_TS_Template_DIR = $_TS_Project_Template_Dir & "\TS Projects"
; ~ Ts Reserved variables
Global Const $_TS_ObjectName = "this"

; ~ Ts misc
Global Const $_TS_Project_Ts_PROJECT_INI = "TS.project.ini"
Global Const $_TS_Project_FilePatt = "%s\" & $_TS_Project_Ts_PROJECT_INI; This will hold specifik stuff for that "project" like name, X32, x64 (or both), output DIR, and a "Also copy these files \ folders" and icon for each out file "name"


; $_resource_curFileNameDISPLAY : $oNamespace.raw : $item.cleanName : $item.paramsRaw
Global Const $_TS_Debug = ";TS_DEBUG=%s:%s:%s:%s"

; ~ Misc of misc
Global Enum $_TS_COMPILE_RUN, $_TS_COMPILE_BUILD_AU3, $_TS_COMPILE_BUILD_EXE

; ~ Autoit related resources
Global Const $_AU3_EXE = @AutoItExe
Global Const $_AU3_DIR = getFromFilepath_basedir($_AU3_EXE)
Global Const $_AU3_AU2EXE = $_AU3_DIR & "\Aut2Exe\Aut2Exe.exe"
Global Const $_AU3_AU2EXE_64 = $_AU3_DIR & "\Aut2Exe\Aut2Exe_x64.exe"
Global Const $_AU3_SCITE_ROAMING_DIR = @LocalAppDataDir & "\AutoIt v3\SciTE"; For calltips mostly
Global Const $_AU3_SCITE_DIR  = $_AU3_DIR & "\SciTE"
Global Const $_AU3_INCLUDE_DIR = $_AU3_DIR & "\Include"
Global Const $_AU3_SCITE_EXE = $_AU3_SCITE_DIR & "\SciTE.exe"

; ~ Scite related resources
Global Const $_SCITE_TIDY = $_AU3_SCITE_DIR & "\Tidy\Tidy.exe"
Global Const $_SCITE_USER_CALLTIPS_API = $_AU3_SCITE_DIR & "\au3.user.calltips.api"
Global Const $_SCITE_USER_UDFS_PROPS = $_AU3_SCITE_DIR & "\au3.UserUdfs.properties"
Global Const $_SCITE_HWND = WinGetHandle("[CLASS:SciTEWindow]")

Global Const $_SCITE_Hotkey_RUN = IniRead($_TS_OptFile, "hotkeys", "run", "{F5}")
Global Const $_SCITE_Hotkey_BUILD_AU3 = IniRead($_TS_OptFile, "hotkeys", "build_au3", "{F6}")
Global Const $_SCITE_Hotkey_BUILD_EXE = IniRead($_TS_OptFile, "hotkeys", "build_exe", "{F7}")
Global Const $_SCITE_Hotkey_SET_OPTIONS = IniRead($_TS_OptFile, "hotkeys", "set_options", "{F8}"); allt ska vara här @x64 parametrar och Requireadmin etcetc "Project dir" och "New Project" etcc
Global Const $_SCITE_Hotkey_EXIT = IniRead($_TS_OptFile, "hotkeys", "exit", "{F10}")

; ~ LazyLoad section
; project Launcher
Global Const $_TS_Project_LazyLoaded_Template = _TS_LazyLoad($_TS_Project_Template_Dir & "\Misc\Launcher.au3")
; AutoitObject
Global Const $_TS_LazyLoadDependencies = [$_TS_Dependencies_Dir & "\AutoItObject.au3", $_TS_Dependencies_Dir & "\CustomInit.au3"]
Global Const $_TS_LazyLoadedContent = _TS_LazyLoad($_TS_LazyLoadDependencies)

; Hotkeys
Global Const $_SCITE_HotkeyCollectionDisplayNames = [5, "Run script", "Build 'AU3'", "Build 'EXE'", "Options GUI", "Exit "&$_TS_AppTitle]
Global $_SCITE_HotkeyCollectionKeys = [5, $_SCITE_Hotkey_RUN, $_SCITE_Hotkey_BUILD_AU3, $_SCITE_Hotkey_BUILD_EXE, $_SCITE_Hotkey_SET_OPTIONS, $_SCITE_Hotkey_EXIT]; no longer CONST
Global Const $_SCITE_HotkeyCollectionFunctNames = [5, "_TS_HOTKEY_RUN", "_TS_HOTKEY_BUILD_AU3", "_TS_HOTKEY_BUILD_EXE", "_TS_HOTKEY_SET_OPT", "_TS_HOTKEY_Exit"]
Global Const $_SCITE_HotkeyCollectionIniNames = [5, "run", "build_au3", "build_exe", "set_options", "exit"]; Only for Gui stuff mkay

#Region Calltips
Global Const $_SCITE_aCALLTIPS = ["@Private?3", "@Public?3", "@Readonly?3", "@Use?3", "@Namespace?3", "@MethodName?3", "@MethodParams?3", "@Extends?3", _
"Class ($x = Func(Class....) Creates a new class)", _
"Extension (Usage: $x = Func(Extension....) Creates an extension that can be used on a previously created Class)", _
"Construct (Usage: $x = Func(Construct....) May only be used inside a Class", _
"As (Usage: @Use ... As ....)", _
"At (Usage: @Use ... At ....)", _
"On (Usage: @Use ... On ....)", _
"__Parent__ (Usage: $X.__Parent__) (Returns the parent object (If no parent exists, NULL will be returned))", _
"__cName__ (Usage: $X.__cName__) (Returns the name of that class as a string.)", _
"__Properties__ (Usage: $X.__Properties__) (Returns the parameters of that class as a string.)", _
"__Namespace__ (Usage: $X.__Namespace__) (Returns the namespace of that class as a string. (If no namespace is set, an EMPTY STRING is returned))", _
"__Methods__ (Usage: $X.__Methods__) (Returns an array of defined methods in that class. This is inteded for developers and have no particular functionality for users) (Does not include extensions)", _
"_TS_ErrorNotify (Usage: _TS_ErrorNotify($_TS_IGNORE or $_TS_CONSOLE or $_TS_MSGBOX)) (Returns the previous option SET, default for non-comipled scripts is $_TS_CONSOLE and $_TS_MSGBOX for compiled scripts)"]

Global Const $_SCITE_aUSER_UDFS = ["@private", "@public", "@readonly", "@use", "@namespace", "@methodname", "@methodparams", "@extends", "class", "extension", "construct", "as", "at", "on", _
"__parent__", "__cname__", "__namespace__", "__Properties__", "__methods__", "_TS_ErrorNotify"]
#EndRegion


; ~~~ Variable names meant for no colission

;  ---------------------------------------------------------
; |				Outside function names						|
;  ---------------------------------------------------------
Global Const $_name_Function = getRandomString(2)
Global Const $_name_Closure = getRandomString(4)

;  ---------------------------------------------------------
; |					Inside function names					|
;  ---------------------------------------------------------
; ~ New random names for AutoitObject_Class()
Global Const $_name_AOClass = getRandomString(3)
; ~ New random names for __Methods__ and __Properties__ Arrays
Global Const $_name_AOProperties = getRandomString(4)
Global Const $_name_AOMethods = getRandomString(5)
; ~ New random names for Lists
Global Const $_name_List = getRandomString(6)
; ~ New random names for EzArray (Return [1,2,3,4,5]) GÖR SÅ
Global Const $_name_ezArray = getRandomString(7)

;  ---------------------------------------------------------
; |					Teeny script resources					|
;  ---------------------------------------------------------

Global $_TS_resource_aHotkeyStorage[1] = [0]

;  ---------------------------------------------------------
; |				Global	Parse-Data	stuff					|
;  ---------------------------------------------------------


;Global $_resource_mainFile = False
; ~ Error related ~
Global $_resource_TS_aErrors[1] = [0]
; ~

Global $_resource_CmdLine = IniRead($_TS_OptFile, "misc", "CmdLine", "")
Global $_resource_HotkeysEnabled = True; To prevent hotkey spam

Global $_resource_sExecFile = ""; The file which is the "base-dir"

; A lazy thing for showing user which file this is
Global $_resource_curFileNameDISPLAY = "";Should only for _TS_error reports

Global $_resource_clousreCount = 0; All closure counts (Global)
Global $_resource_sFuncCount = 0; Each function count for all files
Global $_resource_ffBuffer = ""; The whole new file
Global $_resource_ffDebug = ""; Only the #DEBUG stuff
Global $_resource_aNamespaces[1] = [0]

Global $_resource_bLazyLoad = False;If we are going to lazyLoad AO or not since not all scripts needs it


Func _TS_ResetResources()
	$_resource_curFileNameDISPLAY = ""
	$_resource_sExecFile = "";
	$_resource_clousreCount = 0
	$_resource_sFuncCount = 0
	$_resource_ffBuffer = ""
	$_resource_ffDebug = ""
	_Array_Empty($_resource_aNamespaces); mby not needed either!? mby only ClosureCount and FFbuffer needed
	$_resource_bLazyLoad = False
EndFunc


#Region Error Related

Func _TS_AbortedByUser($hParent = 0)
	MsgBox($MB_ICONWARNING, $_TS_AppTitle, "Operation aborted by user", 0, $hParent)
	Return False
EndFunc

Func _TS_SetError($iCode, $iExtended, $mReturn, $sText = "", $p1 = "", $p2 = "", $p3 = "")
	Local $aRes = [$iCode, $iExtended, $mReturn, StringFormat($sText, $p1, $p2, $p3)]
	_Array_Push($_resource_TS_aErrors, $aRes)
	Return $mReturn
EndFunc

Func _TS_ResetError()
	_Array_Empty($_resource_TS_aErrors)
EndFunc

Func _TS_Error(); returns Num errors
	Return $_resource_TS_aErrors[0]; < 1 = false, > 0 = True
EndFunc

Func _TS_DisplayError()
	Local $cur, $iCode, $iExtended, $mReturn, $sText
	$ConsoleWrite("%s Failed to compile. Here is the trace", "b", $_TS_AppTitle)
	Local $x = 1
	For $i = $_resource_TS_aErrors[0] To 1 Step -1
		$cur = $_resource_TS_aErrors[$i]
		$iCode = $cur[0]
		$iExtended = $cur[1]
		$mReturn = $cur[2]
		$sText = $cur[3]

		$ConsoleWrite("#%d", "r", $x)
		;$ConsoleWrite("@Error:    %s", "r", $iCode)
		;$ConsoleWrite("@Extended: %s", "r", $iExtended)
		;$ConsoleWrite("@Return:   %s", "r", $mReturn)
		$ConsoleWrite($sText, "r")
		ConsoleWrite(@CRLF)
		$x+=1
	Next
	Return False
EndFunc

#EndRegion Error Related
; Load file content into memory instead of using FileRead everytime a script is getting compiled, this can be used by lazy people (Like me Tarre*3)
Func _TS_LazyLoad($aFilepaths)
	Local $sRet, $sFilePaths

	if Not IsArray($aFilepaths) Then
		$sFilePaths = $aFilepaths
		_TS_LazyLoad_Item($sRet, $aFilepaths)
	Else
		$sFilePaths = _ArrayToString($aFilepaths, ", ")
		For $i = 0 to UBound($aFilepaths) - 1
			Local $sCurFile = $aFilepaths[$i]
			_TS_LazyLoad_Item($sRet, $sCurFile)
		Next
	EndIf

	Return "#Region LazyLoaded: " & $sFilePaths & $sRet & @CRLF & "#EndRegion LazyLoaded: " & $sFilePaths & @CRLF
EndFunc

Func _TS_LazyLoad_Item(ByRef $sRet, $sCurFile)
	if not FileExists($sCurFile) Then
		MsgBox($MB_ICONWARNING, $_TS_FullAppTitle, StringFormat("LazyLoaded file '%s' was not found and wont be included", $sCurFile))
	Else
		$sRet &= @CRLF & StringFormat($_TS_Debug, $sCurFile, "Unkown", "Unkown", "Unkown") & @CRLF & FileRead($sCurFile) & @CRLF
	EndIf
EndFunc


Func _TS_Init()
	Sleep(500)
	_Scite_SendMessage() ; Clear Output pane "IDM_CLEAROUTPUT"
	$ConsoleWrite(" _____                 _____         _     _   ", "o")
	$ConsoleWrite("|_   _|___ ___ ___ _ _|   __|___ ___|_|___| |_ ", "o")
  	$ConsoleWrite("  | | | -_| -_|   | | |__   |  _|  _| | . |  _| ", "o")
  	$ConsoleWrite("  |_| |___|___|_|_|_  |_____|___|_| |_|  _|_|   ", "o")
    $ConsoleWrite(STR_PAD("By TarreTarreTarre", $STR_PAD_RIGHT, 18) & "|___|"&STR_PAD(StringFormat("Build '%s'",$_TS_AppVer),$STR_PAD_LEFT, 15, " ")&"|_|       ", "o")

	; Set keybinds and display their usage
	For $i = 1 to $_SCITE_HotkeyCollectionKeys[0]
		$ConsoleWrite("%s = %s","g", StringRegExpReplace($_SCITE_HotkeyCollectionKeys[$i], "\{(.*)\}", "$1"), $_SCITE_HotkeyCollectionDisplayNames[$i])
	Next
	; Enable hotkeys
	_TS_HotkeyManager(True)
	; Register destructor
	OnAutoItExitRegister("_TS_Exit_Auto")
	; Start main loop
	AdlibRegister("_TS_ADLIB", 150)
EndFunc


; TeenyScripts "Main loop"
Func _TS_ADLIB()
	;Disable HotkeyMgr when not inside scite...
	Local $awh = WinGetHandle("[ACTIVE]")
	If $_SCITE_HWND <> $awh And $_resource_HotkeysEnabled Then
		$_resource_HotkeysEnabled = False
		_TS_HotkeyManager(False)
	ElseIf $_SCITE_HWND == $awh And Not $_resource_HotkeysEnabled Then
		$_resource_HotkeysEnabled = True
		_TS_HotkeyManager(True)
	EndIf
	;Else do nothing. no need to spam

	if Not IsHWnd($_SCITE_HWND) Then
		AdlibUnRegister("_TS_ADLIB"); Prevents multiple popup boxes
		MsgBox($MB_ICONINFORMATION, $_TS_FullAppTitle, StringFormat("%s closed because the SciTe window was closed.", $_TS_AppTitle), 5)
		Exit
	EndIf
EndFunc

Func _TS_Exit_Auto()
	_Scite_SendMessage() ; Clear Output pane "IDM_CLEAROUTPUT"
	$ConsoleWrite("%s closed unexpected @ %s:%s:%s", "r", $_TS_AppTitle, @HOUR, @MIN, @SEC)
EndFunc

