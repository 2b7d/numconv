global strlen
global strrev

section .data
    NULL equ 0

section .text
; qword strlen(byte *s)
strlen:
    mov rax, 0
    jmp .loop_test
.loop:
    inc rax
.loop_test:
    cmp byte [rdi+rax], NULL
    jne .loop
    ret

; void strrev(byte *s)
strrev:
    call strlen
    mov r8, rax  ; len

    cqo
    mov r11, 2
    div r11
    add rax, rdx
    mov r10, rax ; middle = len/2 + len%2

    mov rcx, 0   ; index
    jmp .loop_test
.loop:
    mov al, [rdi+rcx] ; left = s[index]
    lea r9, [rdi+r8-1]
    sub r9, rcx
    mov bl, [r9]      ; right = s[len-1-index]

    mov [rdi+rcx], bl ; left = right
    mov [r9], al      ; right = left

    inc rcx
.loop_test:
    cmp rcx, r10 ; index < middle
    jl .loop

    ret
