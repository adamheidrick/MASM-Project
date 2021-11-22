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

; (insert macro definitions here)

; (insert constant definitions here)

.data

; (insert variable definitions here)

.code
main PROC

; (insert executable instructions here)

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
