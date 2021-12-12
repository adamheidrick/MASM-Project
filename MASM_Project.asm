TITLE Project 6     (Proj6_heidrica.asm)

; Author: Adam Heidrick
; Last Modified: 24 November 2021
; OSU email address: heidrica@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 5 December 2021
; Description: This program uses low-level I/O procedures, string primatives, and implements macros to accomplish the following:
;              1. Uses two modular procedures:  
;			      a. ReadVal: receive a user's input as a string and converts it into numeric (SDWORD) form without ReadInt or ReadDec
;			      b. WriteVal: converts the user's coverted SDWORD and converts it back into a string without WriteInt or WriteDec
;	       2. Uses Main to propmpt the user for 10 integers, displays list of 10 integers, displays sum, and displays average. 
;	       Note: This is an exercise in creating our own ReadInt and WriteInt procedures. 

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Displays prompt, get user's keyboard input into memmory location
;
; Preconditions: do not use edx, ecx, as arguments
;
; Receives:
; user_prompt = array address
; user_input = array type
; MAX = array length
; byte_count = array size
; returns: user_input = generated string address
; ---------------------------------------------------------------------------------

mGetString MACRO user_prompt, user_input, MAX, byte_count
	push	edx
	push	ecx
	
	mov		edx, user_prompt		; Diplays message to enter an intger
	call	WriteString
	
	mov		edx, user_input			; Moves array that will store user input values
	mov		ecx, MAX
	call	ReadString
	mov		byte_count, eax			; Returns byte_count 

	pop		ecx
	pop		edx
ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Prints string which is stored in a specified memory location
;
; Preconditions: do not use edx as arguments
;
; Receives:
; converted_string = array address
; returns: prints string to console
; ---------------------------------------------------------------------------------

mDisplayString MACRO converted_string

	push	edx
	mov		edx, converted_string
	call	WriteString
	pop		edx	

ENDM

; ---------------------------------------------------------------------------------
; Name: mCallingString
;
; Pushes all necessary values to the stack prior to running ReadVal Procedure
;
; Preconditions: offsets stored_num, val_error, user_prompt, user_input need to be defined
;				 and values conv_num, max_input, byte_count need to be defined. 
; Receives: None
; 
; returns: Simply pushes all stack values needed for ReadVal Procedure
; ---------------------------------------------------------------------------------

mCallingRead MACRO 

	push	offset stored_num		
	push	offset val_error	
	push	conv_num			
	push	offset user_prompt	
	push	offset user_input	
	push	max_input			
	push	byte_count

ENDM

; ---------------------------------------------------------------------------------
; Name: mCallingString
;
; Pushes all necessary value to the stack prior to running WriteVal Procedure
;
; Preconditions: num_to_write needs to be SDWORD
;
; Receives:
; num_to_write = SDWORD 
; returns: Simply pushes all stack values needed for WriteVal Procedure
; ---------------------------------------------------------------------------------

mCallingWrite MACRO num_to_write 

	push	num_to_write
	push	offset conv_string

ENDM

.data
; This is text for the intro:
author			byte		13,10," ++++ Project 6: Portfolio Project : Low-Level I/O procedures ++++",13,10,
							" ----- Written by: Adam Heidrick (heidrica@oregonestate.edu) -----",13,10,13,10,0

intro			byte		" -----------------------ISTRUCTIONS-------------------------------",13,10,
							" Please enter 10 signed decimal integers.",13,10,
							" Each number needs to fit inside a 32 bit register.",13,10,
							" I will display your entered integers, sum, and average.",13,10,
							" So what? Not impressed?",13,10,
							" This program does not use Irvine32's ReadInt or WriteInt.",13,10,
							" -----------------------------------------------------------------",13,10,13,10,0

; This data is used for the mGetString MACRO:
user_prompt		byte		" Please enter a signed number: ",0		; prompt for user
user_input		byte		31 DUP(0)
max_input		dword		sizeof user_input
byte_count		dword		?

; This is for the ReadVal Procedure
stored_num		sdword		?										; stores the value after conversion								
conv_num		sdword		0										; holds the value while converting (an empty accumulator). 
val_error		dword		0										; this is for indicating an error within ReadVal evaluation, is 1 if error 0 if no error

; This is for Writeval Procedure
conv_string		byte		31 DUP(0)								; string to be read

; This is text for main
user_error		byte		" Error: you did not enter a signed number or your number was too big.",13,10,0
total_message	byte		13,10," You entered the following numbers: ",13,10,0
sum_message		byte		13,10,13,10," The sum of these numbers is: ", 0
average_mes		byte		13,10," The rounded average is: ",0
spacer			byte		", ",0

