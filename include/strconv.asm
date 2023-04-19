global atoi
extern strlen

section .data
    NULL equ 0

    MAX_LEN equ 19

    TRUE  equ 1
    FALSE equ 0

section .text
; qword atoi(qword *dest, byte *str)
atoi:
    push rdi
    mov rdi, rsi
    call strlen
    pop rdi

    cmp rax, MAX_LEN
    jg .error

    mov r8, rax        ; str_len
    mov rax, TRUE      ; is_success
    mov qword [rdi], 0 ; result
    mov rcx, 0         ; index
    mov r9, FALSE      ; has_minus_sign

    cmp byte [rsi], "-"
    jne .loop_test

    mov r9, TRUE
    inc rcx
    jmp .loop_test
.loop:
    xor rdx, rdx
    mov dl, [rsi+rcx]

    cmp dl, "0"
    jl .error
    cmp dl, "9"
    jg .error

    sub dl, "0"

    mov r10, r8
    dec r10
    sub r10, rcx
    jmp .loop_2_test
.loop_2:
    imul rdx, rdx, 10
    dec r10
.loop_2_test:
    cmp r10, 0
    jg .loop_2

    add [rdi], rdx
    inc rcx
.loop_test:
    cmp byte [rsi+rcx], NULL
    jne .loop

    cmp r9, TRUE
    jne .not_negative

    neg qword [rdi]
.not_negative:
    jmp .exit
.error:
    mov rax, FALSE
.exit:
    ret
