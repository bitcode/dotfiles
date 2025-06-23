# x86_64 Hello World Assembly Program
# This program demonstrates basic x86_64 assembly using Linux system calls

.section .data
    msg: .ascii "Hello, x86_64 World!\n"
    msg_len = . - msg

.section .text
.global _start

_start:
    # Write system call
    # sys_write(fd, buf, count)
    movq    $1, %rax            # sys_write system call number
    movq    $1, %rdi            # file descriptor (stdout)
    movq    $msg, %rsi          # message buffer
    movq    $msg_len, %rdx      # message length
    syscall                     # invoke system call

    # Exit system call
    # sys_exit(status)
    movq    $60, %rax           # sys_exit system call number
    movq    $0, %rdi            # exit status
    syscall                     # invoke system call

# Alternative entry point for debugging
.global main
main:
    # Function prologue
    pushq   %rbp
    movq    %rsp, %rbp
    
    # Call _start functionality
    call    print_message
    
    # Function epilogue
    movq    %rbp, %rsp
    popq    %rbp
    
    # Return 0
    movq    $0, %rax
    ret

print_message:
    # Write system call
    movq    $1, %rax            # sys_write
    movq    $1, %rdi            # stdout
    movq    $msg, %rsi          # message
    movq    $msg_len, %rdx      # length
    syscall
    ret

# Build instructions:
# as --64 -g x86_64_hello_world.s -o x86_64_hello_world.o
# ld x86_64_hello_world.o -o x86_64_hello_world
# ./x86_64_hello_world