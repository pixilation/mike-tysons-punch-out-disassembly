;This file has been generated from `RAM.s` using the script `helper_programs/update_ram.js`
.include "Globals.inc"

;-----------------------------------------[Variable Defines]-----------------------------------------
.zeropage

                    .res 1  ;($00)
FightNumber:        .res 1  ;($01) The current fight number (0=GJ, 1=VK, 2=PH, ... 13=Tyson)
FightBank:          .res 1  ;($02) The memory bank containing the data for the current fight
FightOffset:        .res 1  ;($03) Offset of the current fight within its memory bank
                    .res 1  ;($04)
KnockdownSts:       .res 1  ;($05) Knockdown status #$01=Opp down, #$02=Mac down
RoundNumber:        .res 1  ;($06) Current round number.
                    .res 3  ;($07)
MacLosses:          .res 1  ;($0A) Number of losses on Mac's record
                    .res 2  ;($0B)
CurrPRGBank:        .res 1  ;($0D) The current PRG bank mapped to $8000-$9FFF
SavedPRGBank:       .res 1  ;($0E) The last PRG bank to be loaded

                    .res 1  ;($0F)
PPU0Load:           .res 1  ;($10) Value to load next into PPU control register 0.
PPU1Load:           .res 1  ;($11) Value to load next into PPU control register 1.

                    .res 6  ;($12)
RNGValue:           .res 1  ;($18) Random number generator
InputAccum:         .res 1  ;($19) Controller 1 input accumulator

                    .res 1  ;($1A)
SprtBkgUpdt:        .res 1  ;($1B) MSB set=update sprite/background enable/disable.
                                ;#$80=Disable sprites and background.
                                ;#$81=Enable sprites and background.
GameEngStatus:      .res 1  ;($1C) 0=Main game engine running, non-zero=Main game engine not running.
GameStatus:         .res 1  ;($1D) Enables/disables portions of the game.
                                ;#$00 - Main game engine running.
                                ;#$01 - Run game timers.
                                ;#$02 - Stop all game processing.
                                ;#$03 - Process only audio.
                                ;#$FF - Run non-playable portions of game(intro, cut scenes, etc).

FrameCounter:       .res 1  ;($1E) Increments every frame and rolls over when maxed out.
TransTimer:         .res 1  ;($1F) Countdown timer for various transitions.

                    .res 32  ;($20)
CrowdCurState:      .res 1  ;($40) Crowd's current state. Set MSB=initialize new state.
CrowdStateStatus:   .res 1  ;($41) Status of Crowd's current state.
CrowdStateTimer:    .res 1  ;($42) Timer for Crowds current state.
CrowdStateIndex:    .res 1  ;($43) Index to Crowd current state data.
CrowdStBasePtr:             ;Pase pointer to Crowd's current state data.
CrowdStBasePtrLB:   .res 1  ;($44) Pase pointer to Crowd's current state data, lower byte.
CrowdStBasePtrUB:   .res 1  ;($45) Pase pointer to Crowd's current state data, upper byte.
CrowdStRptCntr:     .res 1  ;($46) Counter used to repeat the Crowd's current state.


                    .res 3  ;($47)
ComboTimer:         .res 1  ;($4A) Frames left until another punch must be landed to keep combo alive.
ComboCountDown:     .res 1  ;($4B) Hits left in current combo.

                    .res 4  ;($4C)
MacStatus:          .res 1  ;($50) Status of Little Mac during a fight. MSB set=status update.
MacStateStatus:     .res 1  ;($51) Status of Mac's current state
MacStateTimer:      .res 1  ;($52) Timer for Mac's current state.
MacStateIndex:      .res 1  ;($53) Index to Mac's current state data.
MacStBasePtr:               ;Base pointer to Mac's current state data.
MacStBasePtrLB:     .res 1  ;($54) Base pointer to Mac's current state data, lower byte.
MacStBasePtrUB:     .res 1  ;($55) Base pointer to Mac's current state data, upper byte.
MacStateRptCntr:    .res 1  ;($56) Counter used to repeat Mac's current state.

                    .res 29  ;($57)
