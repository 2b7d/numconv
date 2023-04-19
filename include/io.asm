global print, println
global STDIN, STDOUT, STDERR
extern strlen

section .data
    SYS_WRITE equ 1

    STDIN  equ 0
    STDOUT equ 1
    STDERR equ 2

    LF   equ 10
    NULL equ 0

    new_line db LF, NULL

section .text
; void print(qword fd, byte *s)
print:
    push rdi
    mov rdi, rsi
    call strlen
    pop rdi

    mov rdx, rax
    mov rax, SYS_WRITE
    syscall

    ret

; void println(qword fd, byte *s)
println:
    call print

    mov rsi, new_line
    call print

    ret
