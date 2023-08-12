    .global _start

    .equ STDOUT, 1
    .equ STDERR, 2

    .equ SYS_write, 1
    .equ SYS_exit, 60

    .equ NULL,  0
    .equ TRUE,  1
    .equ FALSE, 0

    .equ INT64_MAXLEN, 19

    .bss
value:
    .quad 0

    .data
usage:
    .ascii "Usage: numconv [VALUE|OPTION]\n"
    .ascii "Prints VALUE as signed, unsigned, hex, binary, octal\n"
    .ascii "VALUE:\n"
    .ascii "    signed 64 bit integer\n"
    .ascii "OPTION:\n"
    .ascii "    --help show help\n"
    .asciz "\n"
help_str:
    .asciz "--help"
argc_err_msg:
    .asciz "Error: Not enough arguments\n"
value_err_msg:
    .asciz "Error: VALUE is invalid\n"

    .text
_start:
    pop %rax
    decq %rax
    cmpq $0, %rax
    je argc_err

    addq $8, %rsp
    pop %rbx

    movq %rbx, %rdi
    movq $help_str, %rsi
    call strcmp
    cmpq $TRUE, %rax
    jne 1f

    movq $STDOUT, %rdi
    call print_usage
    jmp exit_success
1:
    movq %rbx, %rdi
    movq $value, %rsi
    call atoi
    cmpq $0, %rax
    jl value_err

    jmp exit_success

argc_err:
    movq $STDERR, %rdi
    call print_usage
    movq $STDERR, %rdi
    movq $argc_err_msg, %rsi
    call write
    jmp exit_fail

value_err:
    movq $STDERR, %rdi
    call print_usage
    movq $STDERR, %rdi
    movq $value_err_msg, %rsi
    call write
    jmp exit_fail

exit_fail:
    movq $1, %rdi
    jmp exit

exit_success:
    movq $0, %rdi

exit:
    movq $SYS_exit, %rax
    syscall

# no need to preserve: rax, rdi, rsi, rdx, rcx, r8, r9, r10, r11

# rax atoi(rdi byte *buf, rsi quad *value)
atoi:
    movq $FALSE, %r8 # is negative
    cmpb $'-', (%rdi)
    jne 1f

    movq $TRUE, %r8
    addq $1, %rdi
1:
    call strlen
    cmpq $0, %rax
    je 3f
    cmpq $INT64_MAXLEN, %rax
    jg 3f

    movq (%rsi), %rdx
    movq $0, %rdx
    movq $0, %rcx
1:
    movb (%rdi, %rcx), %al
    cmpb $NULL, %al
    je 2f

    cmpb $'0', %al
    jl 3f
    cmpb $'9', %al
    jg 3f

    subb $'0', %al
    movsbq %al, %rax
    imul $10, %rdx
    addq %rax, %rdx
    jo 3f

    incq %rcx
    jmp 1b
2:
    cmpq $TRUE, %r8
    jne 1f

    neg %rdx
1:
    mov %rdx, (%rsi)
    movq $0, %rax
    ret
3: # error
    movq $-1, %rax
    ret

# rax strcmp(rdi *byte s1, rsi byte *s2)
strcmp:
    movq $FALSE, %rax
    movq $0, %rcx
1:
    movb (%rdi, %rcx), %dl
    cmpb %dl, (%rsi, %rcx)
    jne 2f

    incq %rcx
    cmpb $NULL, %dl
    jne 1b

    movq $TRUE, %rax
2:
    ret

# rax strlen(rdi byte *s)
strlen:
    movq $0, %rax
    jmp 2f
1:
    incq %rax
2:
    cmpb $NULL, (%rdi, %rax)
    jne 1b
    ret

# void print_usage(rdi fd)
print_usage:
    movq $usage, %rsi
    call write
    ret

# void write(rdi fd, rsi byte *buf)
write:
    push %rdi

    movq %rsi, %rdi
    call strlen

    pop %rdi
    mov %rax, %rdx
    movq $SYS_write, %rax
    syscall
    ret
