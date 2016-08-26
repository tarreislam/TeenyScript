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
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <WindowsConstants.au3>
Global Const $___MacroZzzZz = @CRLF & @CRLF & "~Avilable macros " & @CRLF & @CRLF & "%main.name% = Project name" & @CRLF & "%main.ver% = Project version" & @CRLF & "%build.arch% = 32, 64 or 96" & @CRLF &"%project.dir% = Directory of TS.project.ini" & @CRLF

Global $Gui_Main, $gui_Project_Settings, $gui_Main_Input_CmdLine, $gui_Main_btn_create_new_project, $gui_Main_btn_edit_project, $gui_Hotkeys_list_hotkeys, $gui_Hotkeys_btn_change, $gui_Hotkeys_btn_reset_to_default, _
$gui_Main_btn_install_calltips, $gui_Project_Settings_radio_32_bit, $gui_Project_Settings_radio_64_bit, $gui_Project_Settings_radio_32_and_64_bit, $gui_Project_Settings_input_project_name, _
$gui_Project_Settings_input_project_version, $gui_Project_Settings_btn_output_dir, $gui_Project_Settings_input_output_dir, $gui_Project_Settings_btn_icon, $gui_Project_Settings_input_icon, _
$gui_Project_Settings_btn_save, $gui_Project_Settings_input_project_copyright_holder
; When exiting from the main function
Func GuiOpt_Main_Exit()
	Local $_GET_Main_Input_CmdLine = GUICtrlRead($gui_Main_Input_CmdLine)
	$_resource_CmdLine = $_GET_Main_Input_CmdLine
	;write the last used CmdLine
	IniWrite($_TS_OptFile, "misc", "CmdLine", $_GET_Main_Input_CmdLine)
	Return GuiOpt_Exit()
EndFunc

Func GuiOpt_Project_Settings_Save()
	Local $Warnings = 0
	Local Const $getFromFilepath_basedir = getFromFilepath_basedir(_SciTe_getOpenFileName())
	Local Const $_TS_ProjectFile = StringFormat($_TS_Project_FilePatt, $getFromFilepath_basedir)
	If Not FileExists($_TS_ProjectFile) Then Return MsgBox($MB_ICONWARNING, $_TS_AppTitle, "Failed to save in 'TS.project.ini', make sure SciTE is focused on the main file that co-exists with the TS.project.ini file", 0, $gui_Project_Settings)

	;Save arch (Nothing can go wrong here)
	If GUICtrlRead($gui_Project_Settings_radio_32_bit) == $GUI_CHECKED Then IniWrite($_TS_ProjectFile, "build", "arch", "32")
	If GUICtrlRead($gui_Project_Settings_radio_64_bit) == $GUI_CHECKED Then IniWrite($_TS_ProjectFile, "build", "arch", "64")
	If GUICtrlRead($gui_Project_Settings_radio_32_and_64_bit) == $GUI_CHECKED Then IniWrite($_TS_ProjectFile, "build", "arch", "96")
	If isEmpty(GUICtrlRead($gui_Project_Settings_input_project_name)) Then Return MsgBox($MB_ICONWARNING, $_TS_AppTitle, "The project name may not be empty")
	If StringRight(GUICtrlRead($gui_Project_Settings_input_output_dir), 1) == "\" Then Return MsgBox($MB_ICONWARNING, $_TS_AppTitle, "The Output dir may not end with an backslash '\'")

	IniWrite($_TS_ProjectFile, "main", "name", GUICtrlRead($gui_Project_Settings_input_project_name))
	IniWrite($_TS_ProjectFile, "main", "ver", GUICtrlRead($gui_Project_Settings_input_project_version))
	IniWrite($_TS_ProjectFile, "main", "copyright", GUICtrlRead($gui_Project_Settings_input_project_copyright_holder))

	IniWrite($_TS_ProjectFile, "build", "dir", GUICtrlRead($gui_Project_Settings_input_output_dir))
	IniWrite($_TS_ProjectFile, "build", "icon", GUICtrlRead($gui_Project_Settings_input_icon))

	; Generate warning if the directory dosent exist (Dont prompt it as an error)
	Local Const $oProjectSettings = _TS_Project_getFinalProjectSettings($_TS_ProjectFile, $getFromFilepath_basedir)

	If Not FileExists($oProjectSettings.dir) Then
		$Warnings+=1
		MsgBox($MB_ICONWARNING, $_TS_AppTitle, StringFormat("Warning! '%s' the directory '%s' does not exist yet.", GUICtrlRead($gui_Project_Settings_input_output_dir), $oProjectSettings.dir), 0, $Gui_Main)
	EndIf
	If Not FileExists($oProjectSettings.icon) Then
		$Warnings+=1
		MsgBox($MB_ICONWARNING, $_TS_AppTitle, StringFormat("Warning! '%s' the icon '%s' does not exist yet.", GUICtrlRead($gui_Project_Settings_input_icon), $oProjectSettings.icon), 0, $Gui_Main)
	EndIf

	MsgBox(($Warnings ? $MB_ICONWARNING : $MB_ICONINFORMATION), $_TS_AppTitle, "Project settings updated " & ($Warnings ? StringFormat("with %d warnings", $Warnings) :  "successfully!"), 0, $gui_Project_Settings)
