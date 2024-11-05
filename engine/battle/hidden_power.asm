HiddenPowerDamage:
; Override Hidden Power's type and power based on the user's DVs.

	ld hl, wBattleMonDVs
	ldh a, [hBattleTurn]
	and a
	jr z, .got_dvs
	ld hl, wEnemyMonDVs
.got_dvs

; Power:

; Take the top bit from each stat

	; Attack
	ld a, [hl]
	swap a
	and %1000

	; Defense
	ld b, a
	ld a, [hli]
	and %1000
	srl a
	or b

	; Speed
	ld b, a
	ld a, [hl]
	swap a
	and %1000
	srl a
	srl a
	or b

	; Special
	ld b, a
	ld a, [hl]
	and %1000
	srl a
	srl a
	srl a
	or b

; Multiply by 5
	ld b, a
	add a
	add a
	add b

; Add Special & 3
	ld b, a
	ld a, [hld]
	and %0011
	add b

; Divide by 2 and add 30 + 1
	srl a
	add 30
	inc a

	ld d, a

; Type:

	; Def & 3
	ld a, [hl]
	and %0011
	ld b, a

	; + (Atk & 3) << 2
	ld a, [hl]
	and %0011 << 4
	swap a
	add a
	add a
	or b

; Skip Normal
	inc a

; Skip Bird
	cp BIRD
	jr c, .done
	inc a

; Skip unused types
	cp UNUSED_TYPES
	jr c, .done
	add UNUSED_TYPES_END - UNUSED_TYPES

.done

; Overwrite the current move type.
	push af
	ld a, BATTLE_VARS_MOVE_TYPE
	call GetBattleVarAddr
	pop af

; Map back to vanilla types
	push hl
	; ASSUMES a > 0!
	; The table starts at FIGHTING and not NORMAL,
	; but the value assumes we're starting from NORMAL
	; so subtract by 1 to compensate for it
		dec a
	; map back to the proper type
		ld hl, .VanillaTypeRemapping
	; hl <- .VanillaTypeRemapping + a
		add l
		ld l, a
		ld a, h
		adc 0
		ld h, a
	; should get the proper type now
		ld a, [hl]
	pop hl
	ld [hl], a

; Get the rest of the damage formula variables
; based on the new type, but keep base power.
	ld a, 60  ; Forced to 60 base power. Change 60 to 'd' to revert back to variable damage.
	push af
	farcall BattleCommand_DamageStats ; damagestats
	pop af
	ld d, a
	ret

.VanillaTypeRemapping:
; physical/special split changed the order of the
; move enums, remap it back to vanilla format
	table_width 1, HiddenPowerDamage.VanillaTypeRemapping
	db FIGHTING
	db FLYING
	db POISON
	db GROUND
	db ROCK
	db BIRD ; not used
	db BUG
	db GHOST
	db STEEL
	ds UNUSED_TYPES_END - UNUSED_TYPES
	db CURSE_TYPE
	db FIRE
	db WATER
	db GRASS
	db ELECTRIC
	db PSYCHIC_TYPE
	db ICE
	db DRAGON
	db DARK
	assert_table_length TYPES_END
