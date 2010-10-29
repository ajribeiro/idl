;+ 
; NAME: 
; DEFINE_CB_POSITION
; 
; PURPOSE: 
; This function calculates the position for a colorbar right or above an input plot position
; in normalized coordinates. 
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; Result = DEFINE_CB_POSITION(Inpos)
;
; INPUTS:
; Inpos: A 4-element vector holding the position of the plot next to which the colorbar 
; will be placed. In 
; Normalized coordinates.
;
; KEYWORD PARAMETERS:
; GAP: Set this keyword to the size of the gap in normalized coordinates between the 
; plot and the colorbar (default is 5% of the panel width).
;
; WIDTH: Set this keyword to the width of the colorbar in normalized coordinates.
; Default is 0.015
; 
; VERTICAL: Set this keyword to indicate that the colorbar will be placed vertically
; right of the plot. This is the default.
;
; HORIZONTAL: Set this keyword to indicate that the colorbar will be placed horizontally,
; above the plot.
;
; HEIGHT: Set this keyword to the height of the colorbar in per cent of the height of the panel.
; Default is 90% of the panel height.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 24 2009
;-
function define_cb_position, inpos, gap=gap, width=width, $
	horizontal=horizontal, vertical=vertical, height=height

if n_params() lt 1 then begin
	prinfo, 'Must give Inpos.'
	return, [-1., -1., -1., -1.]
endif

if n_elements(gap) lt 1 then $
	gap = .05*(inpos[2]-inpos[0])

if ~keyword_set(width) then $
	width = .015

if ~keyword_set(horizontal) and ~keyword_set(vertical) then $
	vertical = 1

if ~keyword_set(height) then $
	height = 90.

pheight = (inpos[3]-inpos[1])
pwidth  = (inpos[2]-inpos[0])

if keyword_set(vertical) then $
	return, [inpos[2]+gap, $
		inpos[1]+pheight*(1.-float(height)/100.)/2., $
		inpos[2]+gap+width, $
		inpos[3]-pheight*(1.-float(height)/100.)/2.] $
else $
	return, [inpos[0]+pwidth*(1.-float(height)/100.)/2., $
		inpos[3]+gap, $
		inpos[2]-pwidth*(1.-float(height)/100.)/2., $
		inpos[3]+gap+width]

end
