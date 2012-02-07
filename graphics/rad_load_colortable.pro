;+
; NAME:
; RAD_LOAD_COLORTABLE
;
; PURPOSE:
; This procedure loads colortables for various purposes. By default
; it loads a colortable based on AJ Ribiero's colors. Through keywords
; is can also load the Leicester/Cutlass/SuperDARN color table from the file
; GETENV('RAD_RESOURCE_PATH')+'/cut_col_tab.dat' and others.
;
; CATEGORY:
; Graphics
;
; CALLING SEQUENCE:
; RAD_LOAD_COLORTABLE
;
; KEYWORD PARAMETERS:
; BW: Set this keyword to load the grayscale color table, ranging from light gray (lowest)
; to black (highest).
;
; WHITERED: Set this keyword to load a color table ranging from light gray (lowest) to red (highest).
;
; BLUEWHITERED: Set this keyword to load a color table ranging from blue (lowest)
; through light gray (middle) to red (highest).
;
; COMMON BLOCKS:
; USER_PREFS: User preferences.
;
; COLOR_PREFS: Color preferences.
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
; Based on Steve Milan's CUT_COL_TAB.
; Written by Lasse Clausen, Nov, 24 2009
;-
pro rad_load_colortable, name, bw=bw, whitered=whitered, bluewhitered=bluewhitered, $
	leicester=leicester, themis=themis, aj=aj, brewer=brewer, default=default

common color_prefs

if n_params() eq 1 then begin
	if size(name, /type) ne 7 then $
		return
	if strcmp(name, 'bw', /fold_case) then $
		bw = 1
	if strcmp(name, 'whitered', /fold_case) then $
		whitered = 1
	if strcmp(name, 'bluewhitered', /fold_case) then $
		bluewhitered = 1
	if strcmp(name, 'leicester', /fold_case) then $
		leicester = 1
	if strcmp(name, 'themis', /fold_case) then $
		themis = 1
	if strcmp(name, 'aj', /fold_case) then $
		aj = 1
	if strcmp(name, 'brewer', /fold_case) then $
		brewer = 1
	if strcmp(name, 'default', /fold_case) then $
		default = 1
endif

ncolors = get_ncolors()
bottom = get_bottom()
black = get_black()
white = get_white()
gray = get_gray()

if keyword_set(leicester) then begin
	tab_file = GETENV('RAD_RESOURCE_PATH')+'/leicester_ct.dat'
	if ~file_test(tab_file) then begin
		prinfo, 'Cannot load colortable. File does not exist: ', tab_file, /force
		return
	endif
	restore, tab_file
	tvlct, red, green, blue
	set_colortable, 'LEICESTER'
	set_red, bottom + ncolors - 1
	set_green, bottom + 3./8.*ncolors - 1
	set_blue, bottom + 1./8.*ncolors - 1
	set_cyan, 0
	set_magenta, 0
	set_yellow, bottom + 5./8.*ncolors - 1
	set_orange,  bottom + 6.5/8.*ncolors - 1
	set_purple, bottom
	return
endif

if keyword_set(themis) then begin
	loadct2, 43
	set_colortable, 'THEMIS'
	set_red, bottom + 7.5/8.*ncolors - 1
	set_green, bottom + 4.3/8.*ncolors - 1
	set_blue, bottom + 2./8.*ncolors - 1
	set_cyan, bottom + 3.2/8.*ncolors - 1
	set_magenta, 0
	set_yellow, bottom + 5.5/8.*ncolors - 1
	set_orange,  bottom + 6.5/8.*ncolors - 1
	set_purple, bottom + 0.5/8.*ncolors - 1
	return
endif

red   = bytarr(ncolors)
green = bytarr(ncolors)
blue  = bytarr(ncolors)

if ~keyword_set(bw) and ~keyword_set(whitered) and ~keyword_set(bluewhitered) and ~keyword_set(aj) and ~keyword_set(brewer) and ~keyword_set(default) then $
	aj = 1

if keyword_set(whitered) then BEGIN
	gray_base=0.9
	red   = findgen(ncolors)*(1.-gray_base) + (ncolors-1.)*gray_base
	green = ((ncolors-1.)-findgen(ncolors))*gray_base
	blue  = ((ncolors-1.)-findgen(ncolors))*gray_base
	set_colortable, 'WHITERED'
	set_red, bottom+ncolors-1
	set_green, 0
	set_blue, 0
	set_cyan, 0
	set_magenta, 0
	set_yellow, 0
	set_orange, 0
	set_purple, 0
ENDIF ELSE if keyword_set(bw) then BEGIN
	gray_base=1.
	red   = ((ncolors-1.)-findgen(ncolors))*gray_base
	green = ((ncolors-1.)-findgen(ncolors))*gray_base
	blue  = ((ncolors-1.)-findgen(ncolors))*gray_base
	set_colortable, 'BW'
	set_red, 0
	set_green, 0
	set_blue, 0
	set_cyan, 0
	set_magenta, 0
	set_yellow, 0
	set_orange, 0
	set_purple, 0	
ENDIF ELSE if keyword_set(bluewhitered) then BEGIN
	gray_base=0.95
	red[0:ncolors/2-1]         = reverse(((ncolors-1.)-2.*findgen(ncolors/2))*gray_base)
	green[0:ncolors/2-1]       = reverse(((ncolors-1.)-2.*findgen(ncolors/2))*gray_base)
	blue[0:ncolors/2-1]        = reverse(2.*findgen(ncolors/2)*(1.-gray_base) + (ncolors-1.)*gray_base)
	red[ncolors/2:ncolors-1]   = 2.*findgen(ncolors/2+1)*(1.-gray_base) + (ncolors-1.)*gray_base
	green[ncolors/2:ncolors-1] = ((ncolors-1.)-2.*findgen(ncolors/2+1))*gray_base
	blue[ncolors/2:ncolors-1]  = ((ncolors-1.)-2.*findgen(ncolors/2+1))*gray_base
	set_colortable, 'BLUEWHITERED'
	set_red, bottom+ncolors-1
	set_green, 0
	set_blue, bottom
	set_cyan, 0
	set_magenta, 0
	set_yellow, 0
	set_orange, 0
	set_purple, 0
