global _start

extern print, println, STDOUT, STDERR
extern exit
extern atoi
extern strrev

section .data
    BINARY_LEN equ 64
    OCTAL_LEN  equ 22
    HEX_LEN    equ 16

    LF   equ 10
    NULL equ 0

    TRUE  equ 1
    FALSE equ 0

    decimal_msg db "decimal: ", NULL
    hex_msg     db "    hex: ", NULL
    binary_msg  db " binary: ", NULL
    octal_msg   db "  octal: ", NULL

    err_num_msg  db "VALUE is not a number", LF, NULL
    err_argc_msg db "Not enough arguments", LF, NULL

    usage_msg db "Usage: numconv [VALUE]", LF
              db "Converts signed int VALUE into binary, hex, octal", LF, NULL

section .bss
    argc resq 1
    argv resq 1

    value resq 1

    binary resb BINARY_LEN+2
    octal  resb OCTAL_LEN+2
    hex    resb HEX_LEN+2

section .text
_start:
    pop rax
    dec rax
    cmp rax, 1
    jl .err_argc

    mov [argc], rax
    add rsp, 8
    pop qword [argv]

    mov rdi, value
    mov rsi, [argv]
    call atoi

    cmp rax, 1
    jne .err_num

    mov rdi, binary
    mov rsi, [value]
    mov rdx, 2
    call fmt_int64

    mov rdi, octal
    mov rsi, [value]
    mov rdx, 8
    call fmt_int64

    mov rdi, hex
    mov rsi, [value]
    mov rdx, 16
    call fmt_int64

    mov rdi, STDOUT
    mov rsi, decimal_msg
    call print
    mov rsi, [argv]
    call println

    mov rsi, hex_msg
    call print
    mov rsi, hex
    call println

    mov rsi, binary_msg
    call print
    mov rsi, binary
    call println

    mov rsi, octal_msg
    call print
    mov rsi, octal
    call println

    jmp .exit_success

.err_argc:
    mov rdi, STDERR
    mov rsi, err_argc_msg
    call print
    jmp .print_usage

.err_num:
    mov rdi, STDERR
    mov rsi, err_num_msg
    call print
    jmp .print_usage

.print_usage:
    mov rdi, STDERR
    mov rsi, usage_msg
    call print
    jmp .exit_fail

.exit_fail:
    mov rdi, 1
    call exit

.exit_success:
    mov rdi, 0
    call exit

; void fmt_int64(byte *dest, qword num, qword base)
fmt_int64:
    mov rax, rsi  ; num
    mov rcx, 0    ; index
    mov r8, rdx   ; base
    mov r9, FALSE ; is_negative

    cmp rax, 0
    jge .loop

    neg rax
    mov r9, TRUE
.loop:
    cqo
    idiv r8

    cmp r8, 16
    jne .skip_hex

    cmp dl, 10
    jl .skip_hex

    add dl, "a"-10
    jmp .put_char

.skip_hex:
    add dl, "0"

.put_char:
    mov [rdi+rcx], dl

    inc rcx

    cmp rax, 0
    jne .loop

    cmp r9, TRUE
    jne .not_negative

    mov byte [rdi+rcx], "-"
    inc rcx
.not_negative:
    mov byte [rdi+rcx], NULL
    call strrev

    ret