; This is data stored for main
running_sum		sdword		0										; used to store running sum
nums_collected	sdword		10 DUP(0)								; collected users entered number into array

; This is the farewell text. Thank you! 
farewell		byte		13,10,13,10,"---------------------END OF PROGRAM-----------------------------",13,10,13,10,
										" Thank you and goodbye.", 13,10,13,10,
										"----------------------------------------------------------------",13,10,0
							

.code
; ---------------------------------------------------------------------------------
; Name: Main
; Note on this project: 
; Per prgram requirements, the only two modular procedure are ReadVal and WriteVal
; Main "uses the ReadVal and WriteVal procedures above to:
;
; 1. Get 10 valid integers from the user. Your ReadVal will be called within the loop in main. 
;    Do not put your counted loop within ReadVal.
; 2. Stores these numeric values in an array.
; 3. Display the integers, their sum, and their average."
;  
; Therfore, main references data segment varaibles by name while the two procedures 
; use STDCall call convention
; ---------------------------------------------------------------------------------
main PROC
_intro:
	; Uses macros to easily print intro messages to console.
	mDisplayString offset author
	mDisplayString offset intro

; --------------------------------------------------------------------------------------------------------------------------
; This is where the user's inputs are collected and converted into intgers
; --------------------------------------------------------------------------------------------------------------------------
_collection:
	; Sets up loop for collecting user input which will be 10 valid integers. 
	mov		ecx, 10				
	mov		edi, offset nums_collected	; This is the array that will hold the valid integers

_collectLoop:
	; This is the loop where "ReadVall will be called within the loop in main." Per program requirements. This is that loop.
	mCallingRead						; See above, this just uses a macro to push required data to be processed by ReadVal		
	call	ReadVal
	cmp		val_error, 1				; If ReadVal returns an error, it is reflected in this variable
	je		_error

	mov		eax, stored_num				
	add	    running_sum, eax			; Keeps a running sum to be printed to console at _sum
	stosd								; String primitive to store value in array and increase destination array
	loop	_collectLoop
	jmp		_Write
	
_error:
	; This is the code block that handles errors during ReadVal
	inc		ecx
	mDisplayString offset user_error	; Error message to be displayed to user
	mov		val_error, 0
	loop	_collectLoop


; --------------------------------------------------------------------------------------------------------------------------
; This is where the integers are then converted back to characters
; --------------------------------------------------------------------------------------------------------------------------

_Write:
	mDisplayString offset total_message ; Prints message to user indicating the 10 input integers
	mov		esi, offset nums_collected
	mov		ecx, 10
	
_Writeloop:
	; This iterates through the list of collected integers and prints them to the consold. 
	lodsd								; String primitive to take each integer in nums_collected to pass one at a time to WriteVal
	mov		stored_num, eax
	
	mCallingWrite stored_num
	call	WriteVal
	
	mDisplayString offset spacer		; This just adds " ," after each character printed for readability.
	loop	_Writeloop
	
_sum:
	; This prints the sum of numbers entered
	mDisplayString offset sum_message	; This takes the running_sum that was totaled during collectLoop and calls WriteVal to translate and print
	mCallingWrite	running_sum
	call	WriteVal
	call	crLf

_average:
	; This prints the average of number entered (floored per program description)
	mDisplayString offset average_mes	; Displays average floored. 
	mov		eax, running_sum
	cdq
	mov		ebx, 10
	idiv	ebx
	mCallingWrite	eax
	call	WriteVal

_goodbye:
	; Prints farewell message. 
	mDisplayString offset farewell

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Receives a string of characters and converts it into an integer. 
;
; Preconditions: below recieves are preconditions. 
;
; Postconditions: two variables changed: stored_num and val_error
;
; Receives:
; [ebp+32]	= stored_num:	 SDWORD		variable
; [ebp+28]	= val_error:	 DWORD		variable
; [ebp+24]	= conv_num:		 SDWORD		variable	
; [ebp+20]	= user_prompt	 array		offset for asking user to input number
; [ebp+16]	= user_input	 array		offset of the user input array
; [ebp+12]	= max_input	     DWORD		size of user input
; [ebp+8]	= byte_count	 DWORD		length of user input
; 
;
; returns: stored_num dword with integer; val_error 0 or 1 (1 for error 0 for no error)
; ---------------------------------------------------------------------------------
ReadVal PROC
	push		ebp
	mov			ebp, esp
	pushad

	mGetString [ebp+20], [ebp+16], [ebp+12], [ebp+8] ; MACRO TO GET USER INPUT
	
	; Moving the appropriate arrays to esi and edi and moving the byte_count into ECX for loop. 
	mov			esi, [ebp+16]
	mov			edi, [ebp+32]
	mov			ecx, [ebp+8]						

	; These are preliminary checks: it checks if user just hit enter with no value or too many characters. 
	mov			eax, [ebp+8]
	cmp			eax, 0								; if does not enter value and just hits enter
	jz			_error								
	cmp			eax, 11								; if user enters more than 15 characters, this is just a pre check. An overflow check is also in place in the conversion loop
	ja			_error								

	; These next two checks check for the first value of the array for sign. 
	mov			al, [esi]
	cmp			al, 43								; + symbol check
	je			_positive
	cmp			al, 45								; - symbol check
	je			_negative
	jmp			_convertloop

