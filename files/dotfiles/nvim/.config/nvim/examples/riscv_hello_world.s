# RISC-V Hello World Assembly Program
# This program demonstrates basic RISC-V assembly using Linux system calls

.section .data
    msg: .ascii "Hello, RISC-V World!\n"
    msg_len = . - msg

.section .text
.global _start

_start:
    # Write system call
    # sys_write(fd, buf, count)
    li      a7, 64              # sys_write system call number
    li      a0, 1               # file descriptor (stdout)
    la      a1, msg             # message buffer
    li      a2, msg_len         # message length
    ecall                       # environment call (system call)

    # Exit system call
    # sys_exit(status)
    li      a7, 93              # sys_exit system call number
    li      a0, 0               # exit status
    ecall                       # environment call (system call)

# Alternative entry point for debugging
.global main
main:
    # Function prologue
    addi    sp, sp, -16         # allocate stack frame
    sd      ra, 8(sp)           # save return address
    sd      s0, 0(sp)           # save frame pointer
    addi    s0, sp, 16          # set frame pointer
    
    # Call print function
    call    print_message
    
    # Function epilogue
    ld      ra, 8(sp)           # restore return address
    ld      s0, 0(sp)           # restore frame pointer
    addi    sp, sp, 16          # deallocate stack frame
    
    # Return 0
    li      a0, 0
    ret                         # return

print_message:
    # Function prologue
    addi    sp, sp, -16         # allocate stack frame
    sd      ra, 8(sp)           # save return address
    sd      s0, 0(sp)           # save frame pointer
    addi    s0, sp, 16          # set frame pointer
    
    # Write system call
    li      a7, 64              # sys_write
    li      a0, 1               # stdout
    la      a1, msg             # message
    li      a2, msg_len         # length
    ecall                       # system call
    
    # Function epilogue
    ld      ra, 8(sp)           # restore return address
    ld      s0, 0(sp)           # restore frame pointer
    addi    sp, sp, 16          # deallocate stack frame
    ret                         # return

# Example of RISC-V specific instructions and features
.global demo_riscv_features
demo_riscv_features:
    # Compressed instructions (if RVC extension available)
    c.li    t0, 42              # compressed load immediate
    c.mv    t1, t0              # compressed move
    
    # Multiply extension (if RVM extension available)
    mul     t2, t0, t1          # multiply
    div     t3, t2, t0          # divide
    
    # Atomic operations (if RVA extension available)
    lr.w    t4, (sp)            # load reserved
    sc.w    t5, t0, (sp)        # store conditional
    
    # Floating point (if RVF/RVD extensions available)
    fmv.w.x f0, t0              # move from integer to float
    fcvt.s.w f1, t1             # convert int to float
    fadd.s  f2, f0, f1          # floating point add
    
    ret

# Build instructions:
# riscv64-linux-gnu-as -march=rv64gc -mabi=lp64d riscv_hello_world.s -o riscv_hello_world.o
# riscv64-linux-gnu-ld riscv_hello_world.o -o riscv_hello_world
# qemu-riscv64 ./riscv_hello_world (if cross-compiled)