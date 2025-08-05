# mike-tysons-punch-out-disassembly
Reverse engineering effort of the NES game Mike Tyson's Punch-Out!!

# Folder Structure
```
.
├── documentation      # Various documentation for the disassembly
├── helper_programs    # Small helper programs
├── original_files     # Binary images of the memory banks from the original game
├── output_files       # Assembled binaries placed here after running the Makefile
└── source_files       # The actual disassembled game source code
```

# Getting Started

Prerequisites:
- [cc65](https://cc65.github.io/) - C compiler and assembler for 6502 family CPUs
- make

Windows 11 tips:
- Use WSL2
- `sudo apt-get install cc65`

MacOS tips:
- `brew install cc65`


# Build

```sh
# Build mtpo.nes
make

# Check that the compiled sources are identical to the original binaries
make check

# Delete the output_files folder
make clean
```
