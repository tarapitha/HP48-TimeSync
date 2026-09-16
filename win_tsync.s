* SPDX-License-Identifier: GPL-3.0-or-later
* Copyright (C) 2026 Robert Tiismus

* =======================================================
*  Project:     TimeSync
*  Description: HP48 internal system time synchronization
*		over serial interface against
*		Kermit server on MS Windows
*  Platform:    HP48 Calculators
*  Language:    SysRPL / Saturn Assembly
* =======================================================

* Calculator internal TICKS = ( UnixTimestamp + 62167219200 ) * 8192
*
* Calculator epoch starts at midnight on January 1 of
* year 0 AD or year 1 BC in the proleptic Gregorian calendar
*

ASSEMBLE
XFERFAIL	EQU	#6504E		Contains BINT # C06h "Transfer Failed"
MAXLEN		EQU	14		Max possible length of Ticks string
RPL
::
  AtUserStack
  DEPTH #2+	( Kermit might silently fail, so it is necessary )
  ' NULLLAM	( to check existence of return value on data stack )
  ONE DOBIND
  ::
    SysTime	( Local reference time before contacting external server )

    ( MS Windows PowerShell command line to get the TICKS value for HP48 )
    $ "'{0:X}'-f[bigint]([DateTime]::UtcNow.Ticks*512/625000+259050700800)"
    $ "C"
    DOPKT

    SysTime	( Local reference time after contacting external server )
    DEPTH 1GETLAM #>?SKIP :: XFERFAIL ERROROUT ;
    ROT bit+ bitSR	( Average of the local reference timestamps )
    SWAP
  ;
  ABND
  DUPTYPECSTR? ?SKIP :: XFERFAIL ERROROUT ;
  SEP$NL DROP DUPNULL$? IT :: XFERFAIL ERROROUT ; ( Extract returned value )
  SEP$NL SWAPDROP

  ( As there is no secure way of parsing simple hexadecimal number from string,
    we need to do it character by character )
  CODE
	GOSBVL	=PopASavptr	A.A -> Input string

	LCHEX	3
	B=C	P	B.P will be the reference nibble for ASCII codes '0' to '9'
	C=C+1	P
	D=C	P	D.P will be the reference nibble for ASCII codes '@' to 'I'

	A=A+CON A,5
	D0=A		D0 -> Input string payload length
	A=DAT0	A	A.A = Input string payload length

	LC(5)	2*(MAXLEN)+5	Check if string length is reasonable
	?A>C	A
	GOYES	ERR

	C=A	A
	C=C-CON	A,5
	CSRB.F	A	C.A = String length in bytes

	C=C-1	A
	P=C	0
	C=P	15	C.S = String character counter
	P=	0

	B=0	S	Count characters for use in PUSHhxsLoop

	D0=D0+	5	D0 -> String data
	A=0	W	A.W = Result accumulator
	
-	ASL	W

	C=DAT0	B	Process the character
	D0=D0+	2	D0 -> next character

	A=C	P	A.0 = speculative numerical value of character
	CSR	B

	?C#D	P	Not character from '@' to 'I'
	GOYES	+

*    Character range from '@' to 'I'
	?A=0	P
	GOYES	ERR	If '@' then error out

	LCHEX	6
	?A>C	P
	GOYES	ERR	If not 'A' to 'F' then error out

	A=A+CON	P,9	If 'A' to 'F' then add 9 to base to get #A to #F and continue
	GOTO	++

+	?C=B	P
	GOYES	++	If '0' to '9', then this character is already correctly parsed

	?C#0	P
	GOYES	ERR	Not a Carriage Return, error out

	LCHEX	D
	?A#C	P
	GOYES	ERR	Not a Carriage return, eroror out

	?B=0	S
	GOYES	ERR	String is empty or does not start with hex numbers, error out

	ASR	W	Undo last speculation
	GONC	+	Completed, last character was # 0Dh Carriage Return

ERR	LCHEX	00C06	Transfer Failed message
	GOVLNG	=GPErrjmpC

++	B=B+1	S	Increment character counter
	C=C-1	S	Decrement string position counter
	GONC	-

+	LCHEX	0001D41E89A00000
	?A<C	W
	GOYES	ERR	Time before 1. January 1991 00:00:00 is not handled by calculator

	LCHEX	EBA1AC100000
	?A>=C	W
	GOYES	ERR	Time after 31. December 2090 24:00:00 is not handled by calculator

	GOSBVL	=GETPTR
	C=B	S	Calling PUSHhxsLoop puts the contents of A.WP to Data Stack as HXS
	C=C-1	S	So we need to set register P to character count - 1
	P=C	15
	GOVLNG	=PUSHhxsLoop	Push the number of Ticks to the Data Stack
  ENDCODE

  ' ID TZ Sys@	( If 'TZ' variable is present in the HOME directory )
  IT		( then it should contain real number of hours to shift )
  ::
    DUPTYPEREAL?
    NOTcaseDROP
    % 29491200	( 3600 x #2000h = 29491200 )
    %* %># bit+
  ;

  2DUP HXS>HXS %1 %= DUP4UNROLL	( Testing if clock is running slow or fast )
  ITE
  :: bit- % -999999999999 ;
  :: SWAP bit- % 999999999999 ;
  SWAPDUP

  ( If the discrepancy is large, then we need to adjust the clock multiple times )
  (   # E8D4A50FFFh = 999999999999d that is maximal exact real value )
  HXS A FFF05A4D8E
  DUPUNROT bit/
  DUPUNROT bit* ROTSWAP bit- HXS>% 4UNROLL
  HXS># DUP#0=ITE
  2DROP
  ::
    ZERO_DO (DO)
     DUP CLKADJ
    LOOP
    DROP
  ;

  IT %CHS CLKADJ	( The final adjustment )
; 
