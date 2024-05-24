# Data Storage Sizes

The x86-64 architecture supports a specific set of data storage size elements, all based on powers of two. The supported storage sizes are as follows:

| Storage Size       | Size (bits) | Size (bytes) |
|--------------------|-------------|--------------|
| Byte               | 8-bits      | 1 byte       |
| Word               | 16-bits     | 2 bytes      |
| Double-word        | 32-bits     | 4 bytes      |
| Quadword           | 64-bits     | 8 bytes      |
| Double quadword    | 128-bits    | 16 bytes     |

Lists or arrays (sets of memory) can be reserved in any of these types. These storage sizes have a direct correlation to variable declarations in high-level languages (e.g., C, C++, Java, etc.).

For example, C/C++ declarations are mapped as follows:

| C/C++ Declaration  | Storage Size (bits) | Size (bytes) |
|--------------------|---------------------|--------------|
| char               | Byte                | 8-bits       | 1 byte  |
| short              | Word                | 16-bits      | 2 bytes |
| int                | Double-word         | 32-bits      | 4 bytes |
| unsigned int       | Double-word         | 32-bits      | 4 bytes |
| long               | Quadword            | 64-bits      | 8 bytes |
| long long          | Quadword            | 64-bits      | 8 bytes |
| char *             | Quadword            | 64-bits      | 8 bytes |
| int *              | Quadword            | 64-bits      | 8 bytes |
| float              | Double-word         | 32-bits      | 4 bytes |
| double             | Quadword            | 64-bits      | 8 bytes |

The asterisk indicates an address variable. For example, `int *` means the address of an integer. Other high-level languages typically have similar mappings.

\pagebreak

# CPU Registers

A CPU register, or just register, is a temporary storage or working location built into the CPU itself (separate from memory). Computations are typically performed by the CPU using registers.

## General Purpose Registers (GPRs)

There are sixteen, 64-bit General Purpose Registers (GPRs). The GPRs are described in the following table. A GPR register can be accessed with all 64-bits or some portion or subset accessed.

| 64-bit register | Lowest 32-bits | Lowest 16-bits | Lowest 8-bits |
|-----------------|----------------|----------------|---------------|
| rax             | eax            | ax             | al            |
| rbx             | ebx            | bx             | bl            |
| rcx             | ecx            | cx             | cl            |
| rdx             | edx            | dx             | dl            |
| rsi             | esi            | si             | sil           |
| rdi             | edi            | di             | dil           |
| rbp             | ebp            | bp             | bpl           |
| rsp             | esp            | sp             | spl           |
| r8              | r8d            | r8w            | r8b           |
| r9              | r9d            | r9w            | r9b           |
| r10             | r10d           | r10w           | r10b          |
| r11             | r11d           | r11w           | r11b          |
| r12             | r12d           | r12w           | r12b          |
| r13             | r13d           | r13w           | r13b          |
| r14             | r14d           | r14w           | r14b          |
| r15             | r15d           | r15w           | r15b          |

\pagebreak

## Flag Register (rFlags)

The flag register, rFlags, is used for status and CPU control information. The rFlag register is updated by the CPU after each instruction and not directly accessible by programs. This register stores status information about the instruction that was just executed. Of the 64-bits in the rFlag register, many are reserved for future use. The following table shows some of the status bits in the flag register.

| Name     | Symbol | Bit | Use                                                                 |
|----------|--------|-----|---------------------------------------------------------------------|
| Carry    | CF     | 0   | Used to indicate if the previous operation resulted in a carry.     |
| Parity   | PF     | 2   | Used to indicate if the last byte has an even number of 1's (i.e., even parity). |
| Adjust   | AF     | 4   | Used to support Binary Coded Decimal operations.                    |
| Zero     | ZF     | 6   | Used to indicate if the previous operation resulted in a zero result. |
| Sign     | SF     | 7   | Used to indicate if the result of the previous operation resulted in a 1 in the most significant bit (indicating negative in the context of signed data). |
| Direction| DF     | 10  | Used to specify the direction (increment or decrement) for some string operations. |
| Overflow | OF     | 11  | Used to indicate if the previous operation resulted in an overflow. |

# Intel x64 CPU Register Breakdown (Example: RAX)

| Register Part | Size (bits) | Description                         |
|---------------|-------------|-------------------------------------|
| RAX           | 64          | Full 64-bit register                |
| EAX           | 32          | Lower 32 bits of RAX                |
| AX            | 16          | Lower 16 bits of EAX                |
| AH            | 8           | Higher 8 bits of AX                 |
| AL            | 8           | Lower 8 bits of AX                  |

\pagebreak


