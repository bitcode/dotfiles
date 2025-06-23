@ ARM32 Hello World Assembly Program
@ This program demonstrates basic ARM32 assembly using Linux system calls

.section .data
    msg: .ascii "Hello, ARM32 World!\n"
    msg_len = . - msg

.section .text
.global _start

_start:
    @ Write system call
    @ sys_write(fd, buf, count)
    mov     r7, #4              @ sys_write system call number
    mov     r0, #1              @ file descriptor (stdout)
    ldr     r1, =msg            @ message buffer
    mov     r2, #msg_len        @ message length
    swi     #0                  @ software interrupt (system call)

    @ Exit system call
    @ sys_exit(status)
    mov     r7, #1              @ sys_exit system call number
    mov     r0, #0              @ exit status
    swi     #0                  @ software interrupt (system call)

@ Alternative entry point for debugging
.global main
main:
    @ Function prologue
    push    {fp, lr}            @ save frame pointer and link register
    mov     fp, sp              @ set frame pointer
    
    @ Call print function
    bl      print_message
    
    @ Function epilogue
    mov     sp, fp              @ restore stack pointer
    pop     {fp, lr}            @ restore frame pointer and link register
    
    @ Return 0
    mov     r0, #0
    bx      lr                  @ return

print_message:
    @ Function prologue
    push    {r0-r3, lr}         @ save registers and link register
    
    @ Write system call
    mov     r7, #4              @ sys_write
    mov     r0, #1              @ stdout
    ldr     r1, =msg            @ message
    mov     r2, #msg_len        @ length
    swi     #0                  @ system call
    
    @ Function epilogue
    pop     {r0-r3, lr}         @ restore registers and link register
    bx      lr                  @ return

@ Build instructions:
@ arm-linux-gnueabihf-as -march=armv7-a -mfpu=neon arm32_hello_world.s -o arm32_hello_world.o
@ arm-linux-gnueabihf-ld arm32_hello_world.o -o arm32_hello_world
@ qemu-arm ./arm32_hello_world (if cross-compiled)