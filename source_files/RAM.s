;;; This file is used to generate `RAM.asm` using the script `helper_programs/update_ram.js`
.include "Globals.inc"

;-----------------------------------------[Variable Defines]-----------------------------------------
.zeropage

FightNumber :=      $01     ;The current fight number (0=GJ, 1=VK, 2=PH, ... 13=Tyson)
FightBank :=        $02     ;The memory bank containing the data for the current fight
FightOffset :=      $03     ;Offset of the current fight within its memory bank
KnockdownSts :=     $05     ;Knockdown status #$01=Opp down, #$02=Mac down
RoundNumber :=      $06     ;Current round number.
MacLosses :=        $0A     ;Number of losses on Mac's record
CurrPRGBank :=      $0D     ;The current PRG bank mapped to $8000-$9FFF
SavedPRGBank :=     $0E     ;The last PRG bank to be loaded

PPU0Load :=         $10     ;Value to load next into PPU control register 0.
PPU1Load :=         $11     ;Value to load next into PPU control register 1.

RNGValue :=         $18     ;Random number generator
InputAccum :=       $19     ;Controller 1 input accumulator

SprtBkgUpdt :=      $1B     ;MSB set=update sprite/background enable/disable.
                                ;#$80=Disable sprites and background.
                                ;#$81=Enable sprites and background.
GameEngStatus :=    $1C     ;0=Main game engine running, non-zero=Main game engine not running.
GameStatus :=       $1D     ;Enables/disables portions of the game.
                                ;#$00 - Main game engine running.
                                ;#$01 - Run game timers.
                                ;#$02 - Stop all game processing.
                                ;#$03 - Process only audio.
                                ;#$FF - Run non-playable portions of game(intro, cut scenes, etc).

FrameCounter :=     $1E     ;Increments every frame and rolls over when maxed out.
TransTimer :=       $1F     ;Countdown timer for various transitions.

CrowdCurState :=    $40     ;Crowd's current state. Set MSB=initialize new state.
CrowdStateStatus := $41     ;Status of Crowd's current state.
CrowdStateTimer :=  $42     ;Timer for Crowds current state.
CrowdStateIndex :=  $43     ;Index to Crowd current state data.
CrowdStBasePtr :=   $44     ;Pase pointer to Crowd's current state data.
CrowdStBasePtrLB := $44     ;Pase pointer to Crowd's current state data, lower byte.
CrowdStBasePtrUB := $45     ;Pase pointer to Crowd's current state data, upper byte.
CrowdStRptCntr :=   $46     ;Counter used to repeat the Crowd's current state.


ComboTimer :=       $4A     ;Frames left until another punch must be landed to keep combo alive.
ComboCountDown :=   $4B     ;Hits left in current combo.

MacStatus :=        $50     ;Status of Little Mac during a fight. MSB set=status update.
MacStateStatus :=   $51     ;Status of Mac's current state
MacStateTimer :=    $52     ;Timer for Mac's current state.
MacStateIndex :=    $53     ;Index to Mac's current state data.
MacStBasePtr :=     $54     ;Base pointer to Mac's current state data.
MacStBasePtrLB :=   $54     ;Base pointer to Mac's current state data, lower byte.
MacStBasePtrUB :=   $55     ;Base pointer to Mac's current state data, upper byte.
MacStateRptCntr :=  $56     ;Counter used to repeat Mac's current state.

MacPunchType :=     $74     ;Little Mac punch type.
                                ;#$00=Right punch to face.
                                ;#$01=Left punch to face.
                                ;#$02=Right punch to stomach.
                                ;#$03=Left punch to stomach.
                                ;#$80=Super punch.
MacPunchDamage :=   $75     ;The amount of damage Little Mac's puch will do to opponent.
MacDefense1 :=      $76     ;Little Mac's defense. there are 2 values but they are always -->
MacDefense2 :=      $77     ;written to the same value. Maybe there was plans for a left and -->
                                ;right defense? #$FF=Dodge, #$08=Block, #$80=Duck.

MacKDRound :=       $8F     ;How many times has Mac been knocked down this round?