MacPunchType:       .res 1  ;($74) Little Mac punch type.
                                ;#$00=Right punch to face.
                                ;#$01=Left punch to face.
                                ;#$02=Right punch to stomach.
                                ;#$03=Left punch to stomach.
                                ;#$80=Super punch.
MacPunchDamage:     .res 1  ;($75) The amount of damage Little Mac's puch will do to opponent.
MacDefense1:        .res 1  ;($76) Little Mac's defense. there are 2 values but they are always -->
MacDefense2:        .res 1  ;($77) written to the same value. Maybe there was plans for a left and -->
                                ;right defense? #$FF=Dodge, #$08=Block, #$80=Duck.

                    .res 23  ;($78)
MacKDRound:         .res 1  ;($8F) How many times has Mac been knocked down this round?

OppCurState:        .res 1  ;($90) Opponent's current state. Set MSB=initialize new state.
OppStateStatus:     .res 1  ;($91) Status of opponent's current state.
OppStateTimer:      .res 1  ;($92) Timer for opponents current state.
OppStateIndex:      .res 1  ;($93) Index to opponent current state data.
OppStBasePtr:               ;Pase pointer to opponent's current state data.
OppStBasePtrLB:     .res 1  ;($94) Pase pointer to opponent's current state data, lower byte.
OppStBasePtrUB:     .res 1  ;($95) Pase pointer to opponent's current state data, upper byte.
OppStRepeatCntr:    .res 1  ;($96) Counter used to repeat the opponent's current state.
OppPunching:        .res 1  ;($97) #$00=Opponent not punching, #$01=Opponent punching.
OppPunchSts:        .res 1  ;($98) Same as OppLastPunchSts except #$80=punch active.

                    .res 1  ;($99)
OppAnimSeg:         .res 1  ;($9A) Number of timed segments in opponent's current animation.
OppAnimSegTimer:    .res 1  ;($9B) Number of frames per segment in Opponent's animation.
OppOutlineTimer:    .res 1  ;($9C) Timer for dodge indicator outline color. MSB set=set timer.
OppIndexReturn:     .res 1  ;($9D) Restore value of OppStateIndex after function return.
OppPtrReturnLB:     .res 1  ;($9E) Restore value of OppStBasePtrLB after function return.
OppPtrReturnUB:     .res 1  ;($9F) Restore value of OppStBasePtrUB after function return.
OppAnimFlags:       .res 1  ;($A0) MSB set=Change opponent sprites, LSB set=Move opponent on screen.
OppBaseAnimIndex:   .res 1  ;($A1) Base animation index for opponent sprites.

                    .res 14  ;($A2)
OppBaseSprite:              ;Base address for opponent sprite X,Y positions.
OppBaseXSprite:     .res 1  ;($B0) Base X position for opponent sprites.
OppBaseYSprite:     .res 1  ;($B1) Base Y position for opponent sprites.

                    .res 2  ;($B2)
OppPunchSide:       .res 1  ;($B4) #$00=Punching Little Mac's left side, #$01=Little Mac's right side.
OppPunchDamage:     .res 1  ;($B5) The amount of damage the current punch will do to Little Mac.
OppHitDefense:              ;Base address to opponent defense to Little Mac's various punches.
OppHitDefenseUR:    .res 1  ;($B6) Amount to subtract from Little Mac right punch to face damage.
OppHitDefenseUL:    .res 1  ;($B7) Amount to subtract from Little Mac left punch to face damage.
OppHitDefenseLR:    .res 1  ;($B8) Amount to subtract from Little Mac right punch to stomach damage.
OppHitDefenseLL:    .res 1  ;($B9) Amount to subtract from Little Mac left punch to stomach damage.

                    .res 1  ;($BA)
GameStatusBB:       .res 1  ;($BB) Various game statuses.
                                ;#$00=No action.
                                ;#$01=Referee moving on screen.
                                ;#$02=Opponent throwing right hook.
                                ;#$03=Opponent getting up.
                                ;#$04=Opponent walking to Little Mac after knowck down.
                                ;#$80=Little Mac falling down.
                                ;#$FD=Freeze fight.
                                ;#$FF=Opponent victory dance.
