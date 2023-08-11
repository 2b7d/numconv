.global _start

.equ SYS_write, 1
.equ SYS_exit, 60
.equ STDOUT, 1

.data
msg: .ascii "hello, world\n"
msg_len = . - msg

.text
_start:
    movq $SYS_write, %rax
    movq $STDOUT, %rdi
    movq $msg, %rsi
    movq $msg_len, %rdx
    syscall

    movq $SYS_exit, %rax
    movq $0, %rdi
    syscall
