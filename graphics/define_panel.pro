;+
; NAME:
; DEFINE_PANEL
; 
; PURPOSE:
; This function returns the coordinates of ONE plotting panel
; according to the total amount of plots on a page in normalized coordinates.
; 
; CATEGORY:
; Graphics
; 
; CALLING SEQUENCE: 
; Result = DEFINE_PANEL(Xmaps, Ymaps, Xmap, Ymap)
;
; OPTIONAL INPUTS:
; Xmaps: The total number of columns of plots on the resulting page.
; Default is 1.
;
; Ymaps: The total number of rows of plots on the resulting page.
; Default is 1.
;
; Xmap: The current horizontal (column) index of the plot for which 
; to calculate the position.
; Default is 0.
;
; Ymap: The current vertical (row) index of the plot for which to
; calculate the position.
; Default is 0.
;
; KEYWORD PARAMETERS:
; ASPECT: Set this keyword to force the aspect ratio, i.e. the ratio
; width/height.
;
; BAR: Set this to allow for room of a colorbar on the
; right of your plots.
;
; NO_CENTRE: Set this and panels will not be centred on the page.
;
; NO_TITLE: Set this to indicate that no big title will
; be written above the plot, hence giving more vertical space to fill with the plot.
;
; SQUARE: It constrains the panels to be square.
;
; WITH_INFO: Set this keyword to leave some extra space on the top for plotting noise
; and frequency info panels.
;
; NEXT: Every time DEFINE_PANEL is called, the 4 parameters Xmaps, Ymaps, Xmap, Ymap
; are saved in a common block. By calling DEFINE_PANEL with the NEXT keyword set,
; the panel position is incremented by 1. Positions are incremented columns before rows.
;
; SAME: Every time DEFINE_PANEL is called, the 4 parameters Xmaps, Ymaps, Xmap, Ymap
; are saved in a common block. By calling DEFINE_PANEL with the SAME keyword, the
; current panel position is read from that common block and returned.
;
; XSIZE: The width of the ENTIRE plotting area on the page, in normalized
; coordinates, i.e. 0 < XSIZE <= 1.
;
; YSIZE: The height of the ENTIRE plotting area on the page, in normalized
; coordinates, i.e. 0 < YSIZE <= 1.
;
; XORIGIN: The horizontal margin between the begining of the plotting area
; and the first panel, in normalized
; coordinates.
;
; YORIGIN: The horizontal margin between the begining of the plotting area
; and the first panel, in normalized
; coordinates.
;
; OUTPUTS:
; Returns the position of the panel in normalized coordinates.
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
; Based on Steve Milan's DEFINE_PANEL.
; Written by Lasse Clausen, Nov, 24 2009
;-
function define_panel, xmaps, ymaps, xmap, ymap,$
	square=square, bar=bar, aspect=aspect, $
	no_centre=no_centre,no_title=no_title, with_info=with_info, $
	next=next, same=same, noset=noset, $
	xsize=xsize, ysize=ysize, xorigin=xorigin, yorigin=yorigin

; Default is one panel on screen
IF N_PARAMS() NE 4 and ~keyword_set(next) and ~keyword_set(same) THEN BEGIN 
  xmaps = 1
  ymaps = 1
  xmap = 0
  ymap = 0
ENDIF

if keyword_set(next) then begin
	get_recent_panel, rxmaps, rymaps, rxmap, rymap
	; prinfo, 'next:', strjoin(string([rxmaps, rymaps, rxmap, rymap]), ', ') 
	xmaps = rxmaps
	ymaps = rymaps
	xmap = ( (rxmap+1) eq rxmaps ? 0 : rxmap+1 )
	ymap = ( (rxmap+1) eq rxmaps ? rymap+1 : rymap )
endif

if keyword_set(same) then begin
	get_recent_panel, rxmaps, rymaps, rxmap, rymap
  ; prinfo, 'same:', strjoin(string([rxmaps, rymaps, rxmap, rymap]), ', ') 
	xmaps = rxmaps
	ymaps = rymaps
	xmap = rxmap
	ymap = rymap