MacCanPunch:        .res 1  ;($BC) #$00=Little Mac can't punch, #$01=Little Mac can punch.

OppLastPunchSts:    .res 1  ;($BD) Last punch status of opponent. See punch statuses below.

                    .res 4  ;($BE)
CurrentCount:       .res 1  ;($C2) Current referee count. #$9A=1 through #$A2=9.

                    .res 1  ;($C3)
OppGetUpCount:      .res 1  ;($C4) Count opponent will get up on. #$9A=1 through #$A2=9.

                    .res 11  ;($C5)
Joy1Buttons:        .res 1  ;($D0) Controller 1 button presses.
Joy2Buttons:        .res 1  ;($D1) Controller 2 button presses.

DPad1Status:                ;Controller 1 dpad status.
Button1Status:      .res 1  ;($D2) Base for controller 1 button statuses.
DPad1History:               ;Controller 1 dpad history.
Button1History:     .res 1  ;($D3) Base for controller 1 button histories.      -->
                                ;#$00=Not pressed.                            -->
                                ;#$01=Dpad not released since last change.    -->
                                ;#$81=Dpad/button first press since last release.

A1Status:           .res 1  ;($D4) Controller 1 A button status.
A1History:          .res 1  ;($D5) Controller 1 A button history.
B1Status:           .res 1  ;($D6) Controller 1 B button status.
B1History:          .res 1  ;($D7) Controller 1 B button history.
Strt1Status:        .res 1  ;($D8) Controller 1 start status.
Strt1History:       .res 1  ;($D9) Controller 1 start history.
Sel1Status:         .res 1  ;($DA) Controller 1 select button status.
Sel1History:        .res 1  ;($DB) Controller 1 select button history.

;-------------------------------------[General Purpose Variables]------------------------------------

                    .res 4  ;($DC)
GenByteE0:                  ;General purpose byte.
GenPtrE0:                   ;General use pointer.
GenPtrE0LB:         .res 1  ;($E0) General use pointer, lower byte.

GenByteE1:                  ;General purpose byte.
GenPtrE0UB:         .res 1  ;($E1) General use pointer, upper byte.

                    .res 12  ;($E2)
IndJumpPtr:                 ;Pointer for indirect jump.
IndJumpPtrLB:       .res 1  ;($EE) Pointer for indirect jump, lower byte.
IndJumpPtrUB:       .res 1  ;($EF) Pointer for indirect jump, upper byte.

;--------------------------------------[Sound Engine Variables]--------------------------------------

SoundInitBase:              ;Base address for sound initialization addresses below.
SFXInitSQ1:         .res 1  ;($F0) The SFX index to be started that uses SQ1.
SFXInitSQ2:         .res 1  ;($F1) The SFX index to be started that uses SQ2.
MusicInit:          .res 1  ;($F2) The music index to be started.
DMCInit:            .res 1  ;($F3) The DMC SFX index to be started.
SFXIndexSQ1:        .res 1  ;($F4) The SFX currently being played that uses SQ1.
SFXIndexSQ2:        .res 1  ;($F5) The SFX currently being played that uses SQ2.
MusicIndex:         .res 1  ;($F6) The music currently being played.
DMCIndex:           .res 1  ;($F7) The DMC SFX currently being played.
MusicDataPtr:               ;Pointer base of music data.
MusicDataPtrLB:     .res 1  ;($F8) Pointer base of music data, lower byte.
MusicDataPtrUB:     .res 1  ;($F9) Pointer base of music data, upper byte.

                    .res 2  ;($FA)
SQ2NoteIndex:       .res 1  ;($FC) Index to current SQ2 musical note data.
SQ1NoteIndex:       .res 1  ;($FD) Index to current SQ1 musical note data.

.bss

                    .res 16  ;($100)
SavedPasskey:       .res 1  ;($110) To $0119 and $0120 to $0129. The first 10 bytes are password data
                                ;that after A+B+select were pressed. The second 10 bytes are normal
                                ;password data entered by the user.
                    .res 15  ;($111)
PasskeyDigits:      .res 1  ;($120)

                    .res 479  ;($121)