OppCurState :=      $90     ;Opponent's current state. Set MSB=initialize new state.
OppStateStatus :=   $91     ;Status of opponent's current state.
OppStateTimer :=    $92     ;Timer for opponents current state.
OppStateIndex :=    $93     ;Index to opponent current state data.
OppStBasePtr :=     $94     ;Pase pointer to opponent's current state data.
OppStBasePtrLB :=   $94     ;Pase pointer to opponent's current state data, lower byte.
OppStBasePtrUB :=   $95     ;Pase pointer to opponent's current state data, upper byte.
OppStRepeatCntr :=  $96     ;Counter used to repeat the opponent's current state.
OppPunching :=      $97     ;#$00=Opponent not punching, #$01=Opponent punching.
OppPunchSts :=      $98     ;Same as OppLastPunchSts except #$80=punch active.

OppAnimSeg :=       $9A     ;Number of timed segments in opponent's current animation.
OppAnimSegTimer :=  $9B     ;Number of frames per segment in Opponent's animation.
OppOutlineTimer :=  $9C     ;Timer for dodge indicator outline color. MSB set=set timer.
OppIndexReturn :=   $9D     ;Restore value of OppStateIndex after function return.
OppPtrReturnLB :=   $9E     ;Restore value of OppStBasePtrLB after function return.
OppPtrReturnUB :=   $9F     ;Restore value of OppStBasePtrUB after function return.
OppAnimFlags :=     $A0     ;MSB set=Change opponent sprites, LSB set=Move opponent on screen.
OppBaseAnimIndex := $A1     ;Base animation index for opponent sprites.

OppBaseSprite :=    $B0     ;Base address for opponent sprite X,Y positions.
OppBaseXSprite :=   $B0     ;Base X position for opponent sprites.
OppBaseYSprite :=   $B1     ;Base Y position for opponent sprites.

OppPunchSide :=     $B4     ;#$00=Punching Little Mac's left side, #$01=Little Mac's right side.
OppPunchDamage :=   $B5     ;The amount of damage the current punch will do to Little Mac.
OppHitDefense :=    $B6     ;Base address to opponent defense to Little Mac's various punches.
OppHitDefenseUR :=  $B6     ;Amount to subtract from Little Mac right punch to face damage.
OppHitDefenseUL :=  $B7     ;Amount to subtract from Little Mac left punch to face damage.
OppHitDefenseLR :=  $B8     ;Amount to subtract from Little Mac right punch to stomach damage.
OppHitDefenseLL :=  $B9     ;Amount to subtract from Little Mac left punch to stomach damage.

GameStatusBB :=     $BB     ;Various game statuses.
                                ;#$00=No action.
                                ;#$01=Referee moving on screen.
                                ;#$02=Opponent throwing right hook.
                                ;#$03=Opponent getting up.
                                ;#$04=Opponent walking to Little Mac after knowck down.
                                ;#$80=Little Mac falling down.
                                ;#$FD=Freeze fight.
                                ;#$FF=Opponent victory dance.
MacCanPunch :=      $BC     ;#$00=Little Mac can't punch, #$01=Little Mac can punch.

OppLastPunchSts :=  $BD     ;Last punch status of opponent. See punch statuses below.

CurrentCount :=     $C2     ;Current referee count. #$9A=1 through #$A2=9.

OppGetUpCount :=    $C4     ;Count opponent will get up on. #$9A=1 through #$A2=9.

Joy1Buttons :=      $D0     ;Controller 1 button presses.
Joy2Buttons :=      $D1     ;Controller 2 button presses.

DPad1Status :=      $D2     ;Controller 1 dpad status.
Button1Status :=    $D2     ;Base for controller 1 button statuses.
DPad1History :=     $D3     ;Controller 1 dpad history.
Button1History :=   $D3     ;Base for controller 1 button histories.      -->
                                ;#$00=Not pressed.                            -->
                                ;#$01=Dpad not released since last change.    -->
                                ;#$81=Dpad/button first press since last release.

A1Status :=         $D4     ;Controller 1 A button status.
A1History :=        $D5     ;Controller 1 A button history.
B1Status :=         $D6     ;Controller 1 B button status.
B1History :=        $D7     ;Controller 1 B button history.
Strt1Status :=      $D8     ;Controller 1 start status.
Strt1History :=     $D9     ;Controller 1 start history.
Sel1Status :=       $DA     ;Controller 1 select button status.
Sel1History :=      $DB     ;Controller 1 select button history.

