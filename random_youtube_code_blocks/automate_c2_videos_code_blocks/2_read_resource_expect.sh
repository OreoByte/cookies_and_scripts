#!/usr/bin/expect -f
set rfile [lindex $argv 0]

spawn sliver-client
set cmd_file $rfile
set file [open $cmd_file r]
while {[gets $file line] != -1} {
    send "$line\r"
    expect "sliver >"
}
close $file
interact