RoundTmrStart:      .res 1  ;($300) Round timer started: 0=Not started, 1=Started, MSB=needs reset
RoundTmrCntrl:              ;Round timer control. 0=running, 1=halt, 2=flash clock
RoundClock:         .res 1  ;($301) Base address for clock values
RoundMinute:        .res 1  ;($302) Current minute in round.
RoundColon:         .res 1  ;($303) Colon tile pointer used to separate minutes from seconds.
RoundUpperSec:      .res 1  ;($304) Current tens of seconds in round.
RoundLowerSec:      .res 1  ;($305) Current second in round(base 10).

RoundTimerUB:       .res 1  ;($306) Underlying timer behind round clock, upper byte
RoundTimerLB:       .res 1  ;($307) Underlying timer behind round clock, lower byte
ClockRateUB:        .res 1  ;($308) Rate that RoundTimer advances per frame, upper byte
ClockRateLB:        .res 1  ;($309) Rate that RoundTimer advances per frame, lower byte

ClockDispStatus:    .res 1  ;($30A) Whether the clock display requires an update, MSB=needs update
ClockDisplay:               ;Base address for clock display values
ClockDispMin:       .res 1  ;($30B) Clock digit index for minutes
ClockDispColon:     .res 1  ;($30C) Clock digit index for the colon
ClockDispSecUD:     .res 1  ;($30D) Clock digit index for tens of seconds
ClockDispSecLD:     .res 1  ;($30E) Clock digit index for seconds

                    .res 18  ;($30F)
NewHeartsUD:        .res 1  ;($321) New amount of hearts, upper digit(base 10).
NewHeartsLD:        .res 1  ;($322) New amount of hearts, lower digit(base 10).
CurHeartsUD:        .res 1  ;($323) Current amount of hearts, upper digit(base 10).
CurHeartsLD:        .res 1  ;($324) Current amount of hearts, lower digit(base 10).
HeartDispStatus:    .res 1  ;($325) Hearts display status, MSB=needs update
HeartDisplayUD:     .res 1  ;($326) Hearts display digit index, upper digit
HeartDisplayLD:     .res 1  ;($327) Hearts display digit index, lower digit

                    .res 5  ;($328)
HeartRecover:               ;recover hearts this round, base address.
HeartNormRecUD:     .res 1  ;($32D) recover hearts this round, normal amount, upper digit(base 10).
HeartNormRecLD:     .res 1  ;($32E) recover hearts this round, normal amount, lower digit(base 10).
HeartNormRedUD:     .res 1  ;($32F) recover hearts this round, reduced amount, upper digit(base 10).
HeartNormRedLD:     .res 1  ;($330) recover hearts this round, reduced amount, lower digit(base 10).

                    .res 17  ;($331)
NumStars:           .res 1  ;($342) Current number of stars Little Mac has.
IncStars:           .res 1  ;($343) #$01=Increment number of stars.

                    .res 3  ;($344)
StarCountDown:      .res 1  ;($347) Must count down to 1 before stars will be given.

                    .res 72  ;($348)
HealthPoints:       .res 1  ;($390)
MacNextHP:          .res 1  ;($391) Next value to assign to Little Mac HP.
MacCurrentHP:       .res 1  ;($392) Current vlaue of Little Mac's HP.
MacDisplayedHP:     .res 1  ;($393) Displayed HP for Little Mac.

                    .res 3  ;($394)
MacMaxHP:           .res 1  ;($397) Max allowable HP for Little Mac.
OppHP:                      ;Base for HP opponent HP addresses below.
OppNextHP:          .res 1  ;($398) Next value to assign to opponent's HP.
OppCurrentHP:       .res 1  ;($399) Current value of opponents HP.
OppDisplayedHP:     .res 1  ;($39A) Displayed value of opponent's HP.

                    .res 46  ;($39B)
OppRefillIndex:     .res 1  ;($3C9) Index into the table of random opponent HP refills
OppKDRound:         .res 1  ;($3CA) Number of times opponent has been knocked down this round
SpecialKD:          .res 1  ;($3CB) Special knockdown condition

                    .res 4  ;($3CC)
