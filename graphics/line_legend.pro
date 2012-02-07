;+
; NAME:
;	LINE_LEGEND
;
; PURPOSE:
;	This procedure plots a legend for line plots.
;
; CATEGORY:
;	Graphics
;
; CALLING SEQUENCE:
;	LINE_LEGEND, Position, Label
;
; INPUTS:
;	Position:  A 2-element vector containing the position ([x,y]) in
;		normal coordinates of the lower left corner of the
;		box containing the legend.
;	Label:  A vector, of type string, containing the labels for each
;		line.
;
; KEYWORD PARAMETERS:
;	BACKGROUND:  The colour index of a background for the legend box.  If
;		not set, no background is drawn.
;	CHARSIZE:  The size of the label characters, of type floating
;		point.  The default is the IDL default (!p.charsize).
;	COLOR:  A vector, of type integer, containing the colour index
;		values of the lines.  The default is the IDL default
;		(!p.color).
;	FONT:  An integer specifying the graphics font to use.  The default is
;		the IDL default (!p.font).
;	LENGTH:  The length of the lines in normal coordinates.
;	LINESTYLE:  A vector, of type integer, containing the linestyle index
;		value for each line.  The default is the IDL default
;		(!p.linestyle).
;	PSYM:  A vector, of type integer, containing the symbol codes.  The
;		default is the IDL default (!p.psym).
;	THICK:  A vector, of type integer, containing the line thickness
;		value for each line.  The default is the IDL default
;		(!p.thick).
;	TITLE:  A string containing the title of the legend.
;
; USES:
;	VAR_TYPE.pro
;
; PROCEDURE:
;	This procedure uses the input values to construct an appropriate
;	box containing the legend for a line plot.
;
; EXAMPLE:
;	Create a legend for a two-line plot (colours red and green).
;	  tek_color
;	  line_legend, [0.2,0.2], ['Red','Green'], color=[2,3], $
;                      title='Legend'
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
; 	Written by:	Daithi A. Stone (stoned@atm.ox.ac.uk), 2000-09-18.
;	Modified:	DAS, 2003-02-05 (added FONT and PSYM keywords,
;			converted LINE keyword to LINESTYLE).
;	Modified:	DAS, 2003-06-25 (added BACKGROUND keyword).
;	Modified:	DAS, 2005-04-12 (fixed output bugs in CHARSIZE, COLOR, 
;			LINESTYLE, PSYM, THICK keywords)
;	Modified:	DAS, 2009-10-01 (fixed so only one symbol plotted per 
;			label instead of two when PSYM given)
;	Modified:	DAS, 2010-02-19 (fixed bug which always set PSYM)
;-

;***********************************************************************

PRO LINE_LEGEND, $
	Position, $
	Label, $
	BACKGROUND=background, $
	CHARSIZE=charsize, $
	CHARTHICK=charthick, $
	COLOR=color, $
	FONT=font, $
	LENGTH=length, $
	LINESTYLE=linestyle, $
	PSYM=psym, $
	THICK=thick, $
	TITLE=title, $
	no_bullet=no_bullet, $
	no_shadow=no_shadow, $
	NOBOX=nobox

;***********************************************************************
; Variables and Options

; Number of lines
nlabels = n_elements( label )

; Line colours (COLOR keyword)
if not( keyword_set( color ) ) then begin
  color0 = !p.color + intarr( nlabels )
endif else begin
  color0 = color
  ; Assure sufficient number defined
  if n_elements( color0 ) lt nlabels then begin
    color0 = color0[0] + intarr( nlabels )
  endif
endelse

; Graphics font (FONT keyword)
if n_elements( font ) eq 0 then font = !p.font

; Line styles (LINESTYLE keyword)
if not( keyword_set( linestyle ) ) then begin
  linestyle0 = !p.linestyle + intarr( nlabels )
endif else begin
  linestyle0 = linestyle
  ; Assure sufficient number defined
  if n_elements( linestyle0 ) lt nlabels then begin
    linestyle0 = linestyle0[0] + intarr( nlabels )
  endif
endelse

; Line thicknesses (THICK keyword)
if not( keyword_set( thick ) ) then begin
  thick0 = !p.thick + intarr( nlabels )
endif else begin
  thick0 = thick
  ; Assure sufficient number defined
  if n_elements( thick0 ) lt nlabels then begin
    thick0 = thick0[0] + intarr( nlabels )
  endif
endelse

; Symbols (PSYM keyword)
if not( keyword_set( psym ) ) then begin
  psym0 = !p.psym + intarr( nlabels )
endif else begin
  psym0 = psym
  ; Assure sufficient number defined
  if n_elements( psym0 ) lt nlabels then psym0 = psym0[0] + intarr( nlabels )
endelse

; Line lengths (LENGTH keyword)
if not( keyword_set( length ) ) then length = 0.02