endif

; Check for bad x and y
if xmap ge xmaps then begin
	prinfo, 'xmap out of bounds: '+strjoin(strtrim(string([xmaps, ymaps, xmap, ymap]),2),',')
	return, [0.,0.,1.,1.]
endif
if ymap ge ymaps then begin
	prinfo, 'ymap out of bounds: '+strjoin(strtrim(string([xmaps, ymaps, xmap, ymap]),2),',')
	return, [0.,0.,1.,1.]
endif

; Initialize plotting preferences
; x,ysize	-	proportion of screen to put panels in
; x,yorigin	-	where to start page from
; l,r,t,bmargin -	left, right, top and bottom margins around plot
;			window as fractions of the panel
; If set_panel_format,/sardines is in force then 
; tmargin=bmargin=0 and move
; things about slightly
if ~keyword_set(xsize) then begin
	IF KEYWORD_SET(bar) THEN $
		xsize = 0.83 $
	else $
		xsize = 0.95
endif
if ~keyword_set(ysize) then begin
	IF KEYWORD_SET(no_title) THEN $
		ysize = 0.93 $
	else if keyword_set(with_info) then $
		ysize = 0.7 $
	else $
		ysize = 0.83
endif
if n_elements(xorigin) eq 0 then $
	xorigin = 0.03
if n_elements(yorigin) eq 0 then $
	yorigin = 0.05

lmargin = 0.10
rmargin = 0.05
tmargin = 0.10
bmargin = 0.15

; guppies or sardines
fmt = get_format(sardines=sd, square=sq, tokyo=ty)
IF sd THEN BEGIN
	tmargin = 0.03
	bmargin = 0.03
	ysize   = ysize/1.1
	yorigin = 0.1
ENDIF
; tokyo or kansas
IF ty THEN BEGIN
	lmargin = 0.03
	rmargin = 0.03
	xsize   = xsize/1.1
	xorigin = 0.1
ENDIF
	
; Calculate size of each panel
xframe = xsize/xmaps
yframe = ysize/ymaps	

; If /SQUARE option is set then constrain plotting window to be square -
; recalculate xframe and yframe accordingly, taking into account the
; device aspect ratio
IF KEYWORD_SET(square) OR sq THEN $
	aspect_ratio = float(!D.Y_SIZE)/float(!D.X_SIZE) $
else if keyword_set(aspect) then $
	aspect_ratio = aspect*float(!D.Y_SIZE)/float(!D.X_SIZE)

if keyword_set(aspect_ratio) then begin
	; calculate size of plotting area
	xpanel = xframe*(1.-lmargin-rmargin)
	ypanel = yframe*(1.-tmargin-bmargin)
	; check if total width when using aspect ratio
	; on panel width would exceed total width
	; if yes, make height smaller
	IF xmaps*ypanel*aspect_ratio/(1.-lmargin-rmargin) GT xsize THEN $
		ypanel = xpanel/aspect_ratio $
	ELSE $
		xpanel = ypanel*aspect_ratio
	; calculate size of panel
	xframe = xpanel/(1.-lmargin-rmargin)
	yframe = ypanel/(1.-tmargin-bmargin)
endif

x1 = (xmap + lmargin)*xframe
y1 = (ymaps - ymap - 1. + bmargin)*yframe
x2 = (xmap + 1. - rmargin)*xframe
y2 = (ymaps - ymap - tmargin)*yframe

; If panels are forced square, then centre plotting area
IF KEYWORD_SET(NO_CENTRE) THEN BEGIN
	xcentre = 0.
	ycentre = 0.
ENDIF ELSE BEGIN
	xcentre = (xsize - xframe*xmaps)*0.5
	ycentre = (ysize - yframe*ymaps)*0.5
ENDELSE
	
pos = [ $
	x1+xcentre+xorigin, $
	y1+ycentre+yorigin, $
	x2+xcentre+xorigin, $
	y2+ycentre+yorigin $
]

if ~keyword_set(noset) then $
  set_recent_panel, xmaps, ymaps, xmap, ymap

return, pos

END
