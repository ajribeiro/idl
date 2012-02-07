;+ 
; NAME: 
; SET_FORMAT
; 
; PURPOSE: 
; This function returns the currently active format. 
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE: 
; SET_FORMAT
;
; KEYWORD PARAMETERS:
; FREE: Set this keyword to set a free aspect ratio. This is the default.
;
; SQUARE: Set this keyword to format the panel as a square, i.e. xsize=ysize.
;
; LANDSCAPE: Set this keyword to format the output device in landscape mode.
;
; PORTRAIT: Set this keyword to format the output device in portrait mode.
;
; COLORSCALE: Set this keyword to use colored output.
;
; GRAYSCALE: Set this keyword to use monochrome output.
;
; GUPPIES: Set this keyword to allow for top and bottom margins around panels.
;
; SARDINES: Set this keyword to loose top and bottom margins around panels.
;
; SCALE: Set this keyword to use the normal color scale.
;
; ELACS: Set this keyword to use the reversed color scale.
;
; TOKYO: Set this keyword to loose left and right margins.
;
; KANSAS: Set this keyword to allow for left and right margins around the panel.
;
; COMMON BLOCKS:
; USER_PREFS: The common block holding user preferences.
;
; EXAMPLE: 
; 
; COPYRIGHT:
; Non-Commercial Purpose License
; Copyright © November 14, 2006 by Virginia Polytechnic Institute and State University
; All rights reserved.
; Virginia Polytechnic Institute and State University (Virginia Tech) owns the DaViT
; software and its associated documentation (“Software”). You should carefully read the
; following terms and conditions before using this software. Your use of this Software
; indicates your acceptance of this license agreement and all terms and conditions.
; You are hereby licensed to use the Software for Non-Commercial Purpose only. Non-
; Commercial Purpose means the use of the Software solely for research. Non-
; Commercial Purpose excludes, without limitation, any use of the Software, as part of, or
; in any way in connection with a product or service which is sold, offered for sale,
; licensed, leased, loaned, or rented. Permission to use, copy, modify, and distribute this
; compilation for Non-Commercial Purpose is hereby granted without fee, subject to the
; following terms of this license.
; Copies and Modifications
; You must include the above copyright notice and this license on any copy or modification
; of this compilation. Each time you redistribute this Software, the recipient automatically
; receives a license to copy, distribute or modify the Software subject to these terms and
; conditions. You may not impose any further restrictions on this Software or any
; derivative works beyond those restrictions herein.
; You agree to use your best efforts to provide Virginia Polytechnic Institute and State
; University (Virginia Tech) with any modifications containing improvements or
; extensions and hereby grant Virginia Tech a perpetual, royalty-free license to use and
; distribute such modifications under the terms of this license. You agree to notify
; Virginia Tech of any inquiries you have for commercial use of the Software and/or its
; modifications and further agree to negotiate in good faith with Virginia Tech to license
; your modifications for commercial purposes. Notices, modifications, and questions may
; be directed by e-mail to Stephen Cammer at cammer@vbi.vt.edu.
; Commercial Use
; If you desire to use the software for profit-making or commercial purposes, you agree to
; negotiate in good faith a license with Virginia Tech prior to such profit-making or
; commercial use. Virginia Tech shall have no obligation to grant such license to you, and
; may grant exclusive or non-exclusive licenses to others. You may contact Stephen
; Cammer at email address cammer@vbi.vt.edu to discuss commercial use.
; Governing Law
; This agreement shall be governed by the laws of the Commonwealth of Virginia.
; Disclaimer of Warranty
; Because this software is licensed free of charge, there is no warranty for the program.
; Virginia Tech makes no warranty or representation that the operation of the software in
; this compilation will be error-free, and Virginia Tech is under no obligation to provide
; any services, by way of maintenance, update, or otherwise.
; THIS SOFTWARE AND THE ACCOMPANYING FILES ARE LICENSED “AS IS”
; AND WITHOUT WARRANTIES AS TO PERFORMANCE OR
; MERCHANTABILITY OR ANY OTHER WARRANTIES WHETHER EXPRESSED
; OR IMPLIED. NO WARRANTY OF FITNESS FOR A PARTICULAR PURPOSE IS
; OFFERED. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF
; THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE,
; YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR
; CORRECTION.
; Limitation of Liability
; IN NO EVENT WILL VIRGINIA TECH, OR ANY OTHER PARTY WHO MAY
; MODIFY AND/OR REDISTRIBUTE THE PRORAM AS PERMITTED ABOVE, BE
; LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL,
; INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR
; INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS
; OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED
; BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE
; WITH ANY OTHER PROGRAMS), EVEN IF VIRGINIA TECH OR OTHER PARTY
; HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
; Use of Name
; Users will not use the name of the Virginia Polytechnic Institute and State University nor
; any adaptation thereof in any publicity or advertising, without the prior written consent
; from Virginia Tech in each case.
; Export License
; Export of this software from the United States may require a specific license from the
; United States Government. It is the responsibility of any person or organization
; contemplating export to obtain such a license before exporting.
;
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 24 2009
;-
pro set_format, square=square, free=free, $
	landscape=landscape, portrait=portrait, $
	colorscale=colorscale, grayscale=grayscale, $
	guppies=guppies, sardines=sardines, $
	scale=scale, elacs=elacs, $
	tokyo=tokyo, kansas=kansas

COMMON user_prefs

no_bits = 6
mask = 2^no_bits-1

if n_elements(up_format) eq 0 then $
	up_format = 0

IF KEYWORD_SET(square)     THEN up_format=(up_format OR 2^0)
IF KEYWORD_SET(free)       THEN up_format=(up_format AND mask-2^0)
IF KEYWORD_SET(portrait)   THEN begin
	up_format=(up_format OR 2^1)
	if strcmp(!d.name, 'PS') then begin
		DEVICE,/PORTRAIT, /inches, $
			XOFFSET=0.25,YOFFSET=0.25,XSIZE=8.0,YSIZE=10.5,$
			FONT_SIZE=18,SCALE_FACTOR=1
	endif
endif
IF KEYWORD_SET(landscape)  THEN begin
	up_format=(up_format AND mask-2^1)
	if strcmp(!d.name, 'PS') then begin
		DEVICE, /LANDSCAPE, /inches, $
			XOFFSET=0.25,YOFFSET=10.75,XSIZE=10.5,YSIZE=8.0,$
			FONT_SIZE=18,SCALE_FACTOR=1
	endif
endif
IF KEYWORD_SET(grayscale)  THEN up_format=(up_format OR 2^2)
IF KEYWORD_SET(colorscale) THEN up_format=(up_format AND mask-2^2)
IF KEYWORD_SET(sardines)   THEN up_format=(up_format OR 2^3)
IF KEYWORD_SET(guppies)    THEN up_format=(up_format AND mask-2^3)
IF KEYWORD_SET(elacs)      THEN up_format=(up_format OR 2^4)
IF KEYWORD_SET(scale)      THEN up_format=(up_format AND mask-2^4)
IF KEYWORD_SET(tokyo)      THEN up_format=(up_format OR 2^5)
IF KEYWORD_SET(kansas)     THEN up_format=(up_format AND mask-2^5)

END

