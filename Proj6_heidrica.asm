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
	call		writeDec


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
conv_num		SDWORD		?										; holds the value of the converted number

.code
main PROC
push	conv_num
push	offset user_prompt
push	offset user_input
push	max_input
push	byte_count
call ReadVal



	Invoke ExitProcess,0	; exit to operating system
main ENDP

ReadVal PROC
; 20 user prompt. 16 user_input array. 12 size of input. 8 num of characters in array
push		ebp
mov			ebp, esp
pushad

mGetString [ebp+20], [ebp+16], [ebp+12], [ebp+8] 
mov			ecx, [ebp+8]


; LODSB? 
mov			esi, [ebp+16]
_thisloop:
LODSB		; takes whatever value is in ESI and copies it to AL REG then ESI is pointed to the next item. 
; modify AL then store that value in an array (the accumulator) the final number will be stored into holder.
call		CrLf
call		writedec
loop		_thisloop

; Before working with signs, which will just be a loop I hope; convert into value. create converted array; STOSB LODSB

popad
pop			ebp
ret			20	
ReadVal ENDP

WriteVal PROC



ret
WriteVal ENDP

END main
