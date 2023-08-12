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
buf:
    .skip 65

    .data
usage:
    .ascii "Usage: numconv [VALUE|OPTION]\n"
    .ascii "Prints VALUE as hex, binary, octal\n"
    .ascii "VALUE:\n"
    .ascii "    signed 64 bit integer\n"
    .ascii "OPTION:\n"
    .ascii "    --help show help\n"
    .asciz "\n"
hex_output:
    .asciz "Hex:    "
binary_output:
    .asciz "Binary: "
octal_output:
    .asciz "Octal:  "
help_str:
    .asciz "--help"
newline:
    .asciz "\n"
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

    movq value, %rdi
    movq $16, %rsi
    movq $buf, %rdx
    call format_int

    movq $hex_output, %rdi
    movq $buf, %rsi
    call print_value

    movq value, %rdi
    movq $2, %rsi
    movq $buf, %rdx
    call format_int

    movq $binary_output, %rdi
    movq $buf, %rsi
    call print_value

    movq value, %rdi
    movq $8, %rsi
    movq $buf, %rdx
    call format_int

    movq $octal_output, %rdi
    movq $buf, %rsi
    call print_value

    jmp exit_success

argc_err:
    movq $argc_err_msg, %rdi
    call print_error
    jmp exit_fail

value_err:
    movq $value_err_msg, %rdi
    call print_error
    jmp exit_fail

exit_fail:
    movq $1, %rdi
    jmp exit
exit_success:
    movq $0, %rdi
exit:
    movq $SYS_exit, %rax
    syscall

# void format_int(rdi value, rsi base, rdx byte *buf)
format_int:
    movq %rdx, %r8
    movq %rdi, %rax
    movq $0, %rcx
1:
    movq $0, %rdx
    divq %rsi

    push %rdx
    incq %rcx

    cmpq $0, %rax
    jne 1b

    mov %r8, %rdx
    mov $0, %r8
1:
    pop %rax

    cmpq $16, %rsi
    jne 2f

    cmpb $10, %al
    jl 2f

    addb $'a'-10, %al
    jmp 3f
2:
    addb $'0', %al
3:
    movb %al, (%rdx, %r8)
    incq %r8

    cmpq %rcx, %r8
    jl 1b

    movb $NULL, (%rdx, %r8)
    ret

# rax atoi(rdi byte *buf, rsi quad *value)
atoi:
    movq $1, %r8 # sign
    cmpb $'-', (%rdi)
    jne 1f

    movq $-1, %r8
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
    imulq %r8, %rax
    imulq $10, %rdx
    addq %rax, %rdx
    jo 3f

    incq %rcx
    jmp 1b
2:
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

# void print_value(rdi byte *prefix, rsi byte *buf)
print_value:
    push %rsi
    push %rdi

    movq $STDOUT, %rdi
    pop %rsi
    call write

    movq $STDOUT, %rdi
    pop %rsi
    call write

    movq $STDOUT, %rdi
    movq $newline, %rsi
    call write
    ret

# void print_error(rdi byte *err)
print_error:
    push %rdi

    movq $STDERR, %rdi
    call print_usage

    movq $STDERR, %rdi
    pop %rsi
    call write

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