endif else if keyword_set(aj) then begin
	rcol = reverse(shift(reverse([ 37,     255,     255,     255,     124,       0,       0,       0]), 4))
	gcol = reverse(shift(reverse([255,     248,     135,      23,       0,       6,     209,     255]), 4))
	bcol = reverse(shift(reverse([  0,       0,       0,       0,     255,     255,     255,     188]), 4))
	nncolors = n_elements(rcol)
	d = ncolors/(nncolors-1)
	for i=0, nncolors-2 do begin
		red[findgen(d+(i eq nncolors-2))+i*d] = rcol[i]+findgen(d+(i eq nncolors-2))/float(d-1+(i eq nncolors-2))*(rcol[i+1]-rcol[i])
		green[findgen(d+(i eq nncolors-2))+i*d] = gcol[i]+findgen(d+(i eq nncolors-2))/float(d-1+(i eq nncolors-2))*(gcol[i+1]-gcol[i])
		blue[findgen(d+(i eq nncolors-2))+i*d] = bcol[i]+findgen(d+(i eq nncolors-2))/float(d-1+(i eq nncolors-2))*(bcol[i+1]-bcol[i])
	endfor
	set_colortable, 'AJ'
	set_red, bottom + ncolors - 1
	set_green, bottom + 4.5/8.*ncolors - 1
	set_blue, bottom + 1.1/8.*ncolors - 1
	set_cyan, bottom + 3./8.*ncolors - 1
	set_magenta, 0
	set_yellow, bottom + 5.8/8.*ncolors - 1
	set_orange,  bottom + 7./8.*ncolors - 1
	set_purple, bottom
endif else if keyword_set(brewer) then begin
	rcol = reverse([215, 244, 253, 254, 255, 224, 171, 116,  69])
	gcol = reverse([ 48, 109, 174, 224, 255, 243, 217, 173, 117])
	bcol = reverse([ 39,  67,  97, 144, 191, 248, 241, 225, 204])
	nncolors = n_elements(rcol)
	d = float(ncolors)/(nncolors-1.)
	for i=0, nncolors-2 do begin
		si = round(i*d)
		di = round((i+1.)*d)+(i eq nncolors-2) - si
		fi = findgen(di)
		red[  fi+si] = rcol[i]+fi/float(di-1)*(rcol[i+1]-rcol[i])
		green[fi+si] = gcol[i]+fi/float(di-1)*(gcol[i+1]-gcol[i])
		blue[ fi+si] = bcol[i]+fi/float(di-1)*(bcol[i+1]-bcol[i])
	endfor
	set_colortable, 'BREWER'
	set_red, bottom + ncolors - 1
	set_green, 0
	set_blue, bottom
	set_cyan, 0
	set_magenta, 0
	set_yellow, bottom + 5./8.*ncolors - 1
	set_orange,  bottom + 7./8.*ncolors - 1
	set_purple, 0
endif else if keyword_set(default) then begin
	rcol = reverse([255, 255, 127,   0])
	gcol = reverse([  0, 255, 255,   0])
 	bcol = reverse([  0,   0,   0, 255])
	nncolors = 2
	d = float(ncolors/2)/(nncolors-1.)
	for i=0, nncolors-2 do begin
		si = round(i*d)
		di = round((i+1.)*d)+(i eq nncolors-2) - si
		fi = findgen(di)
		red[  fi+si] = rcol[i]+fi/float(di-1)*(rcol[i+1]-rcol[i])
		green[fi+si] = gcol[i]+fi/float(di-1)*(gcol[i+1]-gcol[i])
		blue[ fi+si] = bcol[i]+fi/float(di-1)*(bcol[i+1]-bcol[i])
	endfor
	for i=0, nncolors-2 do begin
		si = round((i+1)*d)
		di = round(((i+1)+1.)*d)+(i eq nncolors-2) - si
		fi = findgen(di)
		red[  fi+si] = rcol[(i+2)]+fi/float(di-1)*(rcol[(i+2)+1]-rcol[(i+2)])
		green[fi+si] = gcol[(i+2)]+fi/float(di-1)*(gcol[(i+2)+1]-gcol[(i+2)])
		blue[ fi+si] = bcol[(i+2)]+fi/float(di-1)*(bcol[(i+2)+1]-bcol[(i+2)])
	endfor
	set_colortable, 'DEFAULT'
	set_red, bottom + ncolors - 1
	set_green, bottom + 3.9/8.*ncolors - 1
	set_blue, bottom
	set_cyan, 0
	set_magenta, 0
	set_yellow, bottom + 4.1/8.*ncolors - 1
	set_orange,  bottom + 6./8.*ncolors - 1
	set_purple, 0
endif

ored   = bytarr(256)
ogreen = bytarr(256)
oblue  = bytarr(256)
ored[bottom:bottom+ncolors-1]   = red
ogreen[bottom:bottom+ncolors-1] = green
oblue[bottom:bottom+ncolors-1]  = blue

; Black and white
ored[black]   = 0
oblue[black]  = 0
ogreen[black] = 0
ored[white]   = 255
oblue[white]  = 255
ogreen[white] = 255

; Ground scatter colour (grey)
ored[gray]    = 200
oblue[gray]   = 200
ogreen[gray]  = 190

IF !D.NAME NE 'NULL' THEN $
	TVLCT,ored,ogreen,oblue

end
