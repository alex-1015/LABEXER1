section .data
clr         db 27, "[2J", 27, "[H"
clr_len     equ $ - clr

menu        db "----------------------------------", 10
            db "MENU", 10
            db "[A]dd", 10
            db "[S]ubtract", 10
            db "[M]ultiply", 10
            db "[D]ivide", 10
            db "-----------------------------------", 10
            db "Enter your choice: "
menu_len    equ $ - menu

p_first     db 10, "Enter first number: "
p_first_len equ $ - p_first
p_second    db "Enter second number: "
p_second_len equ $ - p_second

m_sum       db "The sum is "
m_sum_len   equ $ - m_sum
m_diff      db "The difference is "
m_diff_len  equ $ - m_diff
m_prod      db "The product is "
m_prod_len  equ $ - m_prod
m_quot      db "The quotient is "
m_quot_len  equ $ - m_quot
m_rem       db "The remainder is "
m_rem_len   equ $ - m_rem

m_invalid   db 10, "Invalid choice.", 10
m_invalid_len equ $ - m_invalid

p_again     db 10, "Do you want to try again (Y/N) "
p_again_len equ $ - p_again

nl          db 10

section .bss
buf         resb 10
outbuf      resb 16
num1        resd 1
num2        resd 1
result      resd 1
rem         resd 1
dig         resb 1

section .text
global _start

_start:
main_loop:
    mov ecx, clr
    mov edx, clr_len
    call print
    mov ecx, menu
    mov edx, menu_len
    call print

    mov eax, 3
    mov ebx, 0
    mov ecx, buf
    mov edx, 10
    int 0x80
    mov al, [buf]
    and al, 0xDF

    cmp al, 'A'
    je  get_numbers
    cmp al, 'S'
    je  get_numbers
    cmp al, 'M'
    je  get_numbers
    cmp al, 'D'
    je  get_numbers

    mov ecx, m_invalid
    mov edx, m_invalid_len
    call print
    jmp ask_again

get_numbers:
    mov bl, [buf]
    and bl, 0xDF
    mov [dig], bl

    mov ecx, p_first
    mov edx, p_first_len
    call print
    call read_num
    mov [num1], eax

    mov ecx, p_second
    mov edx, p_second_len
    call print
    call read_num
    mov [num2], eax

    mov al, [dig]
    cmp al, 'A'
    je  do_add
    cmp al, 'S'
    je  do_sub
    cmp al, 'M'
    je  do_mul
    jmp do_div

do_add:
    mov eax, [num1]
    add eax, [num2]
    mov [result], eax
    mov ecx, m_sum
    mov edx, m_sum_len
    call print
    mov eax, [result]
    call print_num
    mov ecx, nl
    mov edx, 1
    call print
    jmp ask_again

do_sub:
    mov eax, [num1]
    sub eax, [num2]
    mov [result], eax
    mov ecx, m_diff
    mov edx, m_diff_len
    call print
    mov eax, [result]
    call print_num
    mov ecx, nl
    mov edx, 1
    call print
    jmp ask_again

do_mul:
    mov eax, [num1]
    imul eax, [num2]
    mov [result], eax
    mov ecx, m_prod
    mov edx, m_prod_len
    call print
    mov eax, [result]
    call print_num
    mov ecx, nl
    mov edx, 1
    call print
    jmp ask_again

do_div:
    mov eax, [num1]
    xor edx, edx
    div dword [num2]
    mov [result], eax
    mov [rem], edx
    mov ecx, m_quot
    mov edx, m_quot_len
    call print
    mov eax, [result]
    call print_num
    mov ecx, nl
    mov edx, 1
    call print
    cmp dword [rem], 0
    je  ask_again
    mov ecx, m_rem
    mov edx, m_rem_len
    call print
    mov eax, [rem]
    call print_num
    mov ecx, nl
    mov edx, 1
    call print

ask_again:
    mov ecx, p_again
    mov edx, p_again_len
    call print
    mov eax, 3
    mov ebx, 0
    mov ecx, buf
    mov edx, 10
    int 0x80
    mov al, [buf]
    and al, 0xDF
    cmp al, 'Y'
    je  main_loop
    cmp al, 'N'
    je  exit
    jmp ask_again

exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80

print:
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

read_num:
    mov eax, 3
    mov ebx, 0
    mov ecx, buf
    mov edx, 10
    int 0x80
    movzx eax, byte [buf]
    sub eax, '0'
    movzx ebx, byte [buf + 1]
    sub ebx, '0'
    cmp ebx, 9
    ja  .done
    imul eax, eax, 10
    add eax, ebx
.done:
    ret

print_num:
    xor esi, esi
    cmp eax, 0
    jge .convert
    neg eax
    mov esi, 1
.convert:
    mov edi, outbuf + 16
    mov ebx, 10
.loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    cmp eax, 0
    jne .loop
    cmp esi, 0
    je  .show
    dec edi
    mov byte [edi], '-'
.show:
    mov ecx, edi
    mov edx, outbuf + 16
    sub edx, edi
    call print
    ret