;-------------------------------------[General Purpose Variables]------------------------------------

GenByteE0 :=        $E0     ;General purpose byte.
GenPtrE0 :=         $E0     ;General use pointer.
GenPtrE0LB :=       $E0     ;General use pointer, lower byte.

GenByteE1 :=        $E1     ;General purpose byte.
GenPtrE0UB :=       $E1     ;General use pointer, upper byte.

IndJumpPtr :=       $EE     ;Pointer for indirect jump.
IndJumpPtrLB :=     $EE     ;Pointer for indirect jump, lower byte.
IndJumpPtrUB :=     $EF     ;Pointer for indirect jump, upper byte.

;--------------------------------------[Sound Engine Variables]--------------------------------------

SoundInitBase :=    $F0     ;Base address for sound initialization addresses below.
SFXInitSQ1 :=       $F0     ;The SFX index to be started that uses SQ1.
SFXInitSQ2 :=       $F1     ;The SFX index to be started that uses SQ2.
MusicInit :=        $F2     ;The music index to be started.
DMCInit :=          $F3     ;The DMC SFX index to be started.
SFXIndexSQ1 :=      $F4     ;The SFX currently being played that uses SQ1.
SFXIndexSQ2 :=      $F5     ;The SFX currently being played that uses SQ2.
MusicIndex :=       $F6     ;The music currently being played.
DMCIndex :=         $F7     ;The DMC SFX currently being played.
MusicDataPtr :=     $F8     ;Pointer base of music data.
MusicDataPtrLB :=   $F8     ;Pointer base of music data, lower byte.
MusicDataPtrUB :=   $F9     ;Pointer base of music data, upper byte.

SQ2NoteIndex :=     $FC     ;Index to current SQ2 musical note data.
SQ1NoteIndex :=     $FD     ;Index to current SQ1 musical note data.

.bss

SavedPasskey :=     $0110   ;To $0119 and $0120 to $0129. The first 10 bytes are password data
                                ;that after A+B+select were pressed. The second 10 bytes are normal
                                ;password data entered by the user.
PasskeyDigits :=    $0120

RoundTmrStart :=    $0300   ;Round timer started: 0=Not started, 1=Started, MSB=needs reset
RoundTmrCntrl :=    $0301   ;Round timer control. 0=running, 1=halt, 2=flash clock
RoundClock :=       $0301   ;Base address for clock values
RoundMinute :=      $0302   ;Current minute in round.
RoundColon :=       $0303   ;Colon tile pointer used to separate minutes from seconds.
RoundUpperSec :=    $0304   ;Current tens of seconds in round.
RoundLowerSec :=    $0305   ;Current second in round(base 10).

RoundTimerUB :=     $0306   ;Underlying timer behind round clock, upper byte
RoundTimerLB :=     $0307   ;Underlying timer behind round clock, lower byte
ClockRateUB :=      $0308   ;Rate that RoundTimer advances per frame, upper byte
ClockRateLB :=      $0309   ;Rate that RoundTimer advances per frame, lower byte

ClockDispStatus :=  $030A   ;Whether the clock display requires an update, MSB=needs update
ClockDisplay :=     $030B   ;Base address for clock display values
ClockDispMin :=     $030B   ;Clock digit index for minutes
ClockDispColon :=   $030C   ;Clock digit index for the colon
ClockDispSecUD :=   $030D   ;Clock digit index for tens of seconds
ClockDispSecLD :=   $030E   ;Clock digit index for seconds

NewHeartsUD :=      $0321   ;New amount of hearts, upper digit(base 10).
NewHeartsLD :=      $0322   ;New amount of hearts, lower digit(base 10).
CurHeartsUD :=      $0323   ;Current amount of hearts, upper digit(base 10).
CurHeartsLD :=      $0324   ;Current amount of hearts, lower digit(base 10).
HeartDispStatus :=  $0325   ;Hearts display status, MSB=needs update
HeartDisplayUD :=   $0326   ;Hearts display digit index, upper digit
HeartDisplayLD :=   $0327   ;Hearts display digit index, lower digit