EndFunc

Func GuiOpt_Exit()
	GUIDelete(@GUI_WinHandle)
EndFunc

Func GuiOpt_Main()
	If IsHWnd($Gui_Main) Then Return WinActivate($Gui_Main)
	$Gui_Main = GUICreate(StringFormat("%s Settings", $_TS_AppTitle), 280, 248, 418, 269)
	GUICtrlCreateTab(2, 2, 273, 233)
	GUICtrlCreateTabItem("Main")
	GUICtrlCreateLabel("CmdLine parameters", 10, 42, 100, 17)
	$gui_Main_Input_CmdLine = GUICtrlCreateInput("", 10, 66, 145, 21)
	$gui_Main_btn_create_new_project = GUICtrlCreateButton("Create new project", 154, 202, 115, 25)
	$gui_Main_btn_edit_project = GUICtrlCreateButton("&Edit Project Settings", 8, 200, 115, 25)
	GUICtrlCreateTabItem("Hotkeys")
	$gui_Hotkeys_btn_change = GUICtrlCreateButton("Change", 10, 202, 75, 25)
	$gui_Hotkeys_btn_reset_to_default = GUICtrlCreateButton("Reset to default", 178, 202, 91, 25)
	$gui_Hotkeys_list_hotkeys = GUICtrlCreateListView("", 8, 32, 258, 166)
	GUICtrlCreateTabItem("Misc")
	$gui_Main_btn_install_calltips = GUICtrlCreateButton("Install Calltips to scite", 8, 32, 155, 25)
	GUICtrlCreateTabItem("")
	GUISetState(@SW_SHOW)


	; Exit window
	GUISetOnEvent($GUI_EVENT_CLOSE, "GuiOpt_Main_Exit")
	;Set hotkey
	GUICtrlSetOnEvent($gui_Hotkeys_btn_change, "GuiOpt_Main_SetHotkey")
	;Reset to default hotkeys
	GUICtrlSetOnEvent($gui_Hotkeys_btn_reset_to_default, "GuiOpt_Main_ResetHotkey")

	;Install Calltips
	GUICtrlSetOnEvent($gui_Main_btn_install_calltips, "GuiOpt_Main_btn_install_calltips")

	;Edit project
	GUICtrlSetOnEvent($gui_Main_btn_edit_project, "GuiOpt_Project_Settings_Edit_Project")
	;New project
	GUICtrlSetOnEvent($gui_Main_btn_create_new_project, "GuiOpt_Project_Settings_create_new_project")
	; Display hotkeys
	GuiOpt_Main_getHotkeyList()
