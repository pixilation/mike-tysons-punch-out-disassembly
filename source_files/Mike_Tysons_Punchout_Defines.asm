.include "Globals.inc"

;------------------------------------------[MMC Registers]-------------------------------------------

BankSelect :=       $AFFF

;--------------------------------------------[Constants]---------------------------------------------

;Silent note indexes.
NO_NOTE1 =         $00     ;Silent note.
NO_NOTE2 =         $02     ;Silent note.

;Sound channel indexes.
AUD_SQ1_INDEX =    $00     ;Square wave 1 channel index.
AUD_SQ2_INDEX =    $04     ;Square wave 2 channel index.
AUD_TRI_INDEX =    $08     ;Triangle wave channel index.

;Drum beat types.
DRUM_BEAT_1 =      $02     ;
DRUM_BEAT_2 =      $06     ;
DRUM_BEAT_3 =      $0A     ;
DRUM_BEAT_4 =      $0E     ;
DRUM_BEAT_5 =      $12     ;Various drum beats used in the music. Drum beat -->
DRUM_SILENT =      $16     ;10 and 11 will have a decay value applied to them.
DRUM_BEAT_7 =      $1A     ;
DRUM_BEAT_8 =      $1E     ;
DRUM_BEAT_9 =      $22     ;
DRUM_BEAT_10 =     $26     ;
DRUM_BEAT_11 =     $2A     ;

;DMC SFX index numbers.
DMC_CROWD =        $01     ;Crowd cheering, repeats.
DMC_LAUGH1 =       $02     ;Opponent laughing, style 1.
DMC_LAUGH2 =       $03     ;Opponent laughing, style 2.
DMC_LAUGH3 =       $04     ;Opponent laughing, style 3.
DMC_LAUGH4 =       $05     ;Opponent laughing, style 4.
DMC_LAUGH5 =       $06     ;Opponent laughing, style 5.
DMC_GRUNT =        $07     ;Opponent grunt when hit blocked.

;SQ1 SFX index numbers.
SQ1_INTRO_PUNCH =  $01     ;Punch SFX when start is pressed at intro.
SQ1_FALL =         $02     ;Opponent/player falls to the ground SFX.
SQ1_PUNCH1 =       $03     ;Opponent/player lands a punch SFX, version 1.
SQ1_PUNCH_BLOCK =  $04     ;Opponent/player blocks a punch SFX.
SQ1_OPP_PUNCH1 =   $05     ;Opponent punch SFX, vesrion 1.
SQ1_PUNCH_MISS1 =  $06     ;Little Mac misses a punch SFX, vesion 1.
SQ1_PUNCH_MISS2 =  $07     ;Little Mac misses a punch SFX, vesion 2.
SQ1_PUNCH2 =       $08     ;Little Mac lands a punch, version 2.
SQ1_TALK1 =        $09     ;Talking SFX, version 1.
SQ1_TALK2 =        $0A     ;Talking SFX, version 2.
SQ1_TALK3 =        $0B     ;Talking SFX, version 3.
SQ1_DIGIT1 =       $09     ;Beep SFX when password cursor is advanced (same as TALK1)
SQ1_DIGIT2 =       $0B     ;Beep SFX when password digits are changed (same as TALK3)
SQ1_BELL1 =        $0C     ;Single bell ring SFX.
SQ1_FIGHT =        $0D     ;Referee "Fight!" SFX.
SQ1_KO =           $0E     ;Referee "KO" SFX.
SQ1_TKO =          $0F     ;Referee "TKO" SFX.
SQ1_COUNT =        $10     ;Referee count SFX.
SQ1_DODGE =        $11     ;Little Mac dodge to one side SFX.
SQ1_BUSY =         $12     ;Busy signal SFX
SQ1_PUNCH3 =       $13     ;Opponent/player lands a punch SFX, version 3.
SQ1_BEEP =         $14     ;Beep SFX.
SQ1_BELL3 =        $15     ;3 bells SFX.
SQ1_STAR_PUNCH =   $16     ;Little Mac star punch wind up SFX.
SQ1_HIPPO_TALK =   $17     ;King Hippo talking SFX.
SQ1_HOLE_PUNCH =   $18     ;Glove punching a hole in the intro SFX.

