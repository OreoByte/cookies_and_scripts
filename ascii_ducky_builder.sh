#!/bin/bash
man_help(){
cat <<eof
-------------------
# Print Help Menu #

./ascii_ducky_builder.sh
./ascii_ducky_builder.sh -h
----------------------------------------------
# Basic ASCII Art Formater For Ducky Scripts #

./ascii_ducky_builder.sh <ascii-art-file.txt> <optional-output-filename>

./ascii_ducky_builder.sh -a Oday_rocks.txt
./ascii_ducky_builder.sh -a Oday_rocks.txt -o Is_Oday_Ok_custom_output.txt
eof
exit 0
}
if [[ -z $1 ]];then
	man_help
fi
ascii=""
output="Is_Oday_Ok.txt"

while [ "$#" -gt 0 ]; do
case "$1" in
	-a) ascii=$2;;
	-o) output=$2;;
	-h) man_help
esac
shift
done
cat <<eof > $output
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

eof

#cat $ascii |grep "\S" |sed -e 's/^/STRING /g' |sed -e 's/$/\nENTER/' >> $output
cat $ascii |grep "\S" |sed -e 's/^/STRING /g' |sed -e 's/$/\nENTER\nHOME/' >> $output
#cat $ascii |grep "\S" |sed -e 's/^/STRING /g' |sed -e 's/$/\nENTER\nHOME\nDELAY 250/' >> $output
#cat $ascii |grep "\S" |sed -e 's/^/ALTSTRING /g' |sed -e 's/$/\nENTER\nHOME\nDELAY 250/' >> $output

