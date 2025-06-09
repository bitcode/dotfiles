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

<div style="page-break-after: always"></div>

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

<div style="page-break-after: always"></div>

# Assembly Language Cheat Sheet: Data Declarations

## Directives for Data Declarations

### Byte (8 bits)
- **Directive:** `db`
- **Description:** Define byte
- **Example:** `myByte db 0x12`

### Word (16 bits)
- **Directive:** `dw`
- **Description:** Define word
- **Example:** `myWord dw 0x1234`

### Double Word (32 bits)
- **Directive:** `dd`
- **Description:** Define double word
- **Example:** `myDword dd 0x12345678`

### Quad Word (64 bits)
- **Directive:** `dq`
- **Description:** Define quad word
- **Example:** `myQword dq 0x123456789ABCDEF0`

### Ten Bytes (80 bits)
- **Directive:** `dt`
- **Description:** Define ten bytes
- **Example:** `myTenBytes dt 0x123456789ABCDEF01234`

<div style="page-break-after: always"></div>

## Reserves Uninitialized Space

### Reserve Byte
- **Directive:** `resb`
- **Description:** Reserve byte(s)
- **Example:** `myBytes resb 4` (Reserves 4 bytes)

### Reserve Word
- **Directive:** `resw`
- **Description:** Reserve word(s)
- **Example:** `myWords resw 2` (Reserves 2 words, or 4 bytes)

### Reserve Double Word
- **Directive:** `resd`
- **Description:** Reserve double word(s)
- **Example:** `myDwords resd 1` (Reserves 1 double word, or 4 bytes)

### Reserve Quad Word
- **Directive:** `resq`
- **Description:** Reserve quad word(s)
- **Example:** `myQwords resq 1` (Reserves 1 quad word, or 8 bytes)

### Reserve Ten Bytes
- **Directive:** `rest`
- **Description:** Reserve ten bytes
- **Example:** `myTenBytes rest 1` (Reserves 10 bytes)

## Data Types and Terminology

### Data Types
- **Byte (8 bits)**: Smallest addressable unit of memory.
  - **Directive:** `db`
  - **Size:** 1 byte
- **Word (16 bits)**: Two bytes.
  - **Directive:** `dw`
  - **Size:** 2 bytes
- **Double Word (32 bits)**: Four bytes.
  - **Directive:** `dd`
  - **Size:** 4 bytes
- **Quad Word (64 bits)**: Eight bytes.
  - **Directive:** `dq`
  - **Size:** 8 bytes
- **Ten Bytes (80 bits)**: Ten bytes.
  - **Directive:** `dt`
  - **Size:** 10 bytes

### Initializing Data
- **Syntax:** `[variable name] [directive] [initial value]`
- **Example:** 
  ```assembly
  byteVar db 0x00
  wordVar dw 0x0000
  doubleWordVar dd 0x00000000
  quadWordVar dq 0x0000000000000000
  tenBytesVar dt 0x00000000000000000000
  
### Uninitialized Data
- **Syntax:** `[variable name] [reserve directive] [number of units]`
- **Example:** 
    ```assembly
    bytesVar resb 4
    wordsVar resw 2
    dwordsVar resd 1
    qwordsVar resq 1
    tenBytesVar rest 1
    ```

### Example Data Section

```assembly
section .data
    ; Initialized data
    byteVar db 0x12                 ; 1 byte
    wordVar dw 0x1234               ; 2 bytes
    doubleWordVar dd 0x12345678     ; 4 bytes
    quadWordVar dq 0x123456789ABCDEF0 ; 8 bytes
    tenBytesVar dt 0x123456789ABCDEF01234 ; 10 bytes

    ; Uninitialized data
    bytesVar resb 4                 ; Reserves  4 bytes
    wordsVar resw 2                 ; Reserves 2 words (4 bytes)
    dwordsVar resd 1                ; Reserves 1 double word (4 bytes)
    qwordsVar resq 1                ; Reserves 1 quad word (8 bytes)
    tenBytesVar rest 1              ; Reserves 10 bytes
    
### Notes
- **Hexadecimal Notation:** Prefixed with `0x` (e.g., `0x00` for zero in hex).
- **Binary Notation:** Prefixed with `0b` (e.g., `0b00000000` for zero in binary).
- **Decimal Notation:** No prefix, used directly (e.g., `0` for zero in decimal).    