MacKDFight:         .res 1  ;($3D0) Number of times Mac has been knocked down in this fight
OppKDFight:         .res 1  ;($3D1) Number of times opponent has been knocked down this fight
LastPunchSts:       .res 1  ;($3D2) Who made the last punch? #$81=Mac #$82=Opp

                    .res 6  ;($3D3)
SelectRefill:       .res 1  ;($3D9) Amount of HP refill Mac will receive from pushing select

                    .res 6  ;($3DA)
PointsStatus:       .res 1  ;($3E0) Status of points
PointsNew:          .res 1  ;($3E1) New points that should be added to the total (base 10)
                    .res 6  ;($3E2)
PointsTotal:        .res 1  ;($3E8) Total points for this round (base 10)

                    .res 39  ;($3E9)
VRAMQueueStatus:    .res 1  ;($410) Status of the VRAM queue
                            ;bit 7: set VRAM address increment to horizontal
                            ;This seems to hold either $81 or $00
VQAddressUB:        .res 1  ;($411) VRAM address where queue bytes will be written (upper byte)
VQAddressLB:        .res 1  ;($412) VRAM address where queue bytes will be written (lower byte)
VRAMQueueData:      .res 1  ;($413) Base pointer for data to be copied into VRAM

                    .res 108  ;($414)
ThisBkgPalette:     .res 1  ;($480) Through $048F. Current background palette data.
                    .res 15  ;($481)
ThisSprtPalette:    .res 1  ;($490) Through $049F. Current sprite palette data.
                    .res 15  ;($491)
UpdatePalFlag:      .res 1  ;($4A0) Non-zero value indicates the palettes need to be updated.

                    .res 15  ;($4A1)
MessageID:          .res 1  ;($4B0) Current message being printed
LetterTimer:        .res 1  ;($4B1) Number of frames until the next character is printed
LetterIndex:        .res 1  ;($4B2) This is an index into the current message containing the next character
MessagePtr:         .res 2  ;($4B3) Pointer to the current text message

;Note: these are in big endian order
LinePosUB:          .res 1  ;($4B5) Position of the current text message line (Upper Byte).
LinePosLB:          .res 1  ;($4B6) Position of the current text message line (Lower Byte).

;Note: these are in big endian order
MessagePosUB:       .res 1  ;($4B7) Top left position of the current text message (Upper Byte)
MessagePosLB:       .res 1  ;($4B8) Top left position of the current text message (Lower Byte)

                    .res 4  ;($4B9)
TalkingSFX:         .res 1  ;($4BD) Sound effect that plays while the text message is output

; ? :=        $04BE ; Next TrainerMessage to show
; ? :=        $04BF ; Next OppMessage to show

                    .res 2  ;($4BE)
PasskeyStatus:      .res 1  ;($4C0) Pass key status...
PasskeyCursor:      .res 1  ;($4C1) Pass key cursor...
PasskeyModified:    .res 1  ;($4C2) Pass key modified...
                    .res 3  ;($4C3)
DemoTimerSec:       .res 1  ;($4C6) Idle countdown timer to trigger demo from main menu (seconds, roughly)
DemoTimerFrac:      .res 1  ;($4C7) Idle countdown timer to trigger demo (fractional part, frames)
                    .res 1  ;($4C8)
DatIndexTemp:       .res 1  ;($4C9) Temporary storage for data index.

                    .res 51  ;($4CA)
VulnerableTimer:    .res 1  ;($4FD) Opponent is vunerable while counting down. Does not count on combos.

                    .res 131  ;($4FE)
VariableStTime:     .res 1  ;($581) A vaiable time for states. Usually decreases after being punched.

                    .res 3  ;($582)
TimerVal0585:       .res 1  ;($585) A variable used to load special timer values.

                    .res 29  ;($586)
HeartTable:         .res 1  ;($5A3) Table of heart values for this fight. (Indexing starts at 3)

                    .res 12  ;($5A4)
StarCountReset:     .res 1  ;($5B0) Reset value for StarCountDown.

                    .res 7  ;($5B1)
ReactTimer:         .res 1  ;($5B8) Opponents reaction time. Does not count on combos.

                    .res 9  ;($5B9)
