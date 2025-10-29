; --- Notes ---
; Messages use lots of double quotes, and there are proper left and right double quotes tiles.
; Standard ASCII doesn't have left and right double quotes, so we'll use < and > for those.
; .byte "<HELP! DOC!!>" ; "HELP! DOC!!" (example message)

; Format used in this file:
;       .charmap ascii, sprite
; Example:
;      .charmap $41, $0B ; "A" -> tile index $0B in CHR ROM

; Reset all character mappings to $FF (space)
.repeat 256, i
    .charmap i, $FF
.endrep

; Digits
.charmap $30, $01   ; 0
.charmap $31, $02   ; 1
.charmap $32, $03   ; 2
.charmap $33, $04   ; 3
.charmap $34, $05   ; 4
.charmap $35, $06   ; 5
.charmap $36, $07   ; 6
.charmap $37, $08   ; 7
.charmap $38, $09   ; 8
.charmap $39, $0A   ; 9

; Uppercase letters
.charmap $41, $0B   ; A
.charmap $42, $0C   ; B
.charmap $43, $0D   ; C
.charmap $44, $0E   ; D
.charmap $45, $0F   ; E
.charmap $46, $10   ; F
.charmap $47, $11   ; G
.charmap $48, $12   ; H
.charmap $49, $13   ; I
.charmap $4A, $14   ; J
.charmap $4B, $15   ; K
.charmap $4C, $16   ; L
.charmap $4D, $17   ; M
.charmap $4E, $18   ; N
.charmap $4F, $19   ; O
.charmap $50, $1A   ; P
.charmap $51, $1B   ; Q
.charmap $52, $1C   ; R
.charmap $53, $1D   ; S
.charmap $54, $1E   ; T
.charmap $55, $1F   ; U
.charmap $56, $20   ; V
.charmap $57, $21   ; W
.charmap $58, $22   ; X
.charmap $59, $23   ; Y
.charmap $5A, $24   ; Z

; Puncuation and symbols
.charmap $2E, $25   ; . (period)
.charmap $27, $26   ; ' (apostrophe)
.charmap $21, $27   ; ! (exclamation mark)
.charmap $2D, $28   ; - (hyphen-minus)
.charmap $3C, $29   ; < (less-than) mapped to left double quote
.charmap $3E, $2A   ; > (greater-than) mapped to right double quote
.charmap $2C, $2B   ; , (comma)
.charmap $3A, $2C   ; : (colon)
.charmap $23, $2D   ; # (number sign)
.charmap $3F, $30   ; ? (question mark)
.charmap $20, $FF   ; " " (Space)

; Unused characters
; .charmap $22, $FF   ; " (double quote)
; .charmap $24, $FF   ; $ (dollar sign)
; .charmap $25, $FF   ; % (percent sign)
; .charmap $26, $FF   ; & (ampersand)
; .charmap $28, $FF   ; ( (left parenthesis)
; .charmap $29, $FF   ; ) (right parenthesis)
; .charmap $2A, $FF   ; * (asterisk)
; .charmap $2B, $FF   ; + (plus sign)
; .charmap $2F, $FF   ; / (slash)
; .charmap $3B, $FF   ; ; (semicolon)
; .charmap $3D, $FF   ; = (equals)
; .charmap $40, $FF   ; @ (at sign)
; .charmap $5B, $FF   ; [ (left bracket)
; .charmap $5C, $FF   ; \ (backslash)
; .charmap $5D, $FF   ; ] (right bracket)
; .charmap $5E, $FF   ; ^ (caret)
; .charmap $5F, $FF   ; _ (underscore)
; .charmap $60, $FF   ; ` (backtick)
; .charmap $7B, $FF   ; { (left curly brace)
; .charmap $7C, $FF   ; | (vertical bar)
; .charmap $7D, $FF   ; } (right curly brace)
; .charmap $7E, $FF   ; ~ (tilde)

; Lowercase mapped to uppercase
.charmap $61, $0B   ; a
.charmap $62, $0C   ; b
.charmap $63, $0D   ; c
.charmap $64, $0E   ; d
.charmap $65, $0F   ; e
.charmap $66, $10   ; f
.charmap $67, $11   ; g
.charmap $68, $12   ; h
.charmap $69, $13   ; i
.charmap $6A, $14   ; j
.charmap $6B, $15   ; k
.charmap $6C, $16   ; l
.charmap $6D, $17   ; m
.charmap $6E, $18   ; n
.charmap $6F, $19   ; o
.charmap $70, $1A   ; p
.charmap $71, $1B   ; q
.charmap $72, $1C   ; r
.charmap $73, $1D   ; s
.charmap $74, $1E   ; t
.charmap $75, $1F   ; u
.charmap $76, $20   ; v
.charmap $77, $21   ; w
.charmap $78, $22   ; x
.charmap $79, $23   ; y
.charmap $7A, $24   ; z