EndFunc

#Region Misc
Func GuiOpt_Main_btn_install_calltips()
	MsgBox($MB_ICONINFORMATION, $_TS_AppTitle, "Installning calltips requires SciTE to restart.", 0, $Gui_Main)

	If FileExists($_SCITE_USER_CALLTIPS_API) Then
		$MsgBox = MsgBox($MB_ICONWARNING + $MB_YESNO, $_TS_AppTitle, StringFormat("The file '%s' already exists. Previous content will be ereased, do you wish to proceed?",$_SCITE_USER_CALLTIPS_API), 0, $Gui_Main)
		If $MsgBox == $IDNO Then Return MsgBox($MB_ICONWARNING, $_TS_AppTitle, "Aborted by user", 0, $Gui_Main)
	EndIf

	If FileExists($_SCITE_USER_UDFS_PROPS) Then
		$MsgBox = MsgBox($MB_ICONWARNING + $MB_YESNO, $_TS_AppTitle, StringFormat("The file '%s' already exists. Previous content will be ereased, do you wish to proceed?",$_SCITE_USER_CALLTIPS_API), 0, $Gui_Main)
		If $MsgBox == $IDNO Then Return MsgBox($MB_ICONWARNING, $_TS_AppTitle, "Aborted by user", 0, $Gui_Main)
	EndIf

	;install Calltips
	Local Const $sCalltips_api = _ArrayToString($_SCITE_aCALLTIPS, @CRLF)
	Local $sUserUdfs_props = StringFormat("au3.keywords.user.udfs=%s", StringLower(_ArrayToString($_SCITE_aUSER_UDFS, " ")))

	Local Const $sCalltips_apiHandle = FileOpen($_SCITE_USER_CALLTIPS_API, $FO_OVERWRITE + $FO_CREATEPATH)
	If Not $sCalltips_apiHandle Then Return MsgBox($MB_ICONWARNING, $_TS_AppTitle, StringFormat("Failed to open '%s' for writing", $_SCITE_USER_CALLTIPS_API), 0, $Gui_Main)
	FileWrite($sCalltips_apiHandle, $sCalltips_api)
	FileClose($sCalltips_apiHandle)

	; Install au3.UserUdfs.properties

	Local Const $sUserUdfs_propsHandle = FileOpen($_SCITE_USER_UDFS_PROPS, $FO_OVERWRITE + $FO_CREATEPATH)
	If Not $sUserUdfs_propsHandle Then Return MsgBox($MB_ICONWARNING, $_TS_AppTitle, StringFormat("Failed to open '%s' for writing", $_SCITE_USER_UDFS_PROPS), 0, $Gui_Main)
	FileWrite($sUserUdfs_propsHandle, $sUserUdfs_props)
	FileClose($sUserUdfs_propsHandle)

	If FileExists($_AU3_SCITE_ROAMING_DIR) Then
		$MsgBox = MsgBox($MB_ICONINFORMATION + $MB_YESNO, $_TS_AppTitle, StringFormat("Scite was also detected in '%s' would you like to copy the files there?", $_AU3_SCITE_ROAMING_DIR), 0, $Gui_Main)
		; Copy to roaming dir and replace
		If $MsgBox == $IDYES Then
			FileCopy($_SCITE_USER_CALLTIPS_API, $_AU3_SCITE_ROAMING_DIR, $FC_OVERWRITE)
			FileCopy($_SCITE_USER_UDFS_PROPS, $_AU3_SCITE_ROAMING_DIR, $FC_OVERWRITE)
		EndIf
	EndIf


	MsgBox($MB_ICONINFORMATION, $_TS_AppTitle, "Calltips installed successfully!", 0, $Gui_Main)

EndFunc
#EndRegion Misc

