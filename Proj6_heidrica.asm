TITLE Project 6     (Proj6_heidrica.asm)

; Author: Adam Heidrick
; Last Modified: 22 November 2021
; OSU email address: heidrica@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 5 December 2021
; Description: This program uses low-level I/O procedures, string primatives, and implements macros to accomplish the following:
;              1. Uses modular procedures to reveive a user's input as a string 10 times and converts it into numeric form without ReadInt or ReadDec
;			   2. The user's input once converted is then calculates the sum and the rounded average. 
;			   3. The numbers entered, sum of numbers, and rounded average, is converted into charachters and printed wihout using WriteInt or WriteDec

INCLUDE Irvine32.inc


mGetString MACRO user_prompt, user_input, MAX, byte_count
	push	edx
	push	ecx
	
	mov		edx, user_prompt
	call	WriteString
	
	mov		edx, user_input
	mov		ecx, MAX
	call	ReadString
	mov		byte_count, eax

	pop		ecx
	pop		edx
ENDM

mDisplayString MACRO converted_num

	push	edx
	mov		edx, converted_num
	call	WriteString
	pop		edx	

ENDM

mCallingRead MACRO 

	push	offset stored_num	
	push	offset val_error	
	push	conv_num			
	push	offset user_prompt	
	push	offset user_input	
	push	max_input			
	push	byte_count

ENDM

mCallingWrite MACRO 

	push	stored_num
	push	offset conv_string

ENDM

.data
; This is for the intro
author			byte		"Project 6: Portfolio Project : Low-Level I/O procedures",13,10,
							"Written by: Adam Heidrick (heidrica@oregonestate.edu)",13,10,13,10,0

intro			byte		"Please proved 10 signed decimal integers.",13,10,
							"Each number needs to be small enough to fit inside a 32 bit register.",13,10,
							"After you have finished inputting the numbers, I will display a list of integers, their sum, and their average.",13,10,13,10,0

; This is for the Get String MACRO
user_prompt		byte		"Please enter a signed number: ",0		; prompt for user
user_input		byte		31 DUP(0)
max_input		DWORD		sizeof user_input
byte_count		dword		?

; This is for the ReadVal Procedure
stored_num		SDWORD		?										; stores the value after conversion								
conv_num		SDWORD		0										; holds the value while converting
val_error		DWORD		0										; this is for indicating an error within ReadVal evaluation, is 1 if error 0 if no error

; This is for Writeval Procedure
conv_string		byte		31 DUP(0)								; string to be read

; This is for main
user_error		byte		"Error: you did not enter a signed number or your number was too big.",13,10,0
running_sum		SDWORD		0										; used to store running sum
nums_collected	byte		31 DUP(0)								; collected users entered number into array

.code
main PROC

	mDisplayString offset author
	mDisplayString offset intro

	mov		ecx, 10				; counting 10 user inputs
	mov		edi, offset nums_collected

_collectLoop:
	mCallingRead			
	call	ReadVal
	cmp		val_error, 1
	je		_error
	
	call	CrLf
	mov		eax, stored_num
	stosb	
	loop	_collectLoop
	jmp		_next
	
	_error:
	inc		ecx
	mov		edx, offset user_error
	call	writestring
	mov		val_error, 0
	loop	_collectLoop

	_next:

	mov	esi, offset nums_collected
	mov ecx, 9
	_larp:
	lodsb
	call writedec
	loop _larp

mCallingWrite
call	WriteVal

	Invoke ExitProcess,0	; exit to operating system
main ENDP



ReadVal PROC
	push		ebp
	mov			ebp, esp
	pushad

	mGetString [ebp+20], [ebp+16], [ebp+12], [ebp+8] ; MACRO TO GET USER INPUT


	mov			ecx, [ebp+8]
	mov			esi, [ebp+16]
	mov			edi, [ebp+32]
	mov			ecx, [ebp+8]						; Prep for loop

; These are preliminary checks: it checks if user just hinted enter with no value or too many characters. 

	mov			eax, [ebp+8]
	cmp			eax, 0
	jz			_error								; if does not enter value and just hits enter
	cmp			eax, 15
	ja			_error								; if user enters more than 10 characters, this is just a pre check. An overflow check is also in place in the conversion loop

; These next two checks check for the first value of the array for sign. 

	mov			al, [esi]
	cmp			al, 43
	je			_positive
	cmp			al, 45
	je			_negative
	jmp			_convertloop

_positive:
	inc			esi
	dec			ecx
	jmp			_convertloop

_negative:
	inc			esi
	dec			ecx
	mov			edx, 1				; register used to determine if the value at the end needs to be negative

_convertloop:

	LODSB		; takes whatever value is in ESI and copies it to AL REG then ESI is pointed to the next item. 
	
	cmp			al, 48
	jl			_error
	cmp			al, 57
	jg			_error 

; conversion starts here
	sub			al, 48
	mov			ebx, [ebp+24]
	push		eax
	mov			eax, 10d
	push		edx						; preserves the register that I am using to determine if the value needs to be negative
	mul			ebx
	pop			edx
	mov			ebx, eax
	pop			eax
	add			ebx, eax
	JO			_error					; -2147483648 -> 2147483647 for SDWORD. IF this overflows, then error is raised. 

; accumulates in conv_accum ebp+24
	mov			[ebp+24], ebx
	loop		_convertloop

; checks if number needs to be negative based on edx register set in _negative
	cmp			edx, 1
	jne			_done
	mov			eax, [ebp+24]
	neg			eax
	JO			_error
	mov			[ebp+24], eax

_done:
	mov			eax, [ebp+24]
	mov			[edi], eax
	JO			_error				; Work on this later
	jmp			_exit

_error:
; if error, then variable stored for errors set to one. Used in main for iteration.
	mov			edi, [ebp+28]
	mov			eax, 1
	mov			[edi], eax

_exit:

popad
pop			ebp
ret			28	
ReadVal ENDP

WriteVal PROC
push		ebp
mov			ebp, esp
pushad

mov			edi, [ebp+8]

mov			eax, [ebp+12]
cmp			eax, 0
jl			_negsym			; if number is negative, add negative symbol
je			_zero			; if number is just a zero
jmp			_separate

_negsym:
neg			eax				; turns into positive for ease of handling
push		eax
mov			eax, 45d		; puts the negative symbol at first index. 
mov			[edi],eax
add			edi, 1
pop			eax
jmp			_separate

_zero:
push		eax
mov			eax, 48d
mov			[edi], eax
pop			eax


_separate:
mov			ebx,10
mov			ecx, 0			; counter for stringit loop

_separateLoop:
inc			ecx
mov			edx,0
div			ebx
push		edx
cmp			eax,0
je			_stringit
jmp			_separateLoop

_stringit:
pop			eax
add			eax, 48d
stosb
loop		_stringit

mDisplayString [ebp+8]


; take dword down to 0 (diby dividing by 10) with remainer in edx constantly pushing to stack, once eax 0, pop & mul10 + ascii (47?) to al and STOSB to array. 

popad
pop			ebp
ret 8
WriteVal ENDP

END main