ComboDataPtrLB:     .res 1  ;($5C2) Pointer to combo data for the current opponent, lower byte
ComboDataPtrUB:     .res 1  ;($5C3) Pointer to combo data for the current opponent, upper byte

                    .res 17  ;($5C4)
OppRefillPtr:               ;Pointer to beginning of table of random refill values
OppRefillPtrLB:     .res 1  ;($5D5) Pointer to random refill table, lower byte
OppRefillPtrUB:     .res 1  ;($5D6) Pointer to random refill table, upper byte
OppHPBoostCap:      .res 1  ;($5D7) Soft cap for HP boosts
ClockRateTable:     .res 1  ;($5D8) Table of values for this fight. (Indexing starts at 2)

                    .res 7  ;($5D9)
OppGetUpTable:      .res 1  ;($5E0) Base address for opponent stand up times after knock down

                    .res 11  ;($5E1)
OppOutline:         .res 1  ;($5EC) Base address for determining the opponent's outline color.

                    .res 1  ;($5ED)
SelRefillPtrLB:     .res 1  ;($5EE) Pointer to refill table for pressing Select between rounds
SelRefillPtrUB:     .res 1  ;($5EF) Pointer to refill table for pressing Select between rounds

OppMessages:        .res 1  ;($5F0) Table of message indices for current opponent
                    .res 7  ;($5F1)
TrainerMessages:    .res 1  ;($5F8) Table of message indices from trainer for this fight

                    .res 167  ;($5F9)
JoyRawReads:        .res 1  ;($6A0) Through $06A8. Raw reads from controller 1 and 2. Even values -->
                                ;are from controller 1 while odd values are from controller 2. -->
                                ;The controllers are polled 4 times each per frame. Used to -->
                                ;DPCM conflict.


                    .res 95  ;($6A1)
SQ2NoteRemain:      .res 1  ;($700) The counter used for remaining SQ2 note time.
SQ1NoteRemain:      .res 1  ;($701) The counter used for remaining SQ1 note time.
TriNoteRemain:      .res 1  ;($702) The counter used for remaining triangle note time.
NoiseNoteRemain:    .res 1  ;($703) The counter used for remaining noise note time.
SQ2NoteLength:      .res 1  ;($704) The total length of the of the current SQ2 note.
SQ1NoteLength:      .res 1  ;($705) The total length of the of the current SQ1 note.
TriNoteLength:      .res 1  ;($706) The total length of the of the current triangle note.
NoiseNoteLength:    .res 1  ;($707) The total length of the of the current noise note.
SQ2EnvIndex:        .res 1  ;($708) The current index to SQ2 envelope data while playing music.
SQ1EnvIndex:        .res 1  ;($709) The current index to SQ1 envelope data while playing music.
MusSeqBase:         .res 1  ;($70A) Base index for finding music sequence data.
MusSeqIndex:        .res 1  ;($70B) Current index for finding music sequence data.
NoiseIndexReload:   .res 1  ;($70C) Reload address to repeat drum beatsin song background.
NoteLengthsBase:    .res 1  ;($70D) Base index for note lengths for a given piece of music.
SQ1SweepCntrl:      .res 1  ;($70E) Control byte for SQ1 sweep hardware.
SQ1LoFreqBits:      .res 1  ;($70F) Lower frequency bits of SQ0.
SQ2LoFreqBits:      .res 1  ;($710) Lower frequency bits of SQ2.

;$0711

                    .res 1  ;($711)
SQ1SFXTimer:        .res 1  ;($712) Length timer for SQ1 SFX.
SQ1SFXByte:         .res 1  ;($713) Multi purpose register for SQ1 SFX.

                    .res 1  ;($714)
