;This file provides constants for writing positions in terms of col, row, and nametable

.scope
    ;Example1 - Where is this position on the screen?
    ;This is not clear at all
    pos1 = $2714
    .assert pos1 = $2714, error

    ;Example 2 - Full calculation
    ;This makes it clear where the position is, but is too verbose
    col = 20
    row = 24
    nametable_index = 1
    pos2 = col + row*$20 + $2000 + nametable_index * $400
    .assert pos2 = $2714, error

    ;Example 3 - constants
    ;This makes it clear where the position is, and will error if you go out of bounds
    pos3 = col_20 + row_24 + nametable_1
    .assert pos3 = $2714, error
.endscope

nametable_0 = $2000 + $400 * 0
nametable_1 = $2000 + $400 * 1
nametable_2 = $2000 + $400 * 2
nametable_3 = $2000 + $400 * 3

col_00 = 00
col_01 = 01
col_02 = 02
col_03 = 03
col_04 = 04
col_05 = 05
col_06 = 06
col_07 = 07
col_08 = 08
col_09 = 09
col_10 = 10
col_11 = 11
col_12 = 12
col_13 = 13
col_14 = 14
col_15 = 15
col_16 = 16
col_17 = 17
col_18 = 18
col_19 = 19
col_20 = 20
col_21 = 21
col_22 = 22
col_23 = 23
col_24 = 24
col_25 = 25
col_26 = 26
col_27 = 27
col_28 = 28
col_29 = 29
col_30 = 30
col_31 = 31

row_00 = 00 * $20
row_01 = 01 * $20
row_02 = 02 * $20
row_03 = 03 * $20
row_04 = 04 * $20
row_05 = 05 * $20
row_06 = 06 * $20
row_07 = 07 * $20
row_08 = 08 * $20
row_09 = 09 * $20
row_10 = 10 * $20
row_11 = 11 * $20
row_12 = 12 * $20
row_13 = 13 * $20
row_14 = 14 * $20
row_15 = 15 * $20
row_16 = 16 * $20
row_17 = 17 * $20
row_18 = 18 * $20
row_19 = 19 * $20
row_20 = 20 * $20
row_21 = 21 * $20
row_22 = 22 * $20
row_23 = 23 * $20
row_24 = 24 * $20
row_25 = 25 * $20
row_26 = 26 * $20
row_27 = 27 * $20
row_28 = 28 * $20
row_29 = 29 * $20