;SQ2 SFX index numbers.
SQ2_INTRO_PUNCH =  $01     ;Punch SFX when start is pressed at intro.
SQ2_FALL =         $02     ;Opponent/player falls to the ground SFX.
SQ2_GET_STAR =     $03     ;Little Mac gets a star SFX.
SQ2_HONK1 =        $04     ;Opponent honk SFX, version 1.
SQ2_HONK2 =        $05     ;Opponent honk SFX, version 2.
SQ2_PUNCH1 =       $06     ;Little Mac lands a punch, version 1
SQ2_PUNCH2 =       $07     ;Little Mac lands a punch, version 2.
SQ2_OPP_PUNCH1 =   $08     ;Opponent punch SFX, version 1.
SQ2_OPP_PUNCH2 =   $09     ;Opponent punch SFX, version 2.
SQ2_OPP_PUNCH3 =   $0A     ;Opponent punch SFX, version 3.
SQ2_SPRING1 =      $0B     ;Opponent spring SFX, version 1.
SQ2_TAUNT =        $0C     ;Opponent taunt.
SQ2_OPP_PUNCH4 =   $0D     ;Opponent punch SFX, version 4.
SQ2_STUN1 =        $0E     ;Opponent stunned SFX, version 1.
SQ2_TIGER_PUNCH =  $0F     ;Great Tiger magic punch SFX.
SQ2_MAGIC =        $10     ;Great Tiger Dissapear SFX.
SQ2_FLEX =         $11     ;Mike Tyson muscle flex.
SQ2_MACHO_PUNCH =  $12     ;Super Macho Man super punch SFX.
SQ2_HIPPO_TALK =   $13     ;King Hippo talking SFX.
SQ2_WIND_UP =      $14     ;Opponent punch wind up SFX.
SQ2_SPRING2 =      $15     ;Opponent spring SFX, version 2.

;Music index numbers.
MUS_END =          $01     ;End music.
MUS_SHORT_INTRO =  $02     ;Short version of the intro music.
MUS_ATTRACT =      $03     ;Attract music.
MUS_NEWSPAPER =    $04     ;Music that plays newspaper is displayed.
MUS_CHAMP =        $05     ;Circuit champion music.
MUS_FIGHT_WIN =    $06     ;Fight win music.
MUS_FIGHT_LOSS =   $07     ;Fight loss music.
MUS_TITLE_BOUT =   $08     ;Title bout music.
MUS_GAME_OVER =    $09     ;Game over music.
MUS_PRE_FIGHT =    $0A     ;Pre-fight music.
MUS_NONE =         $0B     ;No music.
MUS_INTRO =        $0C     ;Intro music.
MUS_ATTRACT2 =     $0D     ;Attract music. Same as above.
MUS_DREAM_FIGHT =  $0E     ;Dream fight music.
MUS_NONE2 =        $0F     ;No music.
MUS_VON_KAISER =   $10     ;Von Kaiser/Macho Man intro music.
MUS_GLASS_JOE =    $11     ;Glass Joe intro music.
MUS_DON_FLAM =     $12     ;Don Flamenco intro music.
MUS_KING_HIPPO =   $13     ;King Hippo intro music.
MUS_SODA_POP =     $14     ;Soda popinski intro music.
MUS_PISTON_HON =   $15     ;Piston Honda intro music.
MUS_NONE3 =        $16     ;No music.
MUS_NONE4 =        $17     ;No music.
MUS_NONE5 =        $18     ;No music.
MUS_NONE6 =        $19     ;No music.
MUS_TRAIN_RPT =    $1A     ;Training music, repeats.
MUS_NONE7 =        $1B     ;No music.
MUS_NONE8 =        $1C     ;No music.
MUS_OPP_DOWN =     $1D     ;Opponent on the mat music.
MUS_MAC_DOWN =     $1E     ;Little Mac on the mat music.
MUS_FIGHT =        $1F     ;Main fight music.

;Game status.
ST_REF_MOVING =    $01     ;Indicates ref is moving on the screen.

