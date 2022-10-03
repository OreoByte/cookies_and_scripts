#!/usr/bin/pwsh
param(
	[string]$o="custom_ducky_ascii.txt",
	[string]$a=""
)
function helper {
$man_help=@"
# Powershell ASCII formater for ducky scripts to replace demo_windows.txt on the flipper
Tested on
1. Linux pwsh (powershell-core)
2. Windows 10 (powershell.exe)

# Print Help
.\ps1_win_ascii_duck.ps1

# basic use
.\ps1_win_ascii_duck.ps1 -a <ascii-file> -o <output-filename>

.\ps1_win_ascii_duck.ps1 -a Oday.txt -o Oday_demo.txt
.\ps1_win_ascii_duck.ps1 -a Oday.txt
"@
$man_help
break
}

if($a -eq ""){
	helper
} else {
$start_notepad=@"
REM Open windows notepad as in a Maxed Window for larger ASCII Art
DELAY 1000
GUI r
DELAY 500
STRING cmd /c "start /max notepad"
DELAY 1000
ENTER
DELAY 750

ALTCHAR 7
ALTSTRING 0Day Was Here!
ENTER
ENTER

"@
	$start_notepad > $o
	$strlines=(get-content $a)|? {$_.trim() -ne ""}|foreach{"STRING " + $_}
	$strlines|foreach {$_ + "`r`nENTER`r`nHOME"} >> $o
}
