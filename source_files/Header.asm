.segment "INESHDR"
  .byte "NES",$1A  ; magic signature
  .byte $08        ; size of PRG ROM in 16384 byte units
  .byte $10        ; size of CHR ROM in 8192 byte units
  .byte $90        ; lower mapper nibble, vertical mirroring
  .byte $00        ; upper mapper nibble