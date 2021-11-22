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
conv_num		SDWORD		0										; holds the value of the converted number
conv_accum		byte		31 DUP(0)								; array for accumulating conversion

.code
main PROC


push	offset conv_accum	; +28
push	conv_num			; +24
push	offset user_prompt	; +20
push	offset user_input	; +16
push	max_input			; +12
push	byte_count			; +8
call ReadVal



	Invoke ExitProcess,0	; exit to operating system
main ENDP

ReadVal PROC
; 20 user prompt. 16 user_input array. 12 size of input. 8 num of characters in array
push		ebp
mov			ebp, esp
pushad

mGetString [ebp+20], [ebp+16], [ebp+12], [ebp+8] ; MACRO TO GET USER INPUT

mov			ecx, [ebp+8]
mov			esi, [ebp+16]

; len list is 0 then that is a non input, and an error should be raised. 
; if len of list is greater than 15 too many inputs: message
; main validation: it will loop in main, so if maybe some a variable -1 then error and repeat. 
; PERHAPS FIRST COMPARRISON TO SEE IF POSITIVE OR NEGATIVE, THEN BRANCH
; to start LODSB ESI by one before sending it to convert if [esi] == + or neg
_positive:
; first sybmol == 43 
; inc esi: then jump
_negative:
; first symbol == 45
; inc esi: then jump

_convertloop:
LODSB		; takes whatever value is in ESI and copies it to AL REG then ESI is pointed to the next item. 

; compare if in range: if not break
sub		al, 48
mov		ebx, [ebp+24]
push	eax
mov		eax, 10d
mul		ebx
mov		ebx, eax
pop		eax
add		ebx, eax
mov		[ebp+24], ebx
loop		_convertloop

call		CrLf
mov			eax, [ebp+24]
call		writeDec
;mov	eax, [edi - 1] ; -1 because it zero terminates. 0 will always be the last number


popad
pop			ebp
ret			24	
ReadVal ENDP

WriteVal PROC
; convert a numeric SDWORD value to a string of ascii digits
; invoke the mDisplayString macro to print the ascii representation of the SDWORD value to the output
; if negative <0, multiply by -1 and move char "-" into edi then inc edi.Then . . 

; take dword down to 0 (diby dividing by 10) with remainer in edx constantly pushing to stack, once eax 0, pop & mul10 + ascii (47?) to al and STOSB to array. 


ret
WriteVal ENDP

END main
