@Namespace Main

; Main function
$Main = Func()

	Local Const $hGUI = GUICreate("Unnamed gui application", 800, 600)

	GUISetState(@SW_SHOW, $hGUI)

	While GUIGetMsg() <> -3

	WEnd


EndFunc()