SQ2SFXTimer:        .res 1  ;($715) Length timer for SQ2 SFX.
SQ2SFXByte1:        .res 1  ;($716) Multi purpose register for SQ2 SFX.
SQ2SFXByte2:        .res 1  ;($717) Multi purpose register for SQ2 SFX.
SQ2ShortPause:      .res 1  ;($718) Creates a short 2 frame pause in SQ2 music.
SQ1ShortPause:      .res 1  ;($719) Creates a short 2 frame pause in SQ1 music.
SQ2RestartFlag:     .res 1  ;($71A) Flag indicating SQ2 music needs to resume after SFX completes.
SQ1RestartFlag:     .res 1  ;($71B) Flag indicating SQ1 music needs to resume after SFX completes.
SQ2EnvBase:         .res 1  ;($71C) Base index for SQ2 envelope data while playing music.
SQ1EnvBase:         .res 1  ;($71D) Base index for SQ1 envelope data while playing music.

;These registers are used for the timing with the DMC laugh SFX. $071E is the time between
;laughs while $071F is the time of the audible portion of the laugh. Each laugh has a small
;silence between them.

DMCLaughLength:     .res 1  ;($71E) Time remaining until next laugh starts.
DMCLghAudLength:    .res 1  ;($71F) Auduble time remaining in this laugh segment.
NoiseVolIndex:      .res 1  ;($720) Index to noise channel control byte for volume/envelope.
NoiseBeatType:      .res 1  ;($721) If drum beat is type 10 or 11, decay will be applied.
TriNoteIndex:       .res 1  ;($722) Index to current triangle musical note data.
NoiseMusicIndex:    .res 1  ;($723) Index to current noise music data.
NoiseInUse:         .res 1  ;($724) Non-zero indicates an SFX is using the noise channel.
SQ2InUse:           .res 1  ;($725) Non-zero indicates an SFX is using the SQ2 channel.
SQ1InUse:           .res 1  ;($726) Non-zero indicates an SFX is using the SQ1 channel.

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

                    .res 3  ;($727)
TriMidBlip:         .res 1  ;($72A) Loaded with 1/2 of Triangle note counter.
TriFrontBlip:       .res 1  ;($72B) Loaded with triangle note counter - 2.
TriBlipType:        .res 1  ;($72C) #$00=Front half blip, #$01=Mid way blip, #$02=Back half blip.

;-------------------------------------[Hardware Registers]-------------------------------------------

.segment "REGISTERS"

PPUControl0:        .res 1  ;($2000)
PPUControl1:        .res 1  ;($2001)
PPUStatus:          .res 1  ;($2002)
SPRAddress:         .res 1  ;($2003) PPU hardware control registers.
SPRIOReg:           .res 1  ;($2004)
PPUScroll:          .res 1  ;($2005)
PPUAddress:         .res 1  ;($2006)
PPUIOReg:           .res 1  ;($2007)

                    .res 8184  ;($2008)
SQ1Cntrl0:          .res 1  ;($4000)
SQ1Cntrl1:          .res 1  ;($4001) SQ1 hardware control registers.
SQ1Cntrl2:          .res 1  ;($4002)
SQ1Cntrl3:          .res 1  ;($4003)

SQ2Cntrl0:          .res 1  ;($4004)
SQ2Cntrl1:          .res 1  ;($4005) SQ2 hardware control registers.
SQ2Cntrl2:          .res 1  ;($4006)
SQ2Cntrl3:          .res 1  ;($4007)

TriangleCntrl0:     .res 1  ;($4008)
TriangleCntrl1:     .res 1  ;($4009) Triangle hardware control registers.
TriangleCntrl2:     .res 1  ;($400A)
TriangleCntrl3:     .res 1  ;($400B)

NoiseCntrl0:        .res 1  ;($400C)
NoiseCntrl1:        .res 1  ;($400D) Noise hardware control registers.
NoiseCntrl2:        .res 1  ;($400E)
NoiseCntrl3:        .res 1  ;($400F)

DMCCntrl0:          .res 1  ;($4010)
DMCCntrl1:          .res 1  ;($4011) DMC hardware control registers.
DMCCntrl2:          .res 1  ;($4012)
DMCCntrl3:          .res 1  ;($4013)

SPRDMAReg:          .res 1  ;($4014) Sprite RAM DMA register.
APUCommonCntrl0:    .res 1  ;($4015) APU common control 1 register.
CPUJoyPad1:         .res 1  ;($4016) Joypad1 register.
APUCommonCntrl1:    .res 1  ;($4017) Joypad2/APU common control 2 register.
