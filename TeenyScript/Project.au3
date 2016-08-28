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

Func _TS_Project_getSettings($_TS_ProjectFile, $getFromFilepath_basedir, $bParseMacro = True)
	Local Const $main_name = IniRead($_TS_ProjectFile, "main", "name", "Unkown")
	Local Const $main_ver = IniRead($_TS_ProjectFile, "main", "ver", "Unkown")
	Local Const $main_copyright = IniRead($_TS_ProjectFile, "main", "copyright", "Unkown")
	; parse directory macros
	Local Const $build_arch = IniRead($_TS_ProjectFile, "build", "arch", "32")
	Local $build_dir, $build_icon

	If $bParseMacro Then
		$build_dir = _TS_Project_parseMacrostring(IniRead($_TS_ProjectFile, "build", "dir", "Unkown"),$build_arch, $main_name, $main_ver, $getFromFilepath_basedir)
		$build_icon = _TS_Project_parseMacrostring(IniRead($_TS_ProjectFile, "build", "icon", "Unkown"),$build_arch, $main_name, $main_ver, $getFromFilepath_basedir)
	Else
		$build_dir = IniRead($_TS_ProjectFile, "build", "dir", "Unkown")
		$build_icon = IniRead($_TS_ProjectFile, "build", "icon", "Unkown")
	EndIf

	Local Const $build_type = IniRead($_TS_ProjectFile, "build", "type", "gui")

	Local $oRet = _AutoItObject_Create()
	; Main
	_AutoItObject_AddProperty($oRet, "name", $ELSCOPE_PUBLIC, $main_name)
	_AutoItObject_AddProperty($oRet, "ver", $ELSCOPE_PUBLIC, $main_ver)
	_AutoItObject_AddProperty($oRet, "copyright", $ELSCOPE_PUBLIC, $main_copyright)
	; Build
	_AutoItObject_AddProperty($oRet, "dir", $ELSCOPE_PUBLIC, $build_dir)
	_AutoItObject_AddProperty($oRet, "icon", $ELSCOPE_PUBLIC, $build_icon)
	_AutoItObject_AddProperty($oRet, "arch", $ELSCOPE_PUBLIC, $build_arch)
	_AutoItObject_AddProperty($oRet, "type", $ELSCOPE_PUBLIC, $build_type)
	Return $oRet
EndFunc

Func _TS_Project_setSettings($_TS_ProjectFile, _
	$main_name, _
	$main_ver, _
	$main_copyright, _
	$build_arch, _
	$build_dir, _
	$build_icon, _
	$build_type)


	IniWrite($_TS_ProjectFile, "main", "name", $main_name)
	IniWrite($_TS_ProjectFile, "main", "ver", $main_ver)
	IniWrite($_TS_ProjectFile, "main", "copyright", $main_copyright)
	IniWrite($_TS_ProjectFile, "build", "arch", $build_arch)
	IniWrite($_TS_ProjectFile, "build", "dir", $build_dir)
	IniWrite($_TS_ProjectFile, "build", "icon", $build_icon)
	IniWrite($_TS_ProjectFile, "build", "type", $build_type)
EndFunc


Func _TS_Project_parseMacrostring($sString, $build_arch, $main_name, $main_ver, $project_dir)
	$sString = StringReplace($sString, "%main.name%", $main_name)
	$sString = StringReplace($sString, "%main.ver%", $main_ver)
	$sString = StringReplace($sString, "%build.arch%", $build_arch)
	Return StringReplace($sString, "%project.dir%", $project_dir)
EndFunc