HeartRecover :=     $032D   ;recover hearts this round, base address.
HeartNormRecUD :=   $032D   ;recover hearts this round, normal amount, upper digit(base 10).
HeartNormRecLD :=   $032E   ;recover hearts this round, normal amount, lower digit(base 10).
HeartNormRedUD :=   $032F   ;recover hearts this round, reduced amount, upper digit(base 10).
HeartNormRedLD :=   $0330   ;recover hearts this round, reduced amount, lower digit(base 10).

NumStars :=         $0342   ;Current number of stars Little Mac has.
IncStars :=         $0343   ;#$01=Increment number of stars.

StarCountDown :=    $0347   ;Must count down to 1 before stars will be given.

HealthPoints :=     $0390
MacNextHP :=        $0391   ;Next value to assign to Little Mac HP.
MacCurrentHP :=     $0392   ;Current vlaue of Little Mac's HP.
MacDisplayedHP :=   $0393   ;Displayed HP for Little Mac.

MacMaxHP :=         $0397   ;Max allowable HP for Little Mac.
OppHP :=            $0398   ;Base for HP opponent HP addresses below.
OppNextHP :=        $0398   ;Next value to assign to opponent's HP.
OppCurrentHP :=     $0399   ;Current value of opponents HP.
OppDisplayedHP :=   $039A   ;Displayed value of opponent's HP.

OppRefillIndex :=   $03C9   ;Index into the table of random opponent HP refills
OppKDRound :=       $03CA   ;Number of times opponent has been knocked down this round
SpecialKD :=        $03CB   ;Special knockdown condition

MacKDFight :=       $03D0   ;Number of times Mac has been knocked down in this fight
OppKDFight :=       $03D1   ;Number of times opponent has been knocked down this fight
LastPunchSts :=     $03D2   ;Who made the last punch? #$81=Mac #$82=Opp

SelectRefill :=     $03D9   ;Amount of HP refill Mac will receive from pushing select

PointsStatus :=     $03E0   ;Status of points
PointsNew :=        $03E1   ;New points that should be added to the total (base 10)
PointsTotal :=      $03E8   ;Total points for this round (base 10)

VRAMQueueStatus :=  $0410   ;Status of the VRAM queue
                            ;bit 7: set VRAM address increment to horizontal
                            ;This seems to hold either $81 or $00
VQAddressUB :=      $0411   ;VRAM address where queue bytes will be written (upper byte)
VQAddressLB :=      $0412   ;VRAM address where queue bytes will be written (lower byte)
VRAMQueueData :=    $0413   ;Base pointer for data to be copied into VRAM

ThisBkgPalette :=   $0480   ;Through $048F. Current background palette data.
ThisSprtPalette :=  $0490   ;Through $049F. Current sprite palette data.
UpdatePalFlag :=    $04A0   ;Non-zero value indicates the palettes need to be updated.

MessageID :=        $04B0   ;Current message being printed
LetterTimer :=      $04B1   ;Number of frames until the next character is printed
LetterIndex :=      $04B2   ;This is an index into the current message containing the next character
MessagePtr :=       $04B3   ;Pointer to the current text message

;Note: these are in big endian order
LinePosUB :=        $04B5   ;Position of the current text message line (Upper Byte).
LinePosLB :=        $04B6   ;Position of the current text message line (Lower Byte).

;Note: these are in big endian order
MessagePosUB :=     $04B7   ;Top left position of the current text message (Upper Byte)
MessagePosLB :=     $04B8   ;Top left position of the current text message (Lower Byte)

TalkingSFX :=       $04BD   ;Sound effect that plays while the text message is output

; ? :=        $04BE ; Next TrainerMessage to show
; ? :=        $04BF ; Next OppMessage to show

PasskeyStatus :=    $04C0   ;Pass key status...
PasskeyCursor :=    $04C1   ;Pass key cursor...
PasskeyModified :=  $04C2   ;Pass key modified...
DemoTimerSec :=     $04C6   ;Idle countdown timer to trigger demo from main menu (seconds, roughly)
DemoTimerFrac :=    $04C7   ;Idle countdown timer to trigger demo (fractional part, frames)
DatIndexTemp :=     $04C9   ;Temporary storage for data index.