#Region Project related
Func GuiOpt_Project_Settings_Edit_Project()
	If IsHWnd($gui_Project_Settings) Then Return WinActivate($gui_Project_Settings)
	; Check if we can find that damn file xD
	Local Const $_TS_ProjectFile = StringFormat($_TS_Project_FilePatt, getFromFilepath_basedir(_SciTe_getOpenFileName()))

	If Not FileExists($_TS_ProjectFile) Then Return MsgBox($MB_ICONWARNING, $_TS_AppTitle, "Could not find 'TS.project.ini', make sure SciTE is focused on the main file that co-exists with the TS.project.ini file", 0, $gui_Project_Settings)

	$gui_Project_Settings = GUICreate("Edit Project Settings", 241, 412, 691, 390)
	GUICtrlCreateGroup("Architecture  options", 8, 8, 225, 41)
	$gui_Project_Settings_radio_32_bit = GUICtrlCreateRadio("32 bit", 16, 24, 57, 17)
	$gui_Project_Settings_radio_64_bit = GUICtrlCreateRadio("64 bit", 80, 24, 49, 17)
	$gui_Project_Settings_radio_32_and_64_bit = GUICtrlCreateRadio("32 && 64 bit", 136, 24, 81, 17)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateGroup("File Details", 8, 56, 225, 161)
	GUICtrlCreateLabel("Project name", 16, 72, 66, 17)
	$gui_Project_Settings_input_project_name = GUICtrlCreateInput("", 16, 88, 209, 21)
	GUICtrlCreateLabel("Project version", 16, 112, 74, 17)
	$gui_Project_Settings_input_project_version = GUICtrlCreateInput("", 16, 136, 209, 21)
	GUICtrlCreateLabel("Copyright holder", 16, 160, 80, 17)
	$gui_Project_Settings_input_project_copyright_holder = GUICtrlCreateInput("", 16, 184, 209, 21)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateGroup("Misc", 8, 224, 225, 145)
	$gui_Project_Settings_btn_output_dir = GUICtrlCreateButton("&Output dir", 16, 248, 75, 25)
	$gui_Project_Settings_input_output_dir = GUICtrlCreateInput("", 16, 280, 209, 21)
	$gui_Project_Settings_btn_icon = GUICtrlCreateButton("&Icon", 16, 304, 75, 25)
	$gui_Project_Settings_input_icon = GUICtrlCreateInput("", 16, 336, 209, 21)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$gui_Project_Settings_btn_save = GUICtrlCreateButton("Verify && Apply", 136, 376, 91, 25)

	; Set data
	GUICtrlSetData($gui_Project_Settings_input_project_name, IniRead($_TS_ProjectFile, "main", "name", "Unkown"))
	GUICtrlSetData($gui_Project_Settings_input_project_version, IniRead($_TS_ProjectFile, "main", "ver", "Unkown"))
	GUICtrlSetData($gui_Project_Settings_input_project_copyright_holder, IniRead($_TS_ProjectFile, "main", "copyright", @UserName))
	GUICtrlSetData($gui_Project_Settings_input_output_dir, IniRead($_TS_ProjectFile, "build", "dir", "Unkown"))
	GUICtrlSetData($gui_Project_Settings_input_icon, IniRead($_TS_ProjectFile, "build", "icon", "Unkown"))
	; Determine options for Arch
	Switch IniRead($_TS_ProjectFile, "build", "arch", "32"); Will default 32 in WCS
		Case '32'
			GUICtrlSetState($gui_Project_Settings_radio_32_bit, $GUI_CHECKED)
		Case '64'
			GUICtrlSetState($gui_Project_Settings_radio_64_bit, $GUI_CHECKED)
		Case '96'
			GUICtrlSetState($gui_Project_Settings_radio_32_and_64_bit, $GUI_CHECKED)
	EndSwitch
	GUISetState(@SW_SHOW)
	; Exit window && Apply
	GUISetOnEvent($GUI_EVENT_CLOSE, "GuiOpt_Exit"); Ignore changes
	GUICtrlSetOnEvent($gui_Project_Settings_btn_save, "GuiOpt_Project_Settings_Save")
	;Editz
	GUICtrlSetOnEvent($gui_Project_Settings_btn_output_dir, "GuiOpt_Project_Settings_Set_Output_dir")
	GUICtrlSetOnEvent($gui_Project_Settings_btn_icon, "GuiOpt_Project_Settings_Set_Icon")