; Determine the legend box corner positions
xpos = position[[0,0]]
ypos = position[[1,1]]
if !p.multi[1] ne 0 then begin
  if !p.multi[0] eq 0 then pmulti0 = !p.multi[1] * !p.multi[2] $
                      else pmulti0 = !p.multi[0]
  xpos = ( pmulti0 + !p.multi[1] - 1 ) / !p.multi[1] $
         - pmulti0 / 1. / !p.multi[1] + xpos / !p.multi[1]
endif
if !p.multi[2] ne 0 then begin
  if !p.multi[0] eq 0 then pmulti0 = !p.multi[1] * !p.multi[2] $
                      else pmulti0 = !p.multi[0]
  ypos = ( ypos + ( pmulti0 - 1 ) / !p.multi[1] ) / 1. / !p.multi[2]
endif

; Character scale
if not( keyword_set( charsize ) ) then begin
  charsize0 = !p.charsize
endif else begin
  charsize0 = charsize
endelse
if charsize0 eq 0. then charsize0 = 1.
if !p.multi[2] gt 1 then charsize0 = charsize0 / !p.multi[2]
spacing = 1. * charsize0 * !d.y_ch_size / !d.y_size

if not( keyword_set( charthick ) ) then begin
  charthick0 = !p.charthick
endif else begin
  charthick0 = charthick
endelse

;***********************************************************************
; Plot Legend

; Re-determine the legend box corner positions
ypos[1] = ypos[0] + ( 1.5 * nlabels + 0.5 ) * spacing

; plot shadow
if ~keyword_set(no_shadow) then begin
	if n_elements( background ) eq 0 then $
		background = get_background()
  id = where( strlen( label ) eq max( strlen( label ) ) )
  xyouts, xpos[0]+length/2., ypos[0]+spacing/2., label[id[0]], $
      /normal, charsize=charsize0, width=strwidth, font=font, charthick=charthick0
  xpos[1] = xpos[0] + 2.5 * length + strwidth
  ; Clear area for legend box
	xfac = 1.
	yfac = 1.
	sd = get_format(landscape=ls, portrait=pt)
	if pt then $
		yfac = 1./sqrt(2) $
	else $
		xfac = 1./sqrt(2)
  polyfill, xpos[[0,1,1,0,0]]+0.025*xfac*(xpos[1]-xpos[0]), ypos[[0,0,1,1,0]]-0.025*yfac*(xpos[1]-xpos[0]), $ ;+[0,0,1,1,0]*2.*spacing, $
      color=get_gray(), /normal
endif

; plot background box
if n_elements( background ) ne 0 then begin
  id = where( strlen( label ) eq max( strlen( label ) ) )
  xyouts, xpos[0]+length/2., ypos[0]+spacing/2., label[id[0]], $
      /normal, charsize=charsize0, width=strwidth, font=font, charthick=charthick0
  xpos[1] = xpos[0] + 2.5 * length + strwidth
  ; Clear area for legend box
  polyfill, xpos[[0,1,1,0,0]], ypos[[0,0,1,1,0]], $ ;+[0,0,1,1,0]*2.*spacing, $
      color=background, /normal
  ; Draw the legend border
  plots, xpos[[0,1,1,0,0]], ypos[[0,0,1,1,0]], color=!p.color, /normal
endif

; Draw the bullets
if ~keyword_set(no_bullet) then begin
	for i = 0, nlabels - 1 do begin
		j = nlabels - i - 1
		psym_opt = keyword_set( psym0[i] )
		plots, xpos[0]+length+[-1,1]*length/2.*(1-psym_opt), $
				ypos[0]+(1.5*i+1.)*spacing+[0,0], /normal, color=color0[j], $
				linestyle=linestyle0[j], thick=thick0[j], psym=psym0[j]
	endfor
endif

; Label the bullets and determine the longest label
strwidth = 0.
for i = 0, nlabels - 1 do begin
  xyouts, xpos[0]+2*length, ypos[0]+(3.*i+1)*spacing/2., (reverse(label))[i], $
      width=strwidth1, /normal, charsize=charsize0, alignment=0, font=font, charthick=charthick0
  if strwidth1 gt strwidth then strwidth = strwidth1
endfor

; Legend box
if n_elements( background ) eq 0 then begin
  ; Re-determine the legend box corner positions
  xpos[1] = xpos[0] + 2.5 * length + strwidth
  ; Draw the legend border
	if ~keyword_set(nobox) then $
		plots, xpos[[0,1,1,0,0]], ypos[[0,0,1,1,0]], color=!p.color, /normal
endif

; Title
if keyword_set( title ) then begin
  xyouts, (xpos[1]+xpos[0])/2., ypos[1]+spacing/2., title, /normal, $
          charsize=charsize0, alignment=0.5, font=font, charthick=charthick0
endif

;***********************************************************************
; The End

return
END