VulnerableTimer :=  $04FD   ;Opponent is vunerable while counting down. Does not count on combos.

VariableStTime :=   $0581   ;A vaiable time for states. Usually decreases after being punched.

TimerVal0585 :=     $0585   ;A variable used to load special timer values.

HeartTable :=       $05A3   ;Table of heart values for this fight. (Indexing starts at 3)

StarCountReset :=   $05B0   ;Reset value for StarCountDown.

ReactTimer :=       $05B8   ;Opponents reaction time. Does not count on combos.

ComboDataPtrLB :=   $05C2   ;Pointer to combo data for the current opponent, lower byte
ComboDataPtrUB :=   $05C3   ;Pointer to combo data for the current opponent, upper byte

OppRefillPtr :=     $05D5   ;Pointer to beginning of table of random refill values
OppRefillPtrLB :=   $05D5   ;Pointer to random refill table, lower byte
OppRefillPtrUB :=   $05D6   ;Pointer to random refill table, upper byte
OppHPBoostCap :=    $05D7   ;Soft cap for HP boosts
ClockRateTable :=   $05D8   ;Table of values for this fight. (Indexing starts at 2)

OppGetUpTable :=    $05E0   ;Base address for opponent stand up times after knock down

OppOutline :=       $05EC   ;Base address for determining the opponent's outline color.

SelRefillPtrLB :=   $05EE   ;Pointer to refill table for pressing Select between rounds
SelRefillPtrUB :=   $05EF   ;Pointer to refill table for pressing Select between rounds

OppMessages :=      $05F0   ;Table of message indices for current opponent
TrainerMessages :=  $05F8   ;Table of message indices from trainer for this fight

JoyRawReads :=      $06A0   ;Through $06A8. Raw reads from controller 1 and 2. Even values -->
                                ;are from controller 1 while odd values are from controller 2. -->
                                ;The controllers are polled 4 times each per frame. Used to -->
                                ;DPCM conflict.


SQ2NoteRemain :=    $0700   ;The counter used for remaining SQ2 note time.
SQ1NoteRemain :=    $0701   ;The counter used for remaining SQ1 note time.
TriNoteRemain :=    $0702   ;The counter used for remaining triangle note time.
NoiseNoteRemain :=  $0703   ;The counter used for remaining noise note time.
SQ2NoteLength :=    $0704   ;The total length of the of the current SQ2 note.
SQ1NoteLength :=    $0705   ;The total length of the of the current SQ1 note.
TriNoteLength :=    $0706   ;The total length of the of the current triangle note.
NoiseNoteLength :=  $0707   ;The total length of the of the current noise note.
SQ2EnvIndex :=      $0708   ;The current index to SQ2 envelope data while playing music.
SQ1EnvIndex :=      $0709   ;The current index to SQ1 envelope data while playing music.
MusSeqBase :=       $070A   ;Base index for finding music sequence data.
MusSeqIndex :=      $070B   ;Current index for finding music sequence data.
NoiseIndexReload := $070C   ;Reload address to repeat drum beatsin song background.
NoteLengthsBase :=  $070D   ;Base index for note lengths for a given piece of music.
SQ1SweepCntrl :=    $070E   ;Control byte for SQ1 sweep hardware.
SQ1LoFreqBits :=    $070F   ;Lower frequency bits of SQ0.
SQ2LoFreqBits :=    $0710   ;Lower frequency bits of SQ2.

;$0711

SQ1SFXTimer :=      $0712   ;Length timer for SQ1 SFX.
SQ1SFXByte :=       $0713   ;Multi purpose register for SQ1 SFX.

SQ2SFXTimer :=      $0715   ;Length timer for SQ2 SFX.
SQ2SFXByte1 :=      $0716   ;Multi purpose register for SQ2 SFX.
SQ2SFXByte2 :=      $0717   ;Multi purpose register for SQ2 SFX.
SQ2ShortPause :=    $0718   ;Creates a short 2 frame pause in SQ2 music.
SQ1ShortPause :=    $0719   ;Creates a short 2 frame pause in SQ1 music.
SQ2RestartFlag :=   $071A   ;Flag indicating SQ2 music needs to resume after SFX completes.
SQ1RestartFlag :=   $071B   ;Flag indicating SQ1 music needs to resume after SFX completes.
SQ2EnvBase :=       $071C   ;Base index for SQ2 envelope data while playing music.
SQ1EnvBase :=       $071D   ;Base index for SQ1 envelope data while playing music.