_positive:
	; For symbols in the first index, the esi needs to be increased before using string primitives.
	inc			esi
	dec			ecx
	jmp			_convertloop

_negative:
	inc			esi
	dec			ecx
	mov			edx, 1				; This is used to indicate a sign change in _negcheck

_convertloop:
	; takes whatever value is in ESI and copies it to AL REG then ESI is pointed to the next item. 
	LODSB		
	
	; checks if in range of ASCII nums
	cmp			al, 48
	jl			_error
	cmp			al, 57
	jg			_error 

	; conversion starts here
	sub			al, 48
	mov			ebx, [ebp+24]
	push		eax
	mov			eax, 10d
	push		edx						; preserves the register that I am using to determine if the value needs to be negative at _negcheck
	mul			ebx
	pop			edx
	mov			ebx, eax
	pop			eax
	add			ebx, eax
	JO			_error					; -2147483648 -> 2147483647 for SDWORD. IF this overflows, then error is raised. 
	; conversion ends here

	; accumulates in conv_accum ebp+24
	mov			[ebp+24], ebx
	loop		_convertloop

_negcheck:
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
	; if error, then variable stored for errors set to one. Used in main for iteration.
	mov			edi, [ebp+28]
	mov			eax, 1
	mov			[edi], eax

_exit:
	popad
	pop			ebp
	ret			28
	
ReadVal ENDP

; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; Converts a SDWORD value (input parameter, by value) to a string of ascii digits. 
;
; Preconditions: The value to be passed must be SDWORD
;
; Postconditions: Prints converted SDWORD to screen
;
; Receives:
; [ebp+12]	= num_to_write:			SDWORD
; [ebp+8]	= offset conv_string	offset of array to store the converted integer
;
; returns: conv_string = an array of ASCII digits; prints to screen. 
; ---------------------------------------------------------------------------------
WriteVal PROC
	push		ebp
	mov			ebp, esp
	pushad

	; moves array that will store of converted digits into esi, moves the DWORD into eax for processing. 
	mov			edi, [ebp+8]	
	mov			eax, [ebp+12]
	cmp			eax, 0			; This test the sign of the dword

	jl			_negsym			; if number is negative, add negative symbol _negsym
	je			_zero			; if number is just a zero, just convert that number _zero
	jmp			_separate		; if the above are not met, then the string needs to be separated so each number can be converted _separate

_negsym:
	neg			eax				; turns into positive for ease of handling
	push		eax
	mov			eax, 45d		; puts the negative symbol at first index. 
	mov			[edi],eax		; increases edi to be used in separateLoop string primitive
	add			edi, 1
	pop			eax
	jmp			_separate

_zero:
	push		eax
	mov			eax, 48d
	mov			[edi], eax
	pop			eax

_separate:
	; Method is to separate each number by dividing by ten, which puts the value into edx. Then pushing edx to the stack for easy retreival when converting _stringit
	mov			ebx,10
	mov			ecx, 0			; counter for stringit loop

_separateLoop:
	; divide by 10, take edx and push it to stack. This gets each number on the stack. 
	inc			ecx
	mov			edx,0
	div			ebx
	push		edx
	cmp			eax,0			; once eax = 0, all the numbers have been separated onto the stack
	je			_stringit
	jmp			_separateLoop   ; if not 0, then pushing to the stack continues. 

_stringit:
; this pops the edx values pushed above into eax for conversion and storing into array . . . pretty cool. 
	pop			eax				
	add			eax, 48d
	stosb
	loop		_stringit

	mDisplayString [ebp+8]			; Macro that takes in the conv_string [ebp+8] and prints to console. 

_clearit:
	; This is used to clear the array. Without it clear, calling write string will print numbers that were not overwritten by smaller numbers 
	mov			ecx, 31
	mov			edi, [ebp+8]

_clearitloop:
	mov			eax, 0
	stosb
	cld							
	loop	_clearitloop
	std

	popad
	pop			ebp
	ret 8
WriteVal ENDP

END main
