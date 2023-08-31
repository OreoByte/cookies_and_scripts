#!/bin/bash

# Remove empty lines from a file
remove_empty_lines() {
    sed -i '/^\s*$/d' "$1"
}
del_end_whitespace(){
    sed -i 's/[[:blank:]]*$//' "$1"
}
# Auto-indent the code in a file using Vim
auto_indent() {
    vim -e -s -c "set filetype=sh" -c "normal gg=G" -c "wq" "$1"
}

# Main script
if [ "$#" -ne 1 ]; then
cat <<eof
-------------------------------
Fix Copy/Paste URL Code.
-------------------------------
(1) Remove Empty Lines.
(2) Fix File Tab Spacing
(3) Any Vim Supported language

-------------------------------
Usage: $0 <file.cpp>
-------------------------------
eof
exit 1
fi

filename="$1"

# Remove empty lines
remove_empty_lines "$filename"
del_end_whitespace "$filename"

# Auto-indent the code
auto_indent "$filename"
echo "Code cleaned and auto-indented successfully."
echo "File: $filename"
