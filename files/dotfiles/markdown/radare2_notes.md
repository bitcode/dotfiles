# r2

### build files

#### build mojo files
`mojo build file.mojo`

#### build c files
`gcc file.c`

#### r2
`r2 <binary_file>`: Launch Radare2 and load the target binary file.
`aaaa`: Analyze the entire binary to detect functions, data structures, and other program elements.
`afl`: List all functions found in the binary.
`s <address>`: Seek to a specific address in the binary.
`pdf @ <function_name>`: Print the disassembly of a specific function.
`px @ <address>`: Print the hexdump of data at a specific address.
`V`: Enter visual mode, which provides a more user-friendly interface for analyzing the binary.
`dc`: Run the binary in debug mode.
`dr`: Display the current register state when in debug mode.
`db <address>`: Set a breakpoint at a specific address when in debug mode.








research vocab:



