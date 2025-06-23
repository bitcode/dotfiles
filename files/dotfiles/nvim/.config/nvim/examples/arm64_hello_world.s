/*
 * arm64_hello_world.s
 * 
 * Description: Simple "Hello, World!" program for ARM AArch64
 * Author: Assembly Development Environment
 * Date: 2025-06-14
 * Architecture: arm64
 */

.section .data
    msg: .ascii "Hello, ARM AArch64 World!\n"
    msg_len = . - msg

.section .text
.global _start

_start:
    // Write system call (sys_write = 64)
    mov     x8, #64             // System call number for sys_write
    mov     x0, #1              // File descriptor (stdout)
    ldr     x1, =msg            // Message buffer
    mov     x2, #msg_len        // Message length
    svc     #0                  // Supervisor call

    // Exit system call (sys_exit = 93)
    mov     x8, #93             // System call number for sys_exit
    mov     x0, #0              // Exit status
    svc     #0                  // Supervisor call

// Function example with proper ARM AArch64 calling convention
.global add_numbers
.type add_numbers, @function
add_numbers:
    // Function prologue
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    
    // Add the two arguments (x0 + x1)
    add     x0, x0, x1
    
    // Function epilogue
    ldp     x29, x30, [sp], #16
    ret
.size add_numbers, . - add_numbers

// Example of conditional execution
.global compare_and_branch
.type compare_and_branch, @function
compare_and_branch:
    // Compare x0 and x1
    cmp     x0, x1
    b.eq    equal_case
    b.lt    less_case
    b.gt    greater_case

equal_case:
    mov     x0, #0              // Return 0 for equal
    ret

less_case:
    mov     x0, #-1             // Return -1 for less than
    ret

greater_case:
    mov     x0, #1              // Return 1 for greater than
    ret
.size compare_and_branch, . - compare_and_branch

// Example of loop implementation
.global count_to_ten
.type count_to_ten, @function
count_to_ten:
    mov     x0, #0              // Counter
    mov     x1, #10             // Limit

count_loop:
    add     x0, x0, #1          // Increment counter
    cmp     x0, x1              // Compare with limit
    b.lt    count_loop          // Branch if less than
    
    ret                         // Return final count
.size count_to_ten, . - count_to_ten

// Example of memory operations
.global memory_example
.type memory_example, @function
memory_example:
    // Function prologue
    stp     x29, x30, [sp, #-32]!
    mov     x29, sp
    
    // Store some values on stack
    mov     x0, #42
    mov     x1, #84
    stp     x0, x1, [sp, #16]
    
    // Load them back
    ldp     x2, x3, [sp, #16]
    
    // Add them
    add     x0, x2, x3
    
    // Function epilogue
    ldp     x29, x30, [sp], #32
    ret
.size memory_example, . - memory_example

// Example of NEON/SIMD operations (if available)
.global vector_add_example
.type vector_add_example, @function
vector_add_example:
    // Load two 128-bit vectors
    ld1     {v0.4s}, [x0]       // Load 4 32-bit integers from x0
    ld1     {v1.4s}, [x1]       // Load 4 32-bit integers from x1
    
    // Add vectors element-wise
    add     v2.4s, v0.4s, v1.4s
    
    // Store result
    st1     {v2.4s}, [x2]       // Store result to x2
    
    ret
.size vector_add_example, . - vector_add_example