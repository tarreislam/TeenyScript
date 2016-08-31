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
;  ---------------------------------------------------------
; |						Regex Variables.					|
; |															|
; |		These should not not contain any matching-groups	|
; |															|
;  ---------------------------------------------------------

Global Const $re_AcceptedVarName = "[a-z0-9_]+" ; The AutoIt "varname_123"
Global Const $re_AcceptedNameComObject = "[a-z0-9._]+" ; The Autoit "com.object"
Global Const $re_AcceptedNamespace = "[a-z\/_]+" ; Accepted namespaces: str/_undrescore
Global Const $re_AcceptedNamespaceAs = "[a-z]+" ;

;  ---------------------------------------------------------
; |					Function parsing related 				|
;  ---------------------------------------------------------
;Global Const $re_func_getNested = "(?mi)^\h*(\$(" & $re_AcceptedVarName & ")\h*=)\h*func\h*\((.+|)\).*\n((?:\h*+(?!(?:(?:\$" & $re_AcceptedVarName & "\h*=\h*|)func\h*\(.+|\)|endfunc(?:[^\n]*))\h*$)[^\n]*\n|(?R)\n)*)\h*endfunc\h*([^\n]*)$"
Global Const $re_func_getNested = "(?mi)^\h*(?:(@Private|@Public|)\h*)(\$(" & $re_AcceptedVarName & ")\h*=)\h*func\h*\((.+|)\).*\n((?:\h*+(?!(?:(?:(@Private|@Public|)\h*)(?:\$" & $re_AcceptedVarName & "\h*=\h*|)func\h*\(.+|\)|endfunc(?:[^\n]*))\h*$)[^\n]*\n|(?R)\n)*)\h*endfunc\h*([^\n]*)$"
Global Const $re_func_closure = "(?mi)(\(|,)\h*\n*Func\((.*)\)\n*([\s\S]+?)\h+(?:!?\(endFunc\))" ; Functions that can be passed as arguments in a function (Not recursive)
Global Const $re_func_properties = "(?i)(?:@|)(private|public|readonly)\h*\$" & $_TS_ObjectName & "\.(" & $re_AcceptedVarName & ")\h*=\h*([^\n]+)"
;Global Const $re_func_interface = "(?i)\$([a-z]+)\h*=\h*Func\(([^)]+)\)"; Interface detection

;  ---------------------------------------------------------
; |							Array 							|
; |					Array related easers					|
;  ---------------------------------------------------------

;	Return [1, 2, [1, 2], 4, 5]
;							$_R_A_N_D_0 = [1, 2, [1, 2], 4, 5]
;							Return $_R_A_N_D_0
Global Const $re_array_ezArray = "(?i)\h*return\h+(\[.*\])"
;	MyFunc([1, 2, 3, 4, 5], $etc)
;							$_R_A_N_D_0 = [1, 2, 3, 4, 5]
;							MyFunc($_R_A_N_D_0, $etc)
Global Const $re_array_ezArrayClosure = "(?mi)(.*[,(])\h*(\[.+\])\h*([,\)].*)"

;	MsgBox(0, 0, $MyFunc()[0]) Or StringSplit("a b c"," ")
;							$_R_A_N_D_0 = $MyFunc()
;							MsgBox(0, 0, $_R_A_N_D_0[0])
; Global Const $re_array_funcAccess = "(?mi)(\$" & $re_AcceptedNameComObject & "|" & $re_AcceptedVarName & ")(\(.*\))\[([0-9]+)\]" (Not now mate!)
;	@Private $this.name = [1, []]
;							$_aName = [1, []]
;							$AOclass.AddProperty("name", $ELSCOPE_PUBLIC, $_aName)
Global Const $re_array_ClassProp = "^(\[.*\])$"

;  ---------------------------------------------------------
; |					Autoit Enhacnhments						|
;  ---------------------------------------------------------

; Allow the user to use For $x in Function() instead of just variable names
; Works with com objects and namespaces Tarre!
Global Const $re_Au3Enhancement_ForIn = "(?i)For\h*(\$" & $re_AcceptedVarName & ")\h*In\h*((?:\$" & $re_AcceptedNameComObject & "|[a-z0-9._\/\$]+)\(.*\))"

;  ---------------------------------------------------------
; |							@Macros 						|
;  ---------------------------------------------------------