EndFunc

Func GuiOpt_Project_Settings_create_new_project()
	Local Const $sNewProjectTargetDir = FileSelectFolder(StringFormat("%s - Select a new folder for your project", $_TS_AppTitle), @HomeDrive, 0, "", $Gui_Main)
	If @error Then Return MsgBox($MB_ICONWARNING, $_TS_AppTitle, "Aborted by user", 0, $Gui_Main)

	If Not FileExists($sNewProjectTargetDir) Then Return MsgBox($MB_ICONWARNING, $_TS_AppTitle, StringFormat("Unable to find folder %s", $sNewProjectTargetDir), 0, $Gui_Main)
	; No problems? then we copy content
	Local Const $sNewProjectTemplateDir = StringFormat("%s\New Project", $_TS_Project_Template_Dir)


	If FileExists(StringFormat("%s\TS.project.ini", $sNewProjectTargetDir)) Or FileExists(StringFormat("%s\Main.ts.au3", $sNewProjectTargetDir)) Then
		Local Const $MsgBox = MsgBox($MB_ICONWARNING + $MB_YESNO, $_TS_AppTitle, "A TS project was detected at this directory, would you like to OVERWRITE and continue?", 0, $Gui_Main)
		If $MsgBox == $IDNO Then Return MsgBox($MB_ICONWARNING, $_TS_AppTitle, "Aborted by user", 0, $Gui_Main)
	EndIf

	Local $_FileListToArrayRec = _FileListToArrayRec($sNewProjectTemplateDir, "*", $FLTAR_FILESFOLDERS, $FLTAR_RECUR, $FLTAR_NOSORT, $FLTAR_RELPATH)

	For $i = 1 To $_FileListToArrayRec[0]

		; The source of thangz
		Local $cSource = StringFormat("%s\%s", $sNewProjectTemplateDir, $_FileListToArrayRec[$i])
		Local $cTarget = StringFormat("%s\%s", $sNewProjectTargetDir, $_FileListToArrayRec[$i])

		Switch FileGetAttrib($cSource)

			Case "D"; Create target directory if source is a directory
				If Not DirCreate($cTarget) Then
					Return MsgBox($MB_ICONWARNING, $_TS_AppTitle, "An error occured while creating the directory: " & $cTarget, 0, $Gui_Main)
				EndIf
			Case Else; File
				If Not FileCopy($cSource, $cTarget, $FC_OVERWRITE) Then
					Return MsgBox($MB_ICONWARNING, $_TS_AppTitle, StringFormat("An error occured while copying the file '%s' to '%s'", $cSource, $cTarget), 0, $Gui_Main)
				EndIf
		EndSwitch
	Next

	; Open file main.ts.au3 of project
	_Scite_OpenFile(StringFormat("%s\Main.ts.au3", $sNewProjectTargetDir))

	MsgBox($MB_ICONINFORMATION, $_TS_AppTitle, "The project has been created succesfully!", 0, $Gui_Main)

	;Edit project
	GuiOpt_Project_Settings_Edit_Project()

EndFunc

Func GuiOpt_Project_Settings_Set_Output_dir()
	Local $try = InputBox($_TS_AppTitle, "Set output dir. ! TS AUTOMATICLY INCLUDES PROJECT NAME ! ONLY ENTER THE DESIRED OUT DIRECTORY !" & $___MacroZzzZz, GUICtrlRead($gui_Project_Settings_input_output_dir), Default, 350, 250, Default, Default, 0, $gui_Project_Settings)
	If Not @error Then GUICtrlSetData($gui_Project_Settings_input_output_dir, $try)
