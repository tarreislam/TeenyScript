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
#NoTrayIcon
Opt("GUIOnEventMode",1)
#include <WindowsConstants.au3>
#include <FileConstants.au3>
#include <File.au3>
#include "TeenyScript\_Dependencies_\AutoitObject.au3"
#include "TeenyScript\_Dependencies_\CustomInit.au3"
#include "TeenyScript\_Array.au3"
#include "TeenyScript\Helpers.au3"
#include "TeenyScript\Resources.au3"
#include "TeenyScript\RE.au3"
#include "TeenyScript\SciTe.au3"
#include "TeenyScript\Parser.au3"
#include "TeenyScript\Hotkeys.au3"
#include "TeenyScript\GuiOpt.au3"


#Region Pre-checks & warnings
If @Compiled Then
	MsgBox($MB_ICONERROR, $_TS_FullAppTitle, StringFormat("It is not recomended to compile %s, since it uses SciTE for console output...", $_TS_AppTitle))
	Exit
EndIf
If Not $_SCITE_HWND Then
	MsgBox($MB_ICONERROR, $_TS_FullAppTitle, StringFormat("Could not find the SciTe window handle. Make sure you are running %s in SciTe.", $_TS_AppTitle))
	Exit
EndIf
If Not FileExists($_AU3_AU2EXE) Then
	MsgBox($MB_ICONWARNING, $_TS_FullAppTitle, StringFormat("The file '%s' was not found, this will prevent you from compiling the script to .exe", $_AU3_AU2EXE))
EndIf
If Not FileExists($_SCITE_TIDY) Then
	MsgBox($MB_ICONWARNING, $_TS_FullAppTitle, StringFormat("The file '%s' was not found, this will prevent you from using SciTE Tidy-up.", $_SCITE_TIDY))
EndIf
#EndRegion Pre-checks

_TS_Init()


While Sleep(0)

WEnd