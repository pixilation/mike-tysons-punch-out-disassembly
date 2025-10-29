.include "Mike_Tysons_Punchout_Defines.asm"

.segment "PRG_Bank00A": DIRECT

;Message commands
EOL :=                  $80     ;End of Line / New line
EOM :=                  $00     ;End of Message
CLEAR :=                $FA     ;Clear the current message, sized for Doc messages
CLEAR_OPP :=            $FB     ;Clear the current message, sized for opponent messages (unused)
RESET :=                $FC     ;Move the text cursor to the start of the message box

;Message commands with parameters
SLEEP :=                $81     ;Sleep before outputting the next character. Example: SLEEP, 96 - sleep for 96 frames
ADVANCE :=              $FE     ;Advance the text cursor by the given amount. Example: ADVANCE, $01
SFX :=                  $F9     ;Set the talking sound effect (see SQ1_ constants, and SND_OFF). Example: SFX, $09

PrintMessage:
L8000:  JMP CheckStatus         ;Entry point

;Initialize a message based on the MessageID in the accumulator
InitMessage:
L8003:  AND #$7F                ;Clear bit 7 of the MessageID to indicate the message has been initialized
L8005:  STA MessageID           ;Store MessageID, having cleared the uninitialized bit (bit 7)
L8008:  ASL                     ;Multiply by 2 to get a message-index into a table of pointers (address of first byte of pointer)
L8009:  LDY #$00
L800B:  STY LetterIndex         ;Start processing the message at index 0
L800E:  STY VRAMQueueData+1     ;($0414)Add 2 null byte terminator to VRAM queue after 1st character
L8011:  STY VRAMQueueData+2     ;($0415)
L8014:  CMP #$E2                ;Compare the message-index in A to $E2 (same as comparing MessageID to $71)
L8016:  BCS InitMiscMessage     ;If MessageID >= $71, then it is a miscellaneous message
L8018:  CMP #$42                ;Compare the message-index in A to $42 (same as comparing MessageID to $21)
L801A:  BCC InitTrainerMessage  ;If MessageID < $21, then it is a trainer message
;Fall through to opponent message (MesssageID $21 to $70)

;Load opponent message
;Handles MessageID in range [$21,$70]
InitOpponentMessage:
L801C:  SBC #$40                ;(C=1) Subtract $40 from the message-index in A (convert MessageID from range [$21,$70] to [$01,$50])
L801E:  TAY                     ;Transfer the message-index in A to Y for a lookup into the OpponentMsgPtrs table
L801F:  LDA OpponentMsgPtrs,Y   ;($8181)
L8022:  INY
L8023:  STA MessagePtr
L8026:  LDA OpponentMsgPtrs,Y   ;($8181)
L8029:  STA MessagePtr+1
;Set the message position on screen for all opponent messages
.scope
pos = col_18 + row_19 + nametable_0 ;$2272
L802C:  LDX #<pos               ;Set X to the message position (lower byte)
L802E:  LDY #>pos               ;Set Y to the message position (upper byte)
.endscope
L8030:  LDA #SQ1_TALK3          ;Talking sound effect
L8032:  BNE SetupMessage

;Load trainer message
;Handles MessageID in range [$00,$20]
InitTrainerMessage:
L8034:  TAY                     ;Transfer the message-index in A to Y for a lookup into the TrainerMsgPtrs table
L8035:  LDA TrainerMsgPtrs,Y    ;($815B)
L8038:  INY
L8039:  STA MessagePtr
L803C:  LDA TrainerMsgPtrs,Y    ;($815B)
L803F:  STA MessagePtr+1
;Set the message position on screen for all trainer messages
.scope
position_doc = col_00 + row_08 + nametable_0 ;$2100
L8042: LDX #<position_doc       ;Set X to the initial message screen position (lower byte)
L8044: LDY #>position_doc       ;Set Y to the initial message screen position (upper byte)
.endscope
L8046:  LDA #SQ1_TALK2          ;Talking sound effect
L8048:  BNE SetupMessage

;Load miscellaneous message
;Handles MessageID in range [$71,$7F]
;Note: miscellaneous messages start with a 2 byte header with the message position
InitMiscMessage:
L804A:  SBC #$E0                ;(C=1) Subtract $E0 from the message-index in A (convert MessageID from range [$71,$7F] to [$01,$0F])
L804C:  TAY
L804D:  LDA MiscStrings,Y       ;($81E5)Prepare to load header bytes from string
L8050:  INY
L8051:  STA MessagePtr
L8054:  STA GenPtrE0            ;Save a 2nd copy of the message pointer to the zero page
L8056:  LDA MiscStrings,Y       ;($81E5)
L8059:  STA MessagePtr+1
L805C:  STA GenPtrE0+1
L805E:  LDY #$00                ;Y contains an index into the message
L8060:  LDA (GenPtrE0),Y        ;Load the MessagePosLB from byte 0 of the misc message header
L8062:  TAX                     ;Set X to the MessagePosLB
L8063:  INY                     ;Get the next byte of the message
L8064:  LDA (GenPtrE0),Y        ;Load the MessagePosUB from byte 1 of the misc message header
L8066:  INY                     ;Move past the header
L8067:  STY LetterIndex         ;Set the start of the message to 2, due to the header
L806A:  TAY                     ;Set Y to the MessagePosUB
L806B:  LDA #SND_OFF            ;Set talking sound effect off, as music plays during miscellaneous messages

;Set up the message variables
SetupMessage:;(Y=MessagePosUB, X=MessagePosLB, A=talking sfx)
L806D:  STY LinePosUB           ;Set the starting line position
L8070:  STY MessagePosUB        ;Save the position of the message, for restoring line and cursor positions after a RESET
L8073:  STY VQAddressUB         ;Set the cursor position where the next character will be output
L8076:  STX LinePosLB
L8079:  STX MessagePosLB
L807C:  STX VQAddressLB
L807F:  STA TalkingSFX          ;Set sound effect that plays while text is output
L8082:  BNE PrepareForNextCharacter

InitRequired:
L8084:  JMP InitMessage

CheckStatus:
L8087:  TAX                     ;
L8088:  BMI InitRequired        ;If bit 7 of the MessageID is set then the message needs to be initialized
L808A:  DEC LetterTimer         ;
L808D:  BNE Return_1            ;Wait for the timer to reach 0 to print the next letter

PrepareForNextCharacter:
L808F:  LDA #$04
L8091:  STA LetterTimer         ;Wait 4 frames after this character before printing the next one
L8094:  LDY LetterIndex         ;Load the index of the next byte of the message to be processed
L8097:  LDA MessagePtr          ;Load the MessagePtr into the zero page
L809A:  STA GenPtrE0
L809C:  LDA MessagePtr+1
L809F:  STA GenPtrE0+1