EndFunc

Func GuiOpt_Project_Settings_Set_Icon()
	Local $try = InputBox($_TS_AppTitle, "Set icon name." & $___MacroZzzZz, GUICtrlRead($gui_Project_Settings_input_icon), Default, 350, 250, Default, Default, 0, $gui_Project_Settings)
	If Not @error Then GUICtrlSetData($gui_Project_Settings_input_icon, $try)
EndFunc
#EndRegion Project related

#Region Hotkey related
Func GuiOpt_Main_getHotkeyList()
	_GUICtrlListView_DeleteAllItems($gui_Hotkeys_list_hotkeys)
	For $i = 1 To $_SCITE_HotkeyCollectionKeys[0]
		GUICtrlCreateListViewItem(StringFormat("%s|%s",$_SCITE_HotkeyCollectionDisplayNames[$i], $_SCITE_HotkeyCollectionKeys[$i]), $gui_Hotkeys_list_hotkeys)
	Next
	_GUICtrlListView_SetColumnWidth($gui_Hotkeys_list_hotkeys, 0, $LVSCW_AUTOSIZE)
EndFunc

Func GuiOpt_Main_ResetHotkey()
	; Just reset 8-|
	IniWrite($_TS_OptFile, "hotkeys", "run", "{F5}")
	IniWrite($_TS_OptFile, "hotkeys", "build_au3", "{F6}")
	IniWrite($_TS_OptFile, "hotkeys", "build_exe", "{F7}")
	IniWrite($_TS_OptFile, "hotkeys", "set_options", "{F8}")
	IniWrite($_TS_OptFile, "hotkeys", "exit", "{F10}")
	$_SCITE_HotkeyCollectionKeys[1] = "{F5}"
	$_SCITE_HotkeyCollectionKeys[2] = "{F6}"
	$_SCITE_HotkeyCollectionKeys[3] = "{F7}"
	$_SCITE_HotkeyCollectionKeys[4] = "{F8}"
	$_SCITE_HotkeyCollectionKeys[5] = "{F10}"
	GuiOpt_Main_getHotkeyList()
	MsgBox($MB_ICONINFORMATION, $_TS_AppTitle, "Hotkeys reset!")
EndFunc

Func GuiOpt_Main_SetHotkey()
	Local $ListVeiw_Index = _GUICtrlListView_GetSelectedIndices($gui_Hotkeys_list_hotkeys)
	Local $HotkeyArr_Index = $ListVeiw_Index + 1
	Local $inputBox_neWHotkey = InputBox($_TS_AppTitle, StringFormat("Enter a new hotkey for '%s'. Rember to use {} if you are going to use F-keys", $_SCITE_HotkeyCollectionDisplayNames[$HotkeyArr_Index]), $_SCITE_HotkeyCollectionKeys[$HotkeyArr_Index])
	If @error Then
		MsgBox($MB_ICONWARNING, $_TS_AppTitle, "Hotkey change aborted", 5, $Gui_Main)
	Else
		; Check colission
		For $i = 1 To 5
			If $_SCITE_HotkeyCollectionKeys[$i] == $inputBox_neWHotkey Then
				MsgBox($MB_ICONWARNING, $_TS_AppTitle, StringFormat("The hotkey '%s' is already in use", $inputBox_neWHotkey), 0, $Gui_Main)
				Return
			EndIf
		Next

		; Change the hotkey
		$_SCITE_HotkeyCollectionKeys[$HotkeyArr_Index] = $inputBox_neWHotkey
		;Save the hotkey
		IniWrite($_TS_OptFile, "hotkeys", $_SCITE_HotkeyCollectionIniNames[$HotkeyArr_Index], $inputBox_neWHotkey)
		;Update the hotkey list
		GuiOpt_Main_getHotkeyList()
	EndIf

EndFunc

#EndRegion Hotkey related


