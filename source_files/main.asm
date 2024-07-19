
.segment "INESHDR"
  .byte "NES",$1A  ; magic signature
  .byte $08        ; size of PRG ROM in 16384 byte units
  .byte $10        ; size of CHR ROM in 8192 byte units
  .byte $90        ; lower mapper nibble, vertical mirroring
  .byte $00        ; upper mapper nibble

.segment "CHR_Bank000"
.incbin "CHR_Bank000.bin"

.segment "CHR_Bank001"
.incbin "CHR_Bank001.bin"

.segment "CHR_Bank002"
.incbin "CHR_Bank002.bin"

.segment "CHR_Bank003"
.incbin "CHR_Bank003.bin"

.segment "CHR_Bank004"
.incbin "CHR_Bank004.bin"

.segment "CHR_Bank005"
.incbin "CHR_Bank005.bin"

.segment "CHR_Bank006"
.incbin "CHR_Bank006.bin"

.segment "CHR_Bank007"
.incbin "CHR_Bank007.bin"

.segment "CHR_Bank008"
.incbin "CHR_Bank008.bin"

.segment "CHR_Bank009"
.incbin "CHR_Bank009.bin"

.segment "CHR_Bank00A"
.incbin "CHR_Bank00A.bin"

.segment "CHR_Bank00B"
.incbin "CHR_Bank00B.bin"

.segment "CHR_Bank00C"
.incbin "CHR_Bank00C.bin"

.segment "CHR_Bank00D"
.incbin "CHR_Bank00D.bin"

.segment "CHR_Bank00E"
.incbin "CHR_Bank00E.bin"

.segment "CHR_Bank00F"
.incbin "CHR_Bank00F.bin"

.segment "CHR_Bank010"
.incbin "CHR_Bank010.bin"

.segment "CHR_Bank011"
.incbin "CHR_Bank011.bin"

.segment "CHR_Bank012"
.incbin "CHR_Bank012.bin"

.segment "CHR_Bank013"
.incbin "CHR_Bank013.bin"

.segment "CHR_Bank014"
.incbin "CHR_Bank014.bin"

.segment "CHR_Bank015"
.incbin "CHR_Bank015.bin"

.segment "CHR_Bank016"
.incbin "CHR_Bank016.bin"

.segment "CHR_Bank017"
.incbin "CHR_Bank017.bin"

.segment "CHR_Bank018"
.incbin "CHR_Bank018.bin"

.segment "CHR_Bank019"
.incbin "CHR_Bank019.bin"

.segment "CHR_Bank01A"
.incbin "CHR_Bank01A.bin"

.segment "CHR_Bank01B"
.incbin "CHR_Bank01B.bin"

.segment "CHR_Bank01C"
.incbin "CHR_Bank01C.bin"

.segment "CHR_Bank01D"
.incbin "CHR_Bank01D.bin"

.segment "CHR_Bank01E"
.incbin "CHR_Bank01E.bin"

.segment "CHR_Bank01F"
.incbin "CHR_Bank01F.bin"
