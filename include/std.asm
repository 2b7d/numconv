global exit

section .data
    SYS_EXIT equ 60

section .text
; void exit(qword code)
exit:
    mov rax, SYS_EXIT
    syscall