;Little Mac status.
MAC_NO_FIGHT =     $00     ;Fight not running.
MAC_WAITING =      $01     ;Normal. Waiting for player input.
MAC_NO_HEARTS =    $02     ;No hearts.
MAC_DODGE_RIGHT =  $03     ;Dodging right.
MAC_DODGE_LEFT =   $05     ;Dodging left.
MAC_BLOCK =        $07     ;Blocking.
MAC_BLOCK_HIT =    $08     ;Blocking hit.
MAC_RP_LO =        $09     ;Right punching opponent's stomach.
MAC_LP_LO =        $0A     ;Left punching opponent's stomach.
MAC_RP_HI =        $0B     ;Right punching opponent's face.
MAC_LP_HI =        $0C     ;Left punching opponent's face.
MAC_SUPER_PUNCH =  $0D     ;Super punching opponent.
MAC_DUCK =         $0E     ;Ducking.
MAC_STUN_RIGHT =   $10     ;Little Mac stunned to the right.
MAC_STUN_LEFT =    $11     ;Little Mac stunned to the left.
MAC_PRE_WAIT =     $40     ;Pre-fight wait.
MAC_OPP_WAIT =     $41     ;Opponent down wait.
MAC_ROUND_WAIT =   $42     ;Round over.

;Opponent punch side of Little Mac.
MAC_LEFT_SIDE =    $00     ;Punch comming in on Little Mac's left side.
MAC_RIGHT_SIDE =   $01     ;Punch comming in on Little Mac's right side.

;Opponent state functions.
ST_SPRITES =       $00     ;Load sprite data for current opponent sub-state.
ST_SPRITES_XY =    $10     ;Load sprite data and XY position for current opponent sub-state.
ST_SPRT_MV_NU =    $60     ;Move opponent sprites with no animation update.
ST_SPRTS_MOVE =    $70     ;Move opponent animation around on the screen. -->
                                ;Bits 0,1=frames between movements, bits 2,3=number of movements.
ST_TIMER =         $80     ;Number of frames for sub-state to wait.
ST_SPRT_BIG_MV =   $A0     ;Move opponent around the screen large lengths.
ST_CALL_FUNC =     $E0     ;Call an opponent state subroutine.
ST_RETURN_FUNC =   $E1     ;Return from an opponent state subroutine.
ST_VAR_TIME =      $E4     ;Set opponent's state time to a varying amount.
ST_AUD_INIT =      $EC     ;Play a SFX/music.
ST_PNCH_ACTIVE =   $F0     ;Indicates an opponent's punch is active.
ST_JUMP =          $F1     ;Jump to new state base address and index.
ST_CHK_BRANCH =    $F2     ;Check memory for value and branch in state data if value found.
ST_CHK_REPEAT =    $F3     ;Check if a sub-state needs to repeat.
ST_WAIT_STATE =    $F4     ;Put opponent into wait state.
ST_REPEAT =        $F5     ;Load a repeat value for this sub-state.
ST_PUNCH_SIDE =    $F6     ;Indicate what side of Little Mac a punch is approaching.
ST_DEFENSE =       $F7     ;Load Opponent's defense from following 4 data bytes.
ST_PUNCH =         $F9     ;Indicate the opponent is punching.
ST_WRITE_BYTE =    $FA     ;Write a byte into zero page memory.
ST_SPEC_TIMER =    $FB     ;Load a special state timer value.
ST_COMBO_WAIT =    $FC     ;Wait for combo timer to expire.
ST_END =           $FF     ;Indicate the end of this state has been reached.

;Opponent state status.
STAT_NONE =        $00     ;Current state is not active.
STAT_ACTIVE =      $80     ;Current state is active.
STAT_FINISHED =    $83     ;Current state has finished.

;Opponent punch status.
PUNCH_NONE =       $00     ;No opponent punch being thrown.
PUNCH_BLOCKED =    $01     ;Punch blocked by Little Mac.
PUNCH_DUCKED =     $02     ;Punch is ducked by Little Mac.
PUNCH_LANDED =     $03     ;Punch hit Little Mac.
PUNCH_DODGED =     $04     ;Punch dodged by Little Mac.
PUNCH_ACTIVE =     $80     ;Punch is initialized.

;Controller bits.
IN_RIGHT =         $01     ;Right on the dpad.
IN_LEFT =          $02     ;Left on the dpad.
IN_DOWN =          $04     ;Down on the dpad.
IN_UP =            $08     ;Up on the dpad.
IN_START =         $10     ;Start button.
IN_SELECT =        $20     ;Select button.
IN_B =             $40     ;B button.
IN_A =             $80     ;A button.

;Nibble selection bit masks.
LO_NIBBLE =        $0F     ;Bitmask for lower nibble.
HI_NIBBLE =        $F0     ;Bitmask for upper nibble.

