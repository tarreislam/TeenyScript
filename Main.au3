Global  $DB_dbH = Null, $DB_pos = 0

;TS_DEBUG=C:\Program Files (x86)\AutoIt3\Include\FileConstants.au3:Unkown:Unkown:Unkown
#Include <FileConstants.au3>
;TS_DEBUG=C:\Program Files (x86)\AutoIt3\Include\MsgBoxConstants.au3:Unkown:Unkown:Unkown
#Include <MsgBoxConstants.au3>
;TS_DEBUG=C:\Program Files (x86)\AutoIt3\Include\WinAPIFiles.au3:Unkown:Unkown:Unkown
#Include <WinAPIFiles.au3>
;TS_DEBUG=C:\Autoit\CalltipMGR\db\db.ts.au3:DB:init:$sDbFile
Global Const $DB_init = _P_X_1_init
Func _P_X_1_init($sDbFile)

	$DB_dbH = FileOpen($sDbFile, $FO_APPEND)


EndFunc
;TS_DEBUG=C:\Autoit\CalltipMGR\db\db.ts.au3:DB:writeLine:$sData
Global Const $DB_writeLine = _P_X_1_writeLine
Func _P_X_1_writeLine($sData)

	FileWriteLine($DB_dbH, $sData)
	$DB_pos += 1


EndFunc
;TS_DEBUG=C:\Autoit\CalltipMGR\db\db.ts.au3:DB:lineExists:$sData
Global Const $DB_lineExists = _P_X_1_lineExists
Func _P_X_1_lineExists($sData)


	For $i = $DB_pos To 0 Step -1
		If FileReadLine($DB_dbH, $i) == $sData Then Return True
	Next

	Return False


EndFunc
Global  $GUI_hGUI, $GUI_iList, $GUI_hBtn_add_udf, $GUI_hBtn_revemo_udf, $GUI_hBtn_install

;TS_DEBUG=C:\Program Files (x86)\AutoIt3\Include\FileConstants.au3:Unkown:Unkown:Unkown
#Include <FileConstants.au3>
;TS_DEBUG=C:\Program Files (x86)\AutoIt3\Include\ButtonConstants.au3:Unkown:Unkown:Unkown
#Include <ButtonConstants.au3>
;TS_DEBUG=C:\Program Files (x86)\AutoIt3\Include\GUIConstantsEx.au3:Unkown:Unkown:Unkown
#Include <GUIConstantsEx.au3>
;TS_DEBUG=C:\Program Files (x86)\AutoIt3\Include\ListViewConstants.au3:Unkown:Unkown:Unkown
#Include <ListViewConstants.au3>
;TS_DEBUG=C:\Program Files (x86)\AutoIt3\Include\WindowsConstants.au3:Unkown:Unkown:Unkown
#Include <WindowsConstants.au3>
;TS_DEBUG=C:\Autoit\CalltipMGR\gui\gui.ts.au3:GUI:init:
Global Const $GUI_init = _P_X_2_init
Func _P_X_2_init()

	$GUI_hGUI = GUICreate("CalltipMGR", 585, 288, 208, 147)
	$GUI_iList = GUICtrlCreateListView("", 8, 8, 570, 246)
	$GUI_hBtn_add_udf = GUICtrlCreateButton("Add UDF", 8, 256, 75, 25)
	$GUI_hBtn_revemo_udf = GUICtrlCreateButton("Remove UDF", 88, 256, 91, 25)
	$GUI_hBtn_install = GUICtrlCreateButton("Install Calltips from list", 456, 256, 123, 25)
	; Display filez

	; Display gui
	GUISetState(@SW_SHOW)
	; Bind events
	GUISetOnEvent($GUI_EVENT_CLOSE, FuncName($GUI_exit))
	GUICtrlSetOnEvent($GUI_hBtn_add_udf, FuncName($GUI_add_Udf))


EndFunc
;TS_DEBUG=C:\Autoit\CalltipMGR\gui\gui.ts.au3:GUI:add_Udf:
Global Const $GUI_add_Udf = _P_X_2_add_Udf
Func _P_X_2_add_Udf()

	Local $sUdfFile = FileOpenDialog("Select UDF", @DesktopDir, "AutoIt (*.au3)" , $FD_MULTISELECT +  $FD_FILEMUSTEXIST, "", $GUI_hGUI)


EndFunc
;TS_DEBUG=C:\Autoit\CalltipMGR\gui\gui.ts.au3:GUI:exit:
Global Const $GUI_exit = _P_X_2_exit
Func _P_X_2_exit()

	Exit


EndFunc

;TS_DEBUG=C:\Autoit\CalltipMGR\Main.ts.au3:Main:Main:
Global Const $Main_Main = _P_X_3_Main()
Func _P_X_3_Main()

	Opt("GUIOnEventMode", 1)

	; (?im)^\h*Func\h*([^(]+)\((.*)\)

MsgBox(0,0,@ScriptDir & "\db.data")
Exit
	$GUI_init()

	$DB_init(@ScriptDir & "\db.data")
	$DB_WriteLine("YOLO")



	While 1

	WEnd



EndFunc

