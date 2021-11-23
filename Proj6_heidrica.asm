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
	
	mov edx,	user_input
	mov ecx,	MAX
	call		ReadString
	mov			byte_count, eax
	;call		writeDec

	pop		ecx
	pop		edx
ENDM




.data
; This is for the Get String MACRO
user_prompt		byte		"Please enter a signed number: ",0		; prompt for user
user_input		byte		31 DUP(0)
max_input		DWORD		sizeof user_input
byte_count		dword		?

; This is for the ReadVal Procedure
stored_num		SDWORD		?										; stores the value after conversion								
conv_num		SDWORD		0										; holds the value while converting
val_error		DWORD		0										; this is for indicating an error within ReadVal valuation


.code
main PROC
push	offset stored_num	; +32
push	offset val_error	; +28
push	conv_num			; +24
push	offset user_prompt	; +20
push	offset user_input	; +16
push	max_input			; +12
push	byte_count			; +8
call	ReadVal
call	CrLf

mov		eax, stored_num
call	writeInt
mov		eax, val_error
call	writeInt

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
	JO			_error
	jmp			_exit

_error:
	mov			edi, [ebp+28]
	mov			eax, 1
	mov			[edi], eax

_exit:


popad
pop			ebp
ret			28	
ReadVal ENDP

WriteVal PROC
; convert a numeric SDWORD value to a string of ascii digits
; invoke the mDisplayString macro to print the ascii representation of the SDWORD value to the output
; if negative <0, multiply by -1 and move char "-" into edi then inc edi.Then . . 

; take dword down to 0 (diby dividing by 10) with remainer in edx constantly pushing to stack, once eax 0, pop & mul10 + ascii (47?) to al and STOSB to array. 


ret
WriteVal ENDP

END main
