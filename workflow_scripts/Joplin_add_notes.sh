#!/bin/bash
man_help(){
pygmentize -l csh  <<eof

# Bash script for creating multiple Note Markdown pages with a title file using Joplin's local API #
# list of required linux tools installed
* jq, curl, tee, pygmentize, and echo

# tool options
-t // Each line of the <title_file> will be the whole <title-name> in the new note
-a // Authentication token used to authenticate to Joplins API
-p // Parent ID of the Joplin workbook you want to add new note pages to
-s // Skip over (-p) option and instread
-b // Markdown template file to set the Body of each newly created note. <Optional>

	* (1) query all unique {workbooks} from Joplins API
	* (2) prompt the user to enter the desired {workbook} to add notes to by the {parrent-id}

-d // Delete
-w // Wipe all notes with set from the <title_file> from the WHOLE local Joplin application

# Print Help Menu
	./joplin_add_notes.sh
	./joplin_add_notes.sh -h

# Examples for using the tool give you a choice of <Parent-IDs> to <Add> Or <Delete> notes
	./joplin_add_notes.sh -t subnet_ips.txt
	./joplin_add_notes.sh -t ips.txt -s
	./joplin_add_notes.sh -s '' -t ips.txt

	./joplin_add_notes.sh -t ips.txt -p a776033800694273a98825410480f036
	./joplin_add_notes.sh -p a776033800694273a98825410480f036

	./joplin_add_notes.sh -t header.txt -d
	./joplin_add_notes.sh -t header.txt -w

# {/!\\} NOTE; (Use Script in a directory you are able to write to to leverage all functionality)
% DO-NOT forget to enable to API in Joplin befor running
	* (Tools) > (Options) > (Web Clipper) > (Enable the clipper service)
	* Default port: 41184
% Note;
	* New notes will have to be toggled on before editing can be done
	* (left cick newly created note) > (Top-sh right) > (left click Md icon right of the tablet drawing icon)

% Note; For These options to work properly: -s, -d, and -w
	* A: Put the option on the very end with no input
	* B: Or give the arg a empty string -s ''
eof
exit 0
}
workbook_name(){
folder_name=$(curl -s http://localhost:41184/folders?token=$auth_token|jq|grep "$parent_id" -A2|grep '"title"'|awk '{print $2}' |sed -e 's/"//g')
}
add_notes(){
if [[ $body_temp != '' ]];then
body_data=$(sed -e 's/$/\\n/g' $body_temp|tr -d '\n')
echo "${green}[+] ${reset}Body template file is set with ${green}$body_temp${reset}"
else
body_data=''
echo "${red}[-] ${reset}Body template is not has been set."
fi
echo -e -n "${blue}[*] ${reset}POST curl requests in progress to add new Joplin notes...\n"
while IFS= read line
do
curl -s -d "{\"parent_id\": \"$parent_id\", \"title\": \"$line\", \"body\": \"$body_data\"}" http://127.0.0.1:41184/notes?token=$auth_token 1>/dev/null
done < $title_file
echo -e -n "${green}[+] ${reset}Done! New Joplin note pages created.\n"
exit 0
}
del(){
echo -e -n "${red}[!] ${reset}Delete all Notes from this Joplin Notebook: ${red}$folder_name:$parent_id${reset}\n${blue}[*] ${reset}Are you sure to ${green}Continue${reset}? (y/n): "
read check
if [[ $check != "y" ]];then
	exit 0
fi
echo -e -n "${blue}[*] ${reset}POST curl requests in progress to delete/remove Joplin notes...\n"
for i in $(cat $title_file)
do
curl -s http://127.0.0.1:41184/notes?token=$auth_token|jq ".items[]|select(.parent_id == \"$parent_id\")"|grep "\"$i\"" -B 3|grep '"id"'|sed -e 's/"/ /g'|awk '{print $3}'
sleep 0.005
done > del_ids_list.txt
while IFS= read remove
do
curl -s -X DELETE http://127.0.0.1:41184/notes/$remove?token=$auth_token 1>/dev/null
sleep 0.005
done < del_ids_list.txt
echo -e -n "${green}[+] ${reset}Deleted all selected Joplin notes from ${green}$folder_name:$parent_id${reset}\n"
exit 0
}
wipe(){
echo -e -n "${red}[!] Warning ${reset}this will ${red}WIPE ${reset}ALL Notes with a simular title in ${green}$title_file ${reset}from ${red}ALL ${reset}Joplin Workbooks!"
echo -e -n "\n${blue}[*] ${reset}Are you sure to ${green}Continue${reset}? (y/n): "
read check
if [[ $check != "y" ]];then
	exit 0
fi
echo -e -n "${blue}[*] ${reset}POST curl requests in progress to delete/remove Joplin notes...\n"
for i in $(cat $title_file)
do
curl -s http://127.0.0.1:41184/notes?token=$auth_token|jq|grep "$i" -B2|grep '"id"'|sed -e 's/"/ /g'|awk '{print $3}'
sleep 0.005
done | tee wipe_ids_list.txt 1>/dev/null

for remove in $(cat wipe_ids_list.txt)
do
curl -s -X DELETE http://127.0.0.1:41184/notes/$remove?token=$auth_token 1>/dev/null
sleep 0.005
done
echo -e -n "${green}[+] ${red}Wiped ${reset}all selected Joplin notes.\n"
exit 0
}
skips(){
echo -e -n "${blue}[*] ${reset}Skipping over the ${green}Default ${reset}(Parent-ID). Printing all Joplin Notebook records.\n"
#curl -s http://localhost:41184/notes?token=$auth_token|jq '.[]'|jq 'unique_by(.parent_id)' 2>/dev/null
curl -s http://localhost:41184/folders?token=$auth_token|jq
echo -e -n "${blue}[*] ${reset}Please manually enter the ${green}ID ${reset}to set the notes ${blue}parent_id ${reset}to ${green}continue${reset}: "
read parent_id
workbook_name
echo -e -n "${green}[+] ${reset}Notes Parent ID has been manually set to ${green}$parent_id ${reset}for the ${green}$folder_name ${reset}Workbook. With the (skip) option.\n"
}
red=$(tput setaf 1)
green=$(tput setaf 2)
blue=$(tput setaf 4)
reset=$(tput sgr0)

title_file=""
body_temp=""
auth_token="<CHANGE-ME_Joplin-Web-Clipper-Auth-Token>"
parent_id="<CHANGE-ME_Default-Folder-ID>"
remove_del="no"
wipe_all="no"
skip="no"
if [ -z "$1" ];then
	man_help
fi
while [[ "$#" -gt 0 ]]
do
case "$1" in
	-t) title_file=$2;;
	-a) auth_token=$2;;
	-p) parent_id=$2;;
	-s) skip=$2;;
	-b) body_temp=$2;;
	-d) remove_del=$2;;
	-w) wipe_all=$2;;
	-h) man_help
esac
shift
done
if [[ $title_file == '' ]]; then
	echo -e -n "${red}[-] ${reset}Title file is missing. Please select title file: "
	read title_file
	echo -e -n "${green}[+] ${reset}This Title File is currently in use: ${green}$title_file${reset}\n"
else
	echo -e -n "${green}[+] ${reset}This Title File is currently in use: ${green}$title_file${reset}\n"
fi
if [[ $skip != 'no' ]] && [[ $remove_del != 'no' ]]; then
	workbook_name
	skips
	del
fi
if [[ $remove_del != "no" ]];then
	workbook_name
	del
fi
if [[ $wipe_all != "no" ]];then
	wipe
fi
if [[ $skip != 'no' ]];then
	skips
	add_notes
else
	workbook_name
	echo -e -n "${green}[+] ${reset}Creating new notes for: ${green}$folder_name:$parent_id${reset}\n"
	add_notes
fi
