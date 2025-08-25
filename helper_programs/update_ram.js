/*
    This script generates the `RAM.asm` file from the `RAM.s` file.

    Why is this needed?
    For the Mesen2 emulator to read the labels from `mtpo.dbg`, each label must have a real memory address created using `.res` or similar.
    This solution is intended to be easier to work with while the labels are still sparse.
    Once all of the labels are all filled in then `RAM.s` and this script can be removed.

    Usage:
    node helper_programs/update_ram.js

    When to run:
    Whenever `RAM.s` has been updated.
*/


import fs from 'fs';

/**
 * This function reads a dbg file and prints out any labels that are missing a segment.
 * This is useful for finding labels that will not be loaded from the dbg file into the Mesen2 emulator.
 */
function updateRam(ramFile, outputFile) {

    const ramFileContents = fs.readFileSync(ramFile, 'utf8');
    const lines = ramFileContents.split("\n");

    const output = [];

    output.push(";This file has been generated from `RAM.s` using the script `helper_programs/update_ram.js`")

    let pc = 0;
    let lineNumber = 0;
    let previousAddress = 0;
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        lineNumber = i + 1;

        // Allow use of ";;;" for comments that are not copied to the output file
        if (line.startsWith(";;;")) {
            continue;
        }

        if (line === ".bss") {
            pc = 0x100;
        }
        if (line === '.segment "REGISTERS"') {
            pc = 0x2000;
        }

        const match = lineMatch(line);
        if (!match) {
            output.push(line)
            continue;
        }

        const {label, size, address, comment} = lineMatch(line)

        const nextMatch = lineMatch(lines[i+1])
        let printLabelOnly = false;
        if (nextMatch) {
            const {address: nextAddress} = lineMatch(lines[i+1])
            if (address === nextAddress) {
                printLabelOnly = true;
            }
        }

        if (pc > address) {
            console.error(`Line ${lineNumber}: pc ${pc} <= address ${address}`);
        }
        
        const parts = [
            `${label}:`.padEnd(20, " "),
            `.res ${size}`.padEnd(8, " "),
            `;($${address.toString(16).toUpperCase().padStart(2, "0")})`,
            ` ${comment}`.trimEnd()
        ];
        const offset = address - pc;
        if (offset > 0) {
            const from = (pc).toString(16).toUpperCase().padStart(2, "0")
            const to = (pc+offset-1).toString(16).toUpperCase().padStart(2, "0")
            output.push(`                    .res ${offset}  ;($${from})`)
            pc += offset
        }
        if (!printLabelOnly) {
            output.push(parts.join(""))
            pc += size
        } else {
            output.push(`${(label + ":").padEnd(28, " ")};${comment}`)
        }
        previousAddress = address
    }

    fs.writeFileSync(outputFile, output.join("\n"), 'utf8');
}

function lineMatch(line) {
    const match = line.match(/^\s*(?<label>\w+)\s*:=?\s*(\.res (?<size>\d+)|\$(?<address>[0-9A-F]+))\s*(;(\(\$(?<expected>[0-9A-F]+)\))?\s*(?<comment>.*))?/)
    if (!match) return undefined;
    const label = match.groups["label"]
    const size = match.groups["size"] || 1
    const comment = match.groups["comment"] || ""
    const address = parseInt(match.groups["address"] || match.groups["expected"], 16)
    return {label, size, address, comment};
}

// The dbg file is created by ca65 using the "--dbgfile" option. Run make to generate it.
updateRam("source_files/RAM.s", "source_files/RAM.asm");
