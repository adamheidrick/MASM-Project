# Portfolio Project 6: String Primitives and Macros
**This is a portfolio project for OSU's Computer Architeture and Assembly Language course.**
The main purpose of this project is to accomplish the following:

1. Design, implement, and call low-level I/O procedures
2. Implementing and using macros

**What follows is what the program description:**

**MACROS:**
Implement and test two macros for string processing. These macros should use Irvine’s ReadString to get input from the user, and WriteString procedures to display output.

**mGetString:**  Display a prompt (input parameter, by reference), then get the user’s keyboard input into a memory location (output parameter, by reference). You may also need to provide a count (input parameter, by value) for the length of input string you can accommodate and a provide a number of bytes read (output parameter, by reference) by the macro.

**mDisplayString:**  Print the string which is stored in a specified memory location (input parameter, by reference).

**PROCEDURES:**
Implement and test two procedures for signed integers which use string primitive instructions

**ReadVal:** Invoke the mGetString macro to get user input in the form of a string of digits.
Convert (using string primitives) the string of ascii digits to its numeric value representation (SDWORD), validating the user’s input is a valid number (no letters, symbols, etc).
Store this one value in a memory variable (output parameter, by reference). 

**WriteVal:** Convert a numeric SDWORD value (input parameter, by value) to a string of ascii digits
Invoke the mDisplayString macro to print the ASCII representation of the SDWORD value to the output.

Write a test program (in main) which uses the ReadVal and WriteVal procedures above to:

1. Get 10 valid integers from the user. Your ReadVal will be called within the loop in main. Do not put your counted loop within ReadVal.
2. Stores these numeric values in an array.
3. Display the integers, their sum, and their truncated average.
4. Your ReadVal will be called within the loop in main. Do not put your counted loop within ReadVal.

**Program Requirements:**

1. **ReadInt, ReadDec, WriteInt, and WriteDec are not allowed!**
Essentially, the program reads the user input and converts from ASCII to numeric digit--ensuring tha tthe character is valid. 
2. Converting uses string primitives LODSB and STOSB operators for dealing with tstrings.
3. All procedures parameters are passed on the runtime stack using STDCall calling conventions. 
4. REgisters are saved and restored by the called procedures and macros.
5. The stack frame is cleaned up by the called procedure.
6. Procedures, except main, do not reference data segment variables by name.
7. The program uses regiser indirect addressing for integer (SDWORD) array elements and Bast + Offset addressing for accessing parameters on the runtime stack.
8. The program is well documented and styled for readability, which includes complete header blocks, comments, and proper procedure headers. 