;These registers are used for the timing with the DMC laugh SFX. $071E is the time between
;laughs while $071F is the time of the audible portion of the laugh. Each laugh has a small
;silence between them.

DMCLaughLength :=   $071E   ;Time remaining until next laugh starts.
DMCLghAudLength :=  $071F   ;Auduble time remaining in this laugh segment.
NoiseVolIndex :=    $0720   ;Index to noise channel control byte for volume/envelope.
NoiseBeatType :=    $0721   ;If drum beat is type 10 or 11, decay will be applied.
TriNoteIndex :=     $0722   ;Index to current triangle musical note data.
NoiseMusicIndex :=  $0723   ;Index to current noise music data.
NoiseInUse :=       $0724   ;Non-zero indicates an SFX is using the noise channel.
SQ2InUse :=         $0725   ;Non-zero indicates an SFX is using the SQ2 channel.
SQ1InUse :=         $0726   ;Non-zero indicates an SFX is using the SQ1 channel.

;$0728
;$0729

;These register functionalities are hard to explain. When the intro or Piston Honda's intro
;music are playing, a special situation exists where the triangle channel needs to turn off
;before the note length expires. This leaves gaps where the triangle channel does not play.
;Let's call this a "blip". There are 3 situations where special processing is considered:
;  1)If triangle note length > #$09 frames, blib occurs 5 frames before note timer end.
;  2)If #$09 >= triangle note length > #$07, blib occurs in the middle of the note timer.
;  3)if triangle note length <= #$07, a blip occurs 2 frames after the note timer start.
;Registers $072A and $072B keep track of the timing values for the blips. Register $072C determines
;which blip type to use based on initial note length.

TriMidBlip :=       $072A   ;Loaded with 1/2 of Triangle note counter.
TriFrontBlip :=     $072B   ;Loaded with triangle note counter - 2.
TriBlipType :=      $072C   ;#$00=Front half blip, #$01=Mid way blip, #$02=Back half blip.

;-------------------------------------[Hardware Registers]-------------------------------------------

.segment "REGISTERS"

PPUControl0 :=      $2000   ;
PPUControl1 :=      $2001   ;
PPUStatus :=        $2002   ;
SPRAddress :=       $2003   ;PPU hardware control registers.
SPRIOReg :=         $2004   ;
PPUScroll :=        $2005   ;
PPUAddress :=       $2006   ;
PPUIOReg :=         $2007   ;

SQ1Cntrl0 :=        $4000   ;
SQ1Cntrl1 :=        $4001   ;SQ1 hardware control registers.
SQ1Cntrl2 :=        $4002   ;
SQ1Cntrl3 :=        $4003   ;

SQ2Cntrl0 :=        $4004   ;
SQ2Cntrl1 :=        $4005   ;SQ2 hardware control registers.
SQ2Cntrl2 :=        $4006   ;
SQ2Cntrl3 :=        $4007   ;

TriangleCntrl0 :=   $4008   ;
TriangleCntrl1 :=   $4009   ;Triangle hardware control registers.
TriangleCntrl2 :=   $400A   ;
TriangleCntrl3 :=   $400B   ;

NoiseCntrl0 :=      $400C   ;
NoiseCntrl1 :=      $400D   ;Noise hardware control registers.
NoiseCntrl2 :=      $400E   ;
NoiseCntrl3 :=      $400F   ;

DMCCntrl0 :=        $4010   ;
DMCCntrl1 :=        $4011   ;DMC hardware control registers.
DMCCntrl2 :=        $4012   ;
DMCCntrl3 :=        $4013   ;

SPRDMAReg :=        $4014   ;Sprite RAM DMA register.
APUCommonCntrl0 :=  $4015   ;APU common control 1 register.
CPUJoyPad1 :=       $4016   ;Joypad1 register.
APUCommonCntrl1 :=  $4017   ;Joypad2/APU common control 2 register.