Global Const $re_macro_useExtension = "(?i)\@Extends\h+(" & $re_AcceptedNamespace & "\/|)\$(" & $re_AcceptedVarName & ")" ; @Extends path/to/ext/$extension
Global Const $re_macro_useNamespace = "(?i)\@Use\h+(" & $re_AcceptedNamespace & ")\h+(?:In|At|On|As)\h+(" & $re_AcceptedNamespaceAs & ")" ; will detect @Use x/x In At On As x
Global Const $re_macro_getNamespace = "(?i)\@Namespace" ; this will be used to retrive the namespace name as a Macro
Global Const $re_macro_setNamespace = "(?i)^\h*\@Namespace\h+(" & $re_AcceptedNamespace & ")"; WHen assigning namespaces
Global Const $re_macro_getMethodName = "(?i)(\@MethodName)"
Global Const $re_macro_getMethodParams = "(?i)(\@MethodParams)"

;Global Const $re_macro_getInterfaceContent = "(?is)\@interface\h*(" & $re_AcceptedNamespaceAs & ")\n(.+?)@EndInterFace"
;Global Const $re_macro_implementsInterface = "(?i)@Implements\h+([a-z\/_]+)"

;  ---------------------------------------------------------
; |							Heredoc							|
; |					Gluing strings easy						|
;  ---------------------------------------------------------

#cs
	(<<<)
	"text"
	""
	"My var value is {$var}"
	""
	"etc {@Ipadress}"
	(>>>)
#ce
Global Const $re_heredoc_content = "(?s)\(<<<\)\n*([^()]*|.*)\n\h*\(>>>\)"

;	$var = "World"
;
;	"Hello {$var}"		"Hello " & $var & @CRLF "Second line"
;	"Second line"
;
Global Const $re_heredoc_variables = "(?i)\{(\$" & $re_AcceptedNameComObject & "|\@" & $re_AcceptedVarName & ")\}"

;  ---------------------------------------------------------
; |							Lists							|
; |			Some smart text that makes this file longer		|
;  ---------------------------------------------------------

;	$MyObject = {"a", "b", "c", 1, 2, 3, $a, null, False}
Global Const $re_list_create = '(?i)\$(' & $re_AcceptedVarName & ')\h*\=\h*\{([^}]*)\}'; Kolla detta muhammed (\{([^{}]|(?R))*\})  nest listor ska inte vara något problem alls bror. Parsa listan och ersätt träff #2 med en variabel ;D
;	"key": "value", $key => 1234
Global Const $re_list_multiAssign = '(?:[^"' & "'" & '$]*)([^,}]+)\h*(?:\:|\=\h*\>)\h*\n*([^,}\n]+)'

;	$MyObject{"key"} = "value"		_AutoItObject_AddProperty("key", $ELSCOPE_PUBLIC, "value")
;	$MyObject{$key} = 1234			_AutoItObject_AddProperty($key, $ELSCOPE_PUBLIC, "value")
;	$MyObject{$key.list} = 1234
;									$_R_N_D_N_0 = $key.list
;									_AutoItObject_AddProperty($_R_N_D_N_0, $ELSCOPE_PUBLIC, "value")
;
Global Const $re_list_set = '(?i)\$(' & $re_AcceptedVarName & '|' & $re_AcceptedNameComObject & ')\{([^}]+)}\h*\=\h*([^\n]+)'

;	$MyObject{"key"}		Execute($MyObject & ".key")
;	$key.list{"key"}		Execute($key.list & ".key")
Global Const $re_list_get = '(?i)\$(' & $re_AcceptedVarName & '|' & $re_AcceptedNameComObject & ')\{([^}]+)\}'


;	@Private $this.name = {} (Aslo works with content)
;							$AOclass.AddProperty("name", $ELSCOPE_PUBLIC, _AutoitObject_Create())
Global Const $re_list_ClassProp = '^\{(.*)\}$'


;  ---------------------------------------------------------
; |							TS Misc							|
;  ---------------------------------------------------------

Global Const $re_TS_parameter = "(?i)\h*(class|extension|construct)\h*(?:[,]+|)\h*(.*)"
Global Const $re_TS_fileExt = '(?i)\\.*(\.ts\.au3)$' ; Will only detect when file ends with .ts.au3
Global Const $re_TS_Include = '(?i)\#include\h*(?:\<|\")([a-z0-9_ \\\/]+((?:[\*]{0,2}|)\.ts|\.au3))\h*(?:\>|\")'; #include detection
Global Const $re_TS_Debug = '(?si)#DEBUG(.+)'; This will copy raw after #DEBUG (Will not be included when BUILDING au3 or .exe)

;  ---------------------------------------------------------
; |						Scite RE							|
;  ---------------------------------------------------------
Global Const $re_SciTE_TSpath = "( - SciTE.*)"


;  ---------------------------------------------------------
; |						Parsing error RE					|
;  ---------------------------------------------------------

; ~ List keys can only contain a-z, 0-9, _, $variable, $com.object
Global Const $re_parseErr_listKey = "(?i)(?:^[0-9a-z_]+$|\$" & $re_AcceptedNameComObject & ")"