;Opponent state flags
OPP_CHNG_NONE =    $00     ;Done changing opponent sprites.
OPP_CHNG_POS =     $01     ;Move opponent's sprites on the screen.
OPP_CHNG_SPRT =    $80     ;Change opponent's sprites(Next animation sequence).
OPP_CHNG_BOTH =    $81     ;Change both position and sprites.
OPP_RGHT_HOOK =    $02     ;Indicate a right hook is being thrown.

;Misc. items.
NULL_PNTR =        $0000   ;Null pointer.
NO_ACTION =        $00     ;Idle memory byte.
SND_OFF =          $80     ;Silences sound channel.
PPU_LEFT_EN =      $06     ;Enable both left background column and left sprite column.
GAME_ENG_RUN =     $00     ;Enables the main game engine.
SPRT_BKG_OFF =     $80     ;Disable sprites and background.
SPRT_BKG_ON =      $81     ;Enable sprites and background.
PAL_UPDATE =       $81     ;Update palettes flag.

;Musical note indexes SQ1, SQ2.
SQ_C_2 =           $04     ;C2
SQ_C_SHARP_2 =     $06     ;C#2
SQ_D_2 =           $08     ;D2
SQ_D_SHARP_2 =     $0A     ;D#2
SQ_E_2 =           $0C     ;E2
SQ_F_2 =           $0E     ;F2
SQ_F_SHARP_2 =     $10     ;F#2
SQ_G_2 =           $12     ;G2
SQ_G_SHARP_2 =     $14     ;G#2
SQ_A_2 =           $16     ;A2
SQ_A_SHARP_2 =     $18     ;A#2
SQ_B_2 =           $1A     ;B2
SQ_C_3 =           $1C     ;C3
SQ_C_SHARP_3 =     $1E     ;C#3
SQ_D_3 =           $20     ;D3
SQ_D_SHARP_3 =     $22     ;D#3
SQ_E_3 =           $24     ;E3
SQ_F_3 =           $26     ;F3
SQ_F_SHARP_3 =     $28     ;F#3
SQ_G_3 =           $2A     ;G3
SQ_G_SHARP_3 =     $2C     ;G#3
SQ_A_3 =           $2E     ;A3
SQ_A_SHARP_3 =     $30     ;A#3
SQ_B_3 =           $32     ;B3
SQ_C_4 =           $34     ;C4
SQ_C_SHARP_4 =     $36     ;C#4
SQ_D_4 =           $38     ;D4
SQ_D_SHARP_4 =     $3A     ;D#4
SQ_E_4 =           $3C     ;E4
SQ_F_4 =           $3E     ;F4
SQ_F_SHARP_4 =     $40     ;F#4
SQ_G_4 =           $42     ;G4
SQ_G_SHARP_4 =     $44     ;G#4
SQ_A_4 =           $46     ;A4
SQ_A_SHARP_4 =     $48     ;A#4
SQ_B_4 =           $4A     ;B4
SQ_C_5 =           $4C     ;C5
SQ_C_SHARP_5 =     $4E     ;C#5
SQ_D_5 =           $50     ;D5
SQ_D_SHARP_5 =     $52     ;D#5
SQ_E_5 =           $54     ;E5
SQ_F_5 =           $56     ;F5
SQ_F_SHARP_5 =     $58     ;F#5
SQ_G_5 =           $5A     ;G5
SQ_G_SHARP_5 =     $5C     ;G#5
SQ_A_5 =           $5E     ;A5
SQ_A_SHARP_5 =     $60     ;A#5
SQ_B_5 =           $62     ;B5
SQ_C_6 =           $64     ;C6
SQ_C_SHARP_6 =     $66     ;C#6
SQ_D_6 =           $68     ;D6
SQ_D_SHARP_6 =     $6A     ;D#6
SQ_E_6 =           $6C     ;E6
SQ_F_6 =           $6E     ;F6
SQ_F_SHARP_6 =     $70     ;F#6
SQ_G_6 =           $72     ;G6
SQ_G_SHARP_6 =     $74     ;G#6
SQ_A_6 =           $76     ;A6
SQ_A_SHARP_6 =     $78     ;A#6
SQ_B_6 =           $7A     ;B6
SQ_C_7 =           $7C     ;C7
SQ_C_SHARP_7 =     $7E     ;C#7