NextCharacter:
L80A1:  LDA (GenPtrE0),Y        ;Get the next byte from the message
L80A3:  INY                     ;Increment the message position
L80A4:  TAX                     ;Set the zero flag
L80A5:  BEQ Return_2            ;NULL byte indicates end of message
L80A7:  BMI HandleSpecialChar   ;
L80A9:  LDX TalkingSFX          ;Load talking sound effect for printable character
L80AC:  STX SFXInitSQ1          ;($F0)

HandleCharacter:
L80AE:  STA VRAMQueueData       ;Set this as the next character to write to VRAM
L80B1:  STY LetterIndex
;Fall through to SetPendingVRAMUpdate

;Update the VRAM queue status to indicate there are tiles to write to VRAM (otherwise the text won't appear)
SetPendingVRAMUpdate:
L80B4:  LDA #$81                ;%10000001 - Set bit 7 to indicate a pending VRAM update
L80B6:  STA VRAMQueueStatus     ;($0410)
L80B9:  INC VQAddressLB

Return_1:
L80BC:  RTS

Return_2:
L80BD:  STA MessageID           ;Message finished, store NULL byte into MessageID
L80C0:  RTS

HandleEOL:
L80C1:  LDA LinePosLB           ;Load the position of the current line
L80C4:  CLC
L80C5:  ADC #$20                ;Move to the next line by adding the screen width of $20
L80C7:  STA LinePosLB           ;Save the updated line position
L80CA:  STA VQAddressLB         ;Set the cursor to the start of the new line
L80CD:  BCC NextCharacter       ;Check if adding $20 caused an overflow requiring the upper bytes to be updated
L80CF:  INC LinePosUB           ;Carry is set, so upper bytes need to increment (e.g. $21FF+1 = $2200)
L80D2:  INC VQAddressUB
L80D5:  BNE NextCharacter       ;This will always jump

;Handle $81 $xx in message - sleep for $xx frames
HandleSleep:
L80D7:  LDA (GenPtrE0),Y        ;Get the next byte of the message, which is the $xx argument to the SLEEP command
L80D9:  STA LetterTimer         ;Wait this many frames before printing the next letter
L80DC:  INY                     ;Consume the $xx argument and move to the next character of the message
L80DD:  STY LetterIndex
L80E0:  RTS

;Handle $F9 $xx in message - change talking sound effect
HandleSFX:
L80E1:  LDA (GenPtrE0),Y        ;Get the next byte of the message, which is the $xx argument to the SFX command
L80E3:  STA TalkingSFX          ;Store it in the sound effect register
L80E6:  INY                     ;Consume the $xx argument and move to the next character of the message
L80E7:  BNE NextCharacter

;Handle characters with bit 7 set
HandleSpecialChar:
L80E9:  INX                     ;Increment the X register until it overflows to 0
L80EA:  BEQ HandleCharacter     ;$FF - Space
L80EC:  INX
L80ED:  BEQ HandleAdvance       ;$FE, $xx - ADVANCE, move cursor forward by $xx
L80EF:  INX
L80F0:  BEQ HandleCharacter     ;$FD - Space (unused)
L80F2:  INX
L80F3:  BEQ HandleReset         ;$FC - RESET
L80F5:  INX
L80F6:  BEQ HandleClearOpp      ;$FB - Clear opponent message (unused)
L80F8:  INX
L80F9:  BEQ HandleClearTrainer  ;$FA - Clear Doc message
L80FB:  INX
L80FC:  BEQ HandleSFX           ;$F9, $xx - Set talking sound effect to index $xx
L80FE:  CMP #EOL                ;Is character $80? (comparing to accumulator, not X)
L8100:  BEQ HandleEOL           ;$80 - EOL
L8102:  BNE HandleSleep         ;$81, $xx - CMD_SLEEP, Sleep for that many frames ($82-$F8 map to this but are unused)

;Handle $FE $xx in message - move cursor forward by $xx
;This is typically used to set the start of a new line after a EOL character.
;Add $xx to the cursor position, moving it right, wrapping to a newline every 32 characters.
HandleAdvance:
L8104:  LDA (GenPtrE0),Y        ;Get the next byte of the message, which is the $xx argument to the ADVANCE command
L8106:  CLC
L8107:  ADC VQAddressLB         ;Add the $xx argument to the cursor position
L810A:  STA VQAddressLB
L810D:  INY                     ;Consume the $xx argument and move to the next character of the message
L810E:  BNE NextCharacter

;Handle $FC in message - Reset cursor to beginning of message
;Used in a RESET, CLEAR, RESET sequence to clear the current dialogue and output a second page of dialogue
HandleReset:
L8110:  LDA MessagePosLB        ;Get the message position
L8113:  STA LinePosLB           ;Reset the line position
L8116:  STA VQAddressLB         ;Reset the cursor position
L8119:  LDA MessagePosUB
L811C:  STA LinePosUB
L811F:  STA VQAddressUB
L8122:  LDA #$00                ;Null byte terminator
L8124:  STA VRAMQueueData+1     ;($0414)Add 2 null byte terminator to VRAM queue after 1st character
L8127:  STA VRAMQueueData+2     ;($0415)TODO: explain this
L812A:  JMP NextCharacter

;Handle $FB in message - Clear opponent message from screen
;Clear the current message by writing 8 rows of 11 spaces to the VRAM queue
;This appears to be sized for opponent messages, however no messages use this command as no opponents have 2 pages of text.
HandleClearOpp:
.scope
        rows = 8
        columns =  11
        LDA #rows
        LDX #columns
.endscope
L8131:  BNE ClearMessage

;Handle $FA in message - Clear trainer message from screen
;Clear the current message by writing 6 rows of 12 spaces to the VRAM queue
;This is sized for trainer messages.
HandleClearTrainer:
.scope
        rows = 6
        columns =  12
        LDA #rows
        LDX #columns
.endscope
;Fall through to ClearMessage

;Clear the trainer message by filling the VRAM queue with spaces
;Used in a RESET, CLEAR, RESET sequence to clear the current dialogue and output a second page of dialogue (e.g. alternate between Mac and Doc)
ClearMessage: ;(A=ROWS, X=COLUMNS)
.scope
        cols_left =    $E2      ;Loop variable for the current column being cleared
        rows_to_clr =  $E3      ;Number of rows to clear (used to populate X as a loop variable)

        STA rows_to_clr         ;Save the number of rows to clear
        STX cols_left           ;Save columns to clear for use as loop variable
        STY LetterIndex         ;Save the current letter index
        LDY #$00                ;Y is the offset into the VRAMQueueData table, start at 0 and increment after each byte written

@OuterLoop:                     ;For cols_left = COLUMNS to 1
        LDX rows_to_clr         ;Write a string this long to the table
        LDA #$FF                ;Fill the string with the tile representing the space character

@InnerLoop:                     ;For X = rows_to_clr to 1
        STA VRAMQueueData,Y     ;Set [$0413,$0418] = #$FF
        INY                     ;Point to the next byte in the table
        DEX                     ;Decrement the loop counter
        BNE @InnerLoop

        LDA #EOM                ;A = 0
        STA VRAMQueueData,Y     ;Terminate the string with a NULL byte
        INY
        DEC cols_left           ;Decrement remaining strings
        BNE @OuterLoop

        STA VRAMQueueData,Y     ;Write 2nd null byte after last string
        JMP SetPendingVRAMUpdate
.endscope

;; Pointers to Mac and Doc messages
TrainerMsgPtrs:
L815B:  .word $0000,    DocMsg01, DocMsg02, DocMsg03, DocMsg04, DocMsg05, DocMsg06, DocMsg07
L816B:  .word DocMsg08, DocMsg09, DocMsg10, DocMsg11, DocMsg12, DocMsg13, DocMsg14, DocMsg15
L817B:  .word DocMsg16, DocMsg17, DocMsg18

;; Pointers to opponent messages
OpponentMsgPtrs:
L8181:  .word $0000,    OppMsg01, OppMsg02, OppMsg03, OppMsg04, OppMsg05, OppMsg06, OppMsg07
L8191:  .word OppMsg08, OppMsg09, OppMsg10, OppMsg11, OppMsg12, OppMsg13, OppMsg14, OppMsg15
L81A1:  .word OppMsg16, OppMsg17, OppMsg18, OppMsg19, OppMsg20, OppMsg21, OppMsg22, OppMsg23
L81B1:  .word OppMsg24, OppMsg25, OppMsg26, OppMsg27, OppMsg28, OppMsg29, OppMsg30, OppMsg31
L81C1:  .word OppMsg32, OppMsg33, OppMsg34, OppMsg35, OppMsg36, OppMsg37, OppMsg38, OppMsg39
L81D1:  .word OppMsg40, OppMsg41, OppMsg42, OppMsg43, OppMsg44, OppMsg45, OppMsg46, OppMsg47
L81E1:  .word OppMsg48, OppMsg49

;; Pointers to miscellaneous strings for intro and credits, etc.
MiscStrings:
L81E5:  .word $0000, MiscMsg1, MiscMsg2, MiscMsg3, MiscMsg4, MiscMsg5, MiscMsg6, MiscMsg7

;; -----------------------------------------------------------------------------

; Map ASCII character to the Punch Out tile map
; < and > are used in place of left-double-quote and right-double-quote (as ASCII doesn't have these, but Punch Out does)
.include "charmap.asm"

; EOL           - move the cursor to the start of the next line
; ADVANCE, $xx  - moves the cursor by $xx
; EOM           - end the message
; SFX, $xx      - change the talking sound effect
; RESET         - move the cursor back to the starting position
; CLEAR         - clear the trainer message
; CLEAR_OPP     - clear the opponenent message (unused but functional)
; SLEEP, $xx    - wait $xx frames before the next character (in addition to the standard 4 frames)

; Standard dialog:
; <Hello
;  World>
;       "<Hello"        - output left-double-quote then "Hello"
;       EOL             - move the cursor to the start of the next line
;       ADVANCE, $01    - the first line started with "<", so move forward 1 character to line up the letters
;       "World>"        - output "World" then right-double-quote
;       EOM             - end the message
;       

; Switch between Doc and Mac talking:
;       SLEEP, $60              - keep the current message on screen for 100 frames ($60 => 96, + standard 4 frames)
;       RESET, CLEAR,   RESET   - clear the dialogue for a another page of dialogue
;       SFX, SQ1_TALK2          - change the talking sound to another person

;; "KEEP YOUR GUARD UP!"
DocMsg01:
.byte "<KEEP YOUR", EOL, ADVANCE, $01
.byte "GUARD UP!>", EOM

;; "PUT HIM AWAY!!"
DocMsg02:
.byte "<PUT HIM", EOL, ADVANCE, $01
.byte "AWAY!!>", EOM

;; "STICK AND MOVE, STICK AND MOVE!"
DocMsg03:
.byte "<STICK AND", EOL, ADVANCE, $01
.byte "MOVE,", EOL, ADVANCE, $01
.byte "STICK AND", EOL, ADVANCE, $01
.byte "MOVE!>", EOM

;; "WATCH HIS LEFT!"
DocMsg04:
.byte "<WATCH", EOL, ADVANCE, $01
.byte "HIS LEFT!>", EOM

;; "ONE TWO, ONE TWO PUNCH, MAC!"
DocMsg05:
.byte "<ONE TWO,", EOL, ADVANCE, $01
.byte "ONE TWO", EOL, ADVANCE, $01
.byte "PUNCH", EOL, ADVANCE, $01
.byte "MAC!>", EOM

;; "DANCIN' LIKE A FLY, BITE LIKE A MOSQUITO!"
DocMsg06:
.byte "<DANCIN'", EOL, ADVANCE, $01
.byte "LIKE A FLY,", EOL, ADVANCE, $01
.byte "BITE", EOL, ADVANCE, $01
.byte "LIKE A", EOL, ADVANCE, $01
.byte "MOSQUITO!>", EOM

;; "HE'S HURT ME, DOC!" / "DON'T GIVE UP, MAC! FIGHT IT!!"
DocMsg07:
.byte SFX, SQ1_TALK1
.byte "<HE'S HURT", EOL, ADVANCE, $01
.byte "ME, DOC!>", SLEEP, $60
.byte RESET
.byte CLEAR
.byte RESET
.byte SFX, SQ1_TALK2
.byte "<DON'T GIVE", EOL, ADVANCE, $01
.byte "UP, MAC!", EOL, ADVANCE, $01
.byte "FIGHT!!>", EOM

;; "I CAN'T WIN, DOC!" / "YES YOU CAN, MAC!"
DocMsg08:
.byte SFX, SQ1_TALK1
.byte "<I CAN'T", EOL, ADVANCE, $01
.byte "WIN, DOC!>", SLEEP, $60
.byte RESET
.byte CLEAR
.byte RESET
.byte SFX, SQ1_TALK2
.byte "<YES YOU", EOL, ADVANCE, $01
.byte "CAN, MAC!>", EOM

;; "I'M TIRED, DOC!" / "HANG IN THERE, MAC!"
DocMsg09:
.byte SFX, SQ1_TALK1
.byte "<I'M TIRED,", EOL, ADVANCE, $01
.byte "DOC!>", SLEEP, $60
.byte RESET
.byte CLEAR
.byte RESET
.byte SFX, SQ1_TALK2
.byte "<HANG IN", EOL, ADVANCE, $01
.byte "THERE,", EOL, ADVANCE, $01
.byte "MAC!>", EOM

;; "LISTEN MAC!! DODGE HIS PUNCH THEN COUNTER-PUNCH!"
DocMsg10:
.byte "<LISTEN", EOL, ADVANCE, $05
.byte "MAC!!>", SLEEP, $40
.byte RESET
.byte CLEAR
.byte RESET
.byte "<DODGE", EOL, ADVANCE, $01
.byte "HIS PUNCH", EOL, ADVANCE, $01
.byte "THEN", EOL, ADVANCE, $01
.byte "COUNTER-", EOL, ADVANCE, $01
.byte "PUNCH!>", EOM

;; "LISTEN MAC!! GIVE HIM A FAST UPPER-CUT WHEN HE'S STUNNED!"
DocMsg11:
.byte "<LISTEN", EOL, ADVANCE, $05
.byte "MAC!!>", SLEEP, $40
.byte RESET
.byte CLEAR
.byte RESET
.byte "<GIVE HIM", EOL, ADVANCE, $01
.byte "A FAST", EOL, ADVANCE, $01
.byte "UPPER-CUT", EOL, ADVANCE, $01
.byte "WHEN HE'S", EOL, ADVANCE, $01
.byte "STUNNED!>", EOM

;; "LISTEN MAC!! CATCH HIM OFF-GUARD TO STUN HIM! THEN UNLOAD ON HIM!"
DocMsg12:
.byte "<LISTEN", EOL, ADVANCE, $05
.byte "MAC!!>", SLEEP, $40
.byte RESET
.byte CLEAR
.byte RESET
.byte "<CATCH HIM", EOL, ADVANCE, $01
.byte "OFF-GUARD", EOL, ADVANCE, $01
.byte "TO STUN", EOL, ADVANCE, $01
.byte "HIM!>", SLEEP, $60
.byte RESET
.byte CLEAR
.byte RESET
.byte "<THEN", EOL, ADVANCE, $01
.byte "UNLOAD", EOL, ADVANCE, $01
.byte "ON HIM!>", EOM

;; "HELP! DOC!!" / "JOIN THE NINTENDO FUN CLUB TODAY! MAC."
DocMsg13:
.byte SFX, SQ1_TALK1
.byte "<HELP!", EOL, ADVANCE, $01
.byte "DOC!!>", SLEEP, $60
.byte RESET
.byte CLEAR
.byte RESET
.byte SFX, SQ1_TALK2
.byte "<JOIN THE", EOL, ADVANCE, $01
.byte "NINTENDO", EOL, ADVANCE, $01
.byte "FUN CLUB", EOL, ADVANCE, $01
.byte "TODAY!", EOL, ADVANCE, $01
.byte "MAC.>", EOM

;; "HIS DEFENSE IS TOO TOUGH, DOC!" / "DON'T GIVE UP, MAC! HE HAS A WEAKNESS.."
;;  / "WEAKNESS? COME ON DOC! TEACH ME MORE.."
DocMsg14:
.byte SFX, SQ1_TALK1
.byte "<HIS", EOL, ADVANCE, $01
.byte "DEFENSE IS", EOL, ADVANCE, $01
.byte "TOO TOUGH,", EOL, ADVANCE, $01
.byte "DOC!>", SLEEP, $60
.byte RESET
.byte CLEAR
.byte RESET
.byte SFX, SQ1_TALK2
.byte "<DON'T GIVE", EOL, ADVANCE, $01
.byte "UP, MAC!", EOL, ADVANCE, $01
.byte "HE HAS A", EOL, ADVANCE, $01
.byte "WEAKNESS..", EOL, ADVANCE, $01
.byte "......>", SLEEP, $60
.byte RESET
.byte CLEAR
.byte RESET
.byte SFX, SQ1_TALK1
.byte "<WEAKNESS?", EOL, ADVANCE, $01
.byte "COME ON", EOL, ADVANCE, $01
.byte "DOC!", EOL, ADVANCE, $01
.byte "TEACH ME", EOL, ADVANCE, $01
.byte "MORE...>", EOM

;; "HIS DEFENSE IS TOO TOUGH, DOC!" / "DON'T GIVE UP, MAC! MAKE HIM CLOSE HIS BIG MOUTH"
;;  / "BIG MOUTH? COME ON DOC! TEACH ME MORE..."
DocMsg15:
.byte SFX, SQ1_TALK1
.byte "<HIS", EOL, ADVANCE, $01
.byte "DEFENSE IS", EOL, ADVANCE, $01
.byte "TOO TOUGH,", EOL, ADVANCE, $01
.byte "DOC!>", SLEEP, $60
.byte RESET
.byte CLEAR
.byte RESET
.byte SFX, SQ1_TALK2
.byte "<DON'T GIVE", EOL, ADVANCE, $01
.byte "UP, MAC!", EOL, ADVANCE, $01
.byte "MAKE HIM", EOL, ADVANCE, $01
.byte "CLOSE HIS", EOL, ADVANCE, $01
.byte "BIG MOUTH>", SLEEP, $60
.byte RESET
.byte CLEAR
.byte RESET
.byte SFX, SQ1_TALK1
.byte "<BIG MOUTH?", EOL, ADVANCE, $01
.byte "COME ON", EOL, ADVANCE, $01
.byte "DOC!", EOL, ADVANCE, $01
.byte "TEACH ME", EOL, ADVANCE, $01
.byte "MORE...>", EOM

;; "HIS FATHER WAS A GREAT MAGICIAN IN INDIA. DON'T BE CHARMED BY HIS MAGIC PUNCHES."
DocMsg16:
.byte "<HIS FATHER", EOL, ADVANCE, $01
.byte "WAS A", EOL, ADVANCE, $01
.byte "GREAT", EOL, ADVANCE, $01
.byte "MAGICIAN", EOL, ADVANCE, $01
.byte "IN INDIA.>", SLEEP, $60
.byte RESET
.byte CLEAR
.byte RESET
.byte "<DON'T BE", EOL, ADVANCE, $01
.byte "CHARMED BY", EOL, ADVANCE, $01
.byte "HIS MAGIC", EOL, ADVANCE, $01
.byte "PUNCHES.>", EOM

;; "MAC! WATCH HIS BULL CHARGE! STAND UP TO HIM!"
DocMsg17:
.byte "<MAC! WATCH", EOL, ADVANCE, $01
.byte "HIS BULL", EOL, ADVANCE, $01
.byte "CHARGE!", EOL, ADVANCE, $01
.byte "STAND UP", EOL, ADVANCE, $01
.byte "TO HIM!>", EOM

;; "LOOK FOR TWO TYPES OF SPIN PUNCH!"
DocMsg18:
.byte "<LOOK FOR", EOL, ADVANCE, $01
.byte "TWO TYPES", EOL, ADVANCE, $01
.byte "OF SPIN", EOL, ADVANCE, $01
.byte "PUNCH!", EOL, ADVANCE, $01
.byte "WATCH HIM>", EOM

;; -----------------------------------------------------------------------------------------

;; "THIS IS MY LAST MATCH! I'M TOO OLD FOR FIGHTING!"
OppMsg01:
.byte "<THIS IS", EOL, ADVANCE, $01
.byte "MY LAST", EOL, ADVANCE, $01
.byte "MATCH!", EOL, EOL, ADVANCE, $01
.byte "I'M TOO", EOL, ADVANCE, $01
.byte "OLD FOR", EOL, ADVANCE, $01
.byte "FIGHTING!>", EOM

;; "MAKE IT QUICK... I WANT TO RETIRE!"
OppMsg02:
.byte "<MAKE IT", EOL, ADVANCE, $01
.byte "QUICK...", EOL, EOL, ADVANCE, $01
.byte "I WANT", EOL, ADVANCE, $01
.byte "TO RETIRE!>", EOM

;; "WATCH THE JAW!! DON'T HIT MY JAW!"
OppMsg03:
.byte "<WATCH THE", EOL, ADVANCE, $01
.byte "JAW!!", EOL, EOL, ADVANCE, $01
.byte "DON'T HIT", EOL, ADVANCE, $01
.byte "MY JAW!>", EOM

;; "DO I HAVE TIME TO TAKE A NAP BEFORE THE FIGHT?"
OppMsg04:
.byte "<DO I HAVE", EOL, ADVANCE, $01
.byte "TIME TO", EOL, ADVANCE, $01
.byte "TAKE A NAP", EOL, ADVANCE, $01
.byte "BEFORE THE", EOL, ADVANCE, $01
.byte "FIGHT?>", EOM

;; "I WAS A BOXING TEACHER... AT THE MILITARY ACADEMY!"
OppMsg05:
.byte "<I WAS A", EOL, ADVANCE, $01
.byte "BOXING", EOL, ADVANCE, $01
.byte "TEACHER...", EOL, ADVANCE, $01
.byte "..AT THE", EOL, ADVANCE, $01
.byte "MILITARY", EOL, ADVANCE, $01
.byte "ACADEMY!>", EOM

;; "I'LL TEACH YOU A LESSON. YOU WILL FALL DOWN!"
OppMsg06:
.byte "<I'LL TEACH", EOL, ADVANCE, $01
.byte "YOU A", EOL, ADVANCE, $01
.byte "LESSON.", EOL, EOL, ADVANCE, $01
.byte "YOU WILL", EOL, ADVANCE, $01
.byte "FALL DOWN!>", EOM

;; "YOUR PUNCH IS SOFT... JUST LIKE YOUR HEART!"
OppMsg07:
.byte "<YOUR PUNCH", EOL, ADVANCE, $01
.byte "IS SOFT...", EOL, EOL, ADVANCE, $01
.byte "JUST LIKE", EOL, ADVANCE, $01
.byte "YOUR", EOL, ADVANCE, $01
.byte "HEART!>", EOM

;; "SURRENDER! OR I WILL CONQUER YOU!!"
OppMsg08:
.byte "<SURRENDER!", EOL, EOL, ADVANCE, $01
.byte "OR I WILL", EOL, ADVANCE, $01
.byte "CONQUER", EOL, ADVANCE, $01
.byte "YOU!!>", EOM

;; "HA,HA,HA! I AM THE KING! HA,HA,HA!"
OppMsg09:
.byte "<HA,HA,HA!", EOL, EOL, ADVANCE, $01
.byte "I AM THE", EOL, ADVANCE, $01
.byte "KING!", EOL, EOL, ADVANCE, $01
.byte "HA,HA,HA!>", EOM

;; "I HAVE MY WEAKNESS. BUT I WON'T TELL YOU! HA,HA,HA!"
OppMsg10:
.byte "<I HAVE MY", EOL, ADVANCE, $01
.byte "WEAKNESS.", EOL, EOL, ADVANCE, $01
.byte "BUT I", EOL, ADVANCE, $01
.byte "WON'T TELL", EOL, ADVANCE, $01
.byte "YOU!", EOL, EOL, ADVANCE, $01
.byte "HA,HA,HA!>", EOM

;; "DO YOU LIKE MY NEW TRUNKS? THEY ARE SIZE XXX LARGE! HA,HA,HA!"
OppMsg11:
.byte "<DO YOU", EOL, ADVANCE, $01
.byte "LIKE MY", EOL, ADVANCE, $01
.byte "NEW", EOL, ADVANCE, $01
.byte "TRUNKS?", EOL, ADVANCE, $01
.byte "THEY ARE", EOL, ADVANCE, $01
.byte "SIZE", EOL, ADVANCE, $01
.byte "XXX LARGE!", EOL, EOL, ADVANCE, $01
.byte "HA,HA,HA!>", EOM

;; "I FEEL LIKE EATING. AFTER I WIN LET'S GO TO LUNCH! HA,HA,HA!"
OppMsg12:
.byte "<I FEEL", EOL, ADVANCE, $01
.byte "LIKE", EOL, ADVANCE, $01
.byte "EATING.", EOL, ADVANCE, $01
.byte "AFTER I", EOL, ADVANCE, $01
.byte "WIN LET'S", EOL, ADVANCE, $01
.byte "GO TO", EOL, ADVANCE, $01
.byte "LUNCH!", EOL, EOL, ADVANCE, $01
.byte "HA,HA,HA!>", EOM

;; "YOU SHOULD WEAR A HELMET WHEN YOU FIGHT ME!"
OppMsg13:
.byte "<YOU SHOULD", EOL, ADVANCE, $01
.byte "WEAR A", EOL, ADVANCE, $01
.byte "HELMET", EOL, ADVANCE, $01
.byte "WHEN YOU", EOL, ADVANCE, $01
.byte "FIGHT ME!>", EOM

;; "WHERE IS THE NHK TV CAMERA? HELLO, TOKYO!"
OppMsg14:
.byte "<WHERE IS", EOL, ADVANCE, $01
.byte "THE NHK TV", EOL, ADVANCE, $01
.byte "CAMERA?", EOL, EOL, ADVANCE, $01
.byte "HELLO,", EOL, ADVANCE, $01
.byte "TOKYO!>", EOM

;; "I STILL REMEMBER OUR FIRST FIGHT. NOW I'M GONNA PAY YOU BACK. BANZAI!"
OppMsg15:
.byte "<I STILL", EOL, ADVANCE, $01
.byte "REMEMBER", EOL, ADVANCE, $01
.byte "OUR FIRST", EOL, ADVANCE, $01
.byte "FIGHT.", EOL, EOL, ADVANCE, $01
.byte "NOW I'M", EOL, ADVANCE, $01
.byte "GONNA PAY", EOL, ADVANCE, $01
.byte "YOU BACK.", EOL, ADVANCE, $01
.byte "BANZAI!!>", EOM

;; "I'LL GIVE YOU A TKO FROM TOKYO!"
OppMsg16:
.byte "<I'LL GIVE", EOL, ADVANCE, $01
.byte "YOU A TKO", EOL, ADVANCE, $01
.byte "FROM", EOL, ADVANCE, $01
.byte "TOKYO!>", EOM

;; "SUSHI, KAMIKAZE, FUJIYAMA, NIPPON-ICHI"
OppMsg17:
.byte "<SUSHI,", EOL, ADVANCE, $01
.byte "KAMIKAZE,", EOL, ADVANCE, $01
.byte "FUJIYAMA,", EOL, ADVANCE, $01
.byte "NIPPON-", EOL, ADVANCE, $01
.byte "ICHI...>", EOM

;; "SO A PUSSYCAT WANTS TO FIGHT A TIGER!"
OppMsg18:
.byte "<SO A", EOL, ADVANCE, $01
.byte "PUSSYCAT", EOL, ADVANCE, $01
.byte "WANTS TO", EOL, ADVANCE, $01
.byte "FIGHT A", EOL, ADVANCE, $01
.byte "TIGER!>", EOM

;; "BEWARE MY TIGER PUNCH!"
OppMsg19:
.byte "<BEWARE", EOL, ADVANCE, $01
.byte "MY TIGER", EOL, ADVANCE, $01
.byte "PUNCH!>", EOM

;; "FLAMENCO STRIKES BACK!! RETURN OF DON!!"
OppMsg20:
.byte "<FLAMENCO", EOL, ADVANCE, $01
.byte "STRIKES", EOL, ADVANCE, $01
.byte "BACK!!", EOL, EOL, ADVANCE, $01
.byte "RETURN OF", EOL, ADVANCE, $01
.byte "DON!!>", EOM

;; "A KITTEN IS NO MATCH FOR A TIGER!"
OppMsg21:
.byte "<A KITTEN", EOL, ADVANCE, $01
.byte "IS NO", EOL, ADVANCE, $01
.byte "MATCH FOR", EOL, ADVANCE, $01
.byte "A TIGER!>", EOM

;; "I HAVE PURRED LONG ENOUGH. NOW HEAR ME ROAR!"
OppMsg22:
.byte "<I HAVE", EOL, ADVANCE, $01
.byte "PURRED", EOL, ADVANCE, $01
.byte "LONG", EOL, ADVANCE, $01
.byte "ENOUGH.", EOL, EOL, ADVANCE, $01
.byte "NOW HEAR", EOL, ADVANCE, $01
.byte "ME ROAR!>", EOM

;; "DOC CAN'T HELP YOU NOW. WILL YOU BEG ME FOR HELP?"
OppMsg23:
.byte "<DOC CAN'T", EOL, ADVANCE, $01
.byte "HELP YOU", EOL, ADVANCE, $01
.byte "NOW.", EOL, EOL, ADVANCE, $01
.byte "WILL YOU", EOL, ADVANCE, $01
.byte "BEG ME FOR", EOL, ADVANCE, $01
.byte "HELP?>", EOM

;; "HEY!LITTLE MAC! MAYBE DOC SHOULD THROW YOU A TOWEL!"
OppMsg24:
.byte "<HEY!LITTLE", EOL, ADVANCE, $01
.byte "MAC!", EOL, EOL, ADVANCE, $01
.byte "MAYBE DOC", EOL, ADVANCE, $01
.byte "SHOULD", EOL, ADVANCE, $01
.byte "THROW YOU", EOL, ADVANCE, $01
.byte "A TOWEL!>", EOM

;; "MY BARBER DIDN'T KNOW WHEN TO QUIT... DO YOU?"
OppMsg25:
.byte "<MY BARBER", EOL, ADVANCE, $01
.byte "DIDN'T", EOL, ADVANCE, $01
.byte "KNOW WHEN", EOL, ADVANCE, $01
.byte "TO QUIT...", EOL, EOL, ADVANCE, $01
.byte "DO YOU?>", EOM

;; "ZIP YOUR LIP,DOC! LITTLE MAC IS MINE NOW."
OppMsg26:
.byte "<ZIP YOUR", EOL, ADVANCE, $01
.byte "LIP,DOC!", EOL, EOL, ADVANCE, $01
.byte "LITTLE MAC", EOL, ADVANCE, $01
.byte "IS MINE", EOL, ADVANCE, $01
.byte "NOW.>", EOM

;; "I CAN'T DRIVE, SO I'M GONNA WALK ALL OVER YOU!"
OppMsg27:
.byte "<I CAN'T", EOL, ADVANCE, $01
.byte "DRIVE,", EOL, ADVANCE, $01
.byte "SO I'M", EOL, ADVANCE, $01
.byte "GONNA WALK", EOL, ADVANCE, $01
.byte "ALL OVER", EOL, ADVANCE, $01
.byte "YOU!>", EOM

;; "WOULD YOU LIKE SOME PUNCH TO DRINK? HA,HA,HA!"
OppMsg28:
.byte "<WOULD YOU", EOL, ADVANCE, $01
.byte "LIKE SOME", EOL, ADVANCE, $01
.byte "PUNCH TO", EOL, ADVANCE, $01
.byte "DRINK?", EOL, ADVANCE, $01
.byte "HA,HA,HA!>", EOM

;; "I'M GONNA MAKE YOU FEEL PUNCH DRUNK!"
OppMsg29:
.byte "<I'M GONNA", EOL, ADVANCE, $01
.byte "MAKE YOU", EOL, ADVANCE, $01
.byte "FEEL", EOL, ADVANCE, $01
.byte "PUNCH", EOL, ADVANCE, $01
.byte "DRUNK!>", EOM

;; "AFTER YOU LOSE,WE'LL DRINK TO YOUR HEALTH! HA,HA,HA!"
OppMsg30:
.byte "<AFTER YOU", EOL, ADVANCE, $01
.byte "LOSE,WE'LL", EOL, ADVANCE, $01
.byte "DRINK TO", EOL, ADVANCE, $01
.byte "YOUR", EOL, ADVANCE, $01
.byte "HEALTH!", EOL, EOL, ADVANCE, $01
.byte "HA,HA,HA!>", EOM

;; "I DRINK TO PREPARE FOR A FIGHT. TONIGHT I AM VERY PREPARED!"
OppMsg31:
.byte "<I DRINK TO", EOL, ADVANCE, $01
.byte "PREPARE", EOL, ADVANCE, $01
.byte "FOR A", EOL, ADVANCE, $01
.byte "FIGHT.", EOL, EOL, ADVANCE, $01
.byte "TONIGHT I", EOL, ADVANCE, $01
.byte "AM VERY", EOL, ADVANCE, $01
.byte "PREPARED!>", EOM

;; "HEY! MAC BABY... SAY GOODNIGHT!"
OppMsg32:
.byte "<HEY!", EOL, ADVANCE, $01
.byte "MAC BABY...", EOL, EOL, ADVANCE, $01
.byte "SAY", EOL, ADVANCE, $01
.byte "GOODNIGHT!>", EOM

;; "WELCOME TO DREAMLAND, BABY!"
OppMsg33:
.byte "<WELCOME", EOL, ADVANCE, $01
.byte "TO", EOL, ADVANCE, $01
.byte "DREAMLAND,", EOL, ADVANCE, $01
.byte "BABY!>", EOM

;; "THIS TIME I'M GONNA CHARGE RIGHT OVER YOU!"
OppMsg34:
.byte "<THIS TIME", EOL, ADVANCE, $01
.byte "I'M GONNA", EOL, ADVANCE, $01
.byte "CHARGE", EOL, ADVANCE, $01
.byte "RIGHT OVER", EOL, ADVANCE, $01
.byte "YOU!>", EOM

;; "I THINK YOU'RE GONNA HAVE A NIGHTMARE TONIGHT!"
OppMsg35:
.byte "<I THINK", EOL, ADVANCE, $01
.byte "YOU'RE", EOL, ADVANCE, $01
.byte "GONNA", EOL, ADVANCE, $01
.byte "HAVE A", EOL, ADVANCE, $01
.byte "NIGHTMARE", EOL, ADVANCE, $01
.byte "TONIGHT!>", EOM

;; "BEDTIME FOR LITTLE MAC!"
OppMsg36:
.byte "<BEDTIME", EOL, ADVANCE, $01
.byte "FOR LITTLE", EOL, ADVANCE, $01
.byte "MAC!>", EOM

;; "I'M A BEAUTIFUL FIGHTER. I HAVE SUCH A STYLE!"
OppMsg37:
.byte "<I'M A", EOL, ADVANCE, $01
.byte "BEAUTIFUL", EOL, ADVANCE, $01
.byte "FIGHTER.", EOL, EOL, ADVANCE, $01
.byte "I HAVE", EOL, ADVANCE, $01
.byte "SUCH A", EOL, ADVANCE, $01
.byte "STYLE!>", EOM

;; "PEOPLE LIKE MY HAIR. DON'T MESS MY HAIR!"
OppMsg38:
.byte "<PEOPLE", EOL, ADVANCE, $01
.byte "LIKE MY", EOL, ADVANCE, $01
.byte "HAIR.", EOL, EOL, ADVANCE, $01
.byte "DON'T MESS", EOL, ADVANCE, $01
.byte "MY HAIR!>", EOM

;; "CARMEN, MY LOVE... I DANCE SO SWEET FOR YOU!"
OppMsg39:
.byte "<CARMEN,", EOL, ADVANCE, $01
.byte "MY LOVE...", EOL, EOL, ADVANCE, $01
.byte "I DANCE", EOL, ADVANCE, $01
.byte "SO SWEET", EOL, ADVANCE, $01
.byte "FOR YOU!>", EOM

;; "HEY!MR. REFEREE MARIO... I LIKE YOUR HAIR!"
OppMsg40:
.byte "<HEY!MR.", EOL, ADVANCE, $01
.byte "REFEREE", EOL, ADVANCE, $01
.byte "MARIO...", EOL, EOL, ADVANCE, $01
.byte "I LIKE", EOL, ADVANCE, $01
.byte "YOUR HAIR!>", EOM

;; "I WORK ON MY TAN HARDER THAN I'LL HAVE TO WORK ON YOU!"
OppMsg41:
.byte "<I WORK ON", EOL, ADVANCE, $01
.byte "MY TAN", EOL, ADVANCE, $01
.byte "HARDER", EOL, ADVANCE, $01
.byte "THAN I'LL", EOL, ADVANCE, $01
.byte "HAVE TO", EOL, ADVANCE, $01
.byte "WORK ON", EOL, ADVANCE, $01
.byte "YOU!>", EOM

;; "I DON'T SMOKE. BUT TONIGHT I'M GONNA SMOKE YOU!"
OppMsg42:
.byte "<I DON'T", EOL, ADVANCE, $01
.byte "SMOKE...", EOL, EOL, ADVANCE, $01
.byte "BUT", EOL, ADVANCE, $01
.byte "TONIGHT", EOL, ADVANCE, $01
.byte "I'M GONNA", EOL, ADVANCE, $01
.byte "SMOKE YOU!>", EOM

;; "MY BODY IS JUST SO TOTALLY COOL!"
OppMsg43:
.byte "<MY BODY", EOL, ADVANCE, $01
.byte "IS JUST", EOL, ADVANCE, $01
.byte "SO TOTALLY", EOL, ADVANCE, $01
.byte "COOL!>", EOM

;; "MY SUPER SPIN PUNCH IS TOTALLY TOUGH!"
OppMsg44:
.byte "<MY SUPER", EOL, ADVANCE, $01
.byte "SPIN PUNCH", EOL, ADVANCE, $01
.byte "IS TOTALLY", EOL, ADVANCE, $01
.byte "TOUGH!>", EOM

;; "YOU THINK THE SPEED OF YOUR FINGERS CAN MATCH THE STRENGTH OF MY FISTS?"
OppMsg45:
.byte "<YOU THINK", EOL, ADVANCE, $01
.byte "THE SPEED", EOL, ADVANCE, $01
.byte "OF YOUR", EOL, ADVANCE, $01
.byte "FINGERS", EOL, ADVANCE, $01
.byte "CAN MATCH", EOL, ADVANCE, $01
.byte "THE", EOL, ADVANCE, $01
.byte "STRENGTH", EOL, ADVANCE, $01
.byte "OF MY", EOL, ADVANCE, $01
.byte "FISTS?>", EOM

;; "IF I KNOCK YOU DOWN, DON'T GET UP!"
OppMsg46:
.byte "<IF I KNOCK", EOL, ADVANCE, $01
.byte "YOU DOWN,", EOL, ADVANCE, $01
.byte "DON'T", EOL, ADVANCE, $01
.byte "GET UP!>", EOM

;; "THEY SAY I CAN'T LOSE. I SAY YOU CAN'T WIN!"
OppMsg47:
.byte "<THEY SAY", EOL, ADVANCE, $01
.byte "I CAN'T", EOL, ADVANCE, $01
.byte "LOSE.", EOL, EOL, ADVANCE, $01
.byte "I SAY YOU", EOL, ADVANCE, $01
.byte "CAN'T WIN!>", EOM

;; "HEY! IS THIS KID A JOKE? WHERE'S THE REAL CHALLENGER"
OppMsg48:
.byte "<HEY!", EOL, EOL, ADVANCE, $01
.byte "IS THIS", EOL, ADVANCE, $01
.byte "KID A", EOL, ADVANCE, $01
.byte "JOKE?", EOL, EOL, ADVANCE, $01
.byte "WHERE'S", EOL, ADVANCE, $01
.byte "THE REAL", EOL, ADVANCE, $01
.byte "CHALLENGER>", EOM

;; "YOUR EXPERIENCE DOESN'T MATCH MINE. GO HOME AND PRACTICE!"
OppMsg49:
.byte "<YOUR", EOL, ADVANCE, $01
.byte "EXPERIENCE", EOL, ADVANCE, $01
.byte "DOESN'T", EOL, ADVANCE, $01
.byte "MATCH MINE.", EOL, EOL, ADVANCE, $01
.byte "GO HOME", EOL, ADVANCE, $01
.byte "AND", EOL, ADVANCE, $01
.byte "PRACTICE!>", EOM

;; -----------------------------------------------------------------------------------------

;; Misc messages contain a 2 byte header indicating where on the 
.include "screen.asm"

;; "STARRING LITTLE MAC AND HIS TRAINER DOC LOUIS  ALSO PLAYING THE ROLE OF MAC, IT'S YOU!!"
MiscMsg1:
.word col_02 + row_12 + nametable_0     ;.byte $82, $21
.byte SLEEP, $20, EOL, ADVANCE, $08
.byte "STARRING", EOL, EOL, ADVANCE, $07
.byte "LITTLE MAC", EOL, SLEEP, $50, EOL, ADVANCE, $0A
.byte "AND", EOL, EOL, ADVANCE, $06
.byte "HIS TRAINER", EOL, ADVANCE, $07
.byte "DOC LOUIS", EOL, SLEEP, $20, EOL, ADVANCE, $0A
.byte "ALSO", EOL
.byte "PLAYING THE ROLE OF MAC,", EOL, SLEEP, $10, EOL, ADVANCE, $07
.byte "IT'S YOU!!", EOL, SLEEP, $50, EOM

;; "THIS IS A STORY OF TRUE VICTORY!! BUT THE ROAD IS LONG......"
MiscMsg2:
.word col_01 + row_20 + nametable_2     ;.byte $81, $2A
.byte ADVANCE, $06
.byte "THIS IS A STORY", EOL, ADVANCE, $05
.byte "OF TRUE VICTORY!!", EOL, EOL
.byte "BUT THE ROAD IS LONG......", EOL
.byte SLEEP, $50, EOM

;; "PASS KEY IS"
MiscMsg3:
.word col_16 + row_03 + nametable_0     ;.byte $70, $20
.byte " PASS KEY IS", EOL, EOL, ADVANCE, $01, EOM

;; "PUSH START!"
MiscMsg4:
.word col_16 + row_07 + nametable_0     ;.byte $F0, $20
.byte " PUSH START!", EOM

;; "THE END"
MiscMsg5:
.word col_20 + row_24 + nametable_1     ;.byte $14, $27
.byte "T", SLEEP, $06
.byte "H", SLEEP, $06
.byte "E  ", SLEEP, $0C
.byte "E", SLEEP, $06
.byte "N", SLEEP, $06
.byte "D", EOM


;; Credits Page 1
MiscMsg6:
.word col_00 + row_02 + nametable_0   ;.byte $40, $20
.byte ADVANCE, $06
.byte "PRODUCER  M. ARAKAWA", SLEEP, $20, EOL, EOL, ADVANCE, $04
.byte "SUPERVISOR  NOA", SLEEP, $20, EOL, EOL, ADVANCE, $06
.byte "DIRECTOR  G. TAKEDA", SLEEP, $20, EOL, EOL, ADVANCE, $01
.byte "GAME DESIGNER  K. YONEYAMA", SLEEP, $10, EOL, ADVANCE, $10
.byte "M. HIROTA", SLEEP, $20, EOL, EOL, ADVANCE, $01
.byte "CHARACTER", EOL, ADVANCE, $06
.byte "DESIGNER  M. WADA", SLEEP, $20, EOL, EOL, ADVANCE, $01
.byte "MUSIC", EOL, ADVANCE, $06
.byte "COMPOSER  U. KANEOKA", SLEEP, $10, EOL, ADVANCE, $10
.byte "A. NAKATUKA", SLEEP, $10, EOL, ADVANCE, $10
.byte "K. YAMAMOTO", SLEEP, $20, EOM

;; Credits Page 2
MiscMsg7:
.word col_00 + row_19 + nametable_0   ;.byte $60, $22
.byte ADVANCE, $01
.byte "ELECTRICAL", EOL, ADVANCE, $06
.byte "ENGINEER  S. FUNAKOSHI", SLEEP, $10, EOL, ADVANCE, $10
.byte "M. TAYA", SLEEP, $20, EOL, EOL, ADVANCE, $04
.byte "PROGRAMMER  M. HATAKEYAMA", SLEEP, $20, EOL, EOL, ADVANCE, $05
.byte "SECRETARY  U. KURIYAMA", SLEEP, $20, EOL, EOL, ADVANCE, $03
.byte "COPYRIGHT 1987 NINTENDO", SLEEP, $20

;; -----------------------------------------------------------------------------------------

;Unused.
L93BF:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L93CE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L93DE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L93EE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L93FE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L940E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L941E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L942E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L943E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L944E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L945E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L946E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L947E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L948E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L949E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L94AE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L94BE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L94CE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L94DE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L94EE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L94FE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L950E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L951E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L952E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L953E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L954E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L955E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L956E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L957E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L958E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L959E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L95AE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L95BE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L95CE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L95DE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L95EE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L95FE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L960E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L961E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L962E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L963E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L964E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L965E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L966E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L967E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L968E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L969E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L96AE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L96BE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L96CE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L96DE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L96EE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L96FE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L970E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L971E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L972E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L973E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L974E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L975E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L976E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L977E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L978E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L979E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L97AE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L97BE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L97CE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L97DE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L97EE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L97FE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L980E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L981E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L982E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L983E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L984E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L985E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L986E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L987E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L988E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L989E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L98AE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L98BE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L98CE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L98DE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L98EE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L98FE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L990E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L991E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L992E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L993E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L994E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L995E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L996E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L997E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L998E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L999E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L99AE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L99BE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L99CE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L99DE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L99EE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L99FE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9A0E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9A1E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9A2E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9A3E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9A4E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9A5E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9A6E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9A7E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9A8E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9A9E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9AAE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9ABE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9ACE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9ADE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9AEE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9AFE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9B0E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9B1E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9B2E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9B3E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9B4E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9B5E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9B6E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9B7E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9B8E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9B9E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9BAE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9BBE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9BCE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9BDE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9BEE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9BFE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9C0E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9C1E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9C2E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9C3E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9C4E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9C5E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9C6E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9C7E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9C8E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9C9E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9CAE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9CBE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9CCE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9CDE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9CEE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9CFE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9D0E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9D1E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9D2E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9D3E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9D4E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9D5E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9D6E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9D7E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9D8E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9D9E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9DAE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9DBE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9DCE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9DDE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9DEE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9DFE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9E0E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9E1E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9E2E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9E3E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9E4E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9E5E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9E6E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9E7E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9E8E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9E9E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9EAE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9EBE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9ECE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9EDE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9EEE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9EFE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9F0E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9F1E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9F2E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9F3E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9F4E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9F5E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9F6E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9F7E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9F8E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9F9E:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9FAE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9FBE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9FCE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9FDE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9FEE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9FFE:  .byte $00, $00
