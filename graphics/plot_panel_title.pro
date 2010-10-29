;+ 
; NAME: 
; PLOT_PANEL_TITLE
; 
; PURPOSE: 
; This procedure plots a more specific title on the top of any panel.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; PLOT_PANEL_TITLE
;
; OPTIONAL INPUTS:
; Xmaps: The total number of columns of plots on the resulting page.
; Default is 1.
;
; Ymaps: The total number of rows of plots on the resulting page.
; Default is 1.
;
; Xmap: The current horizontal (column) index of this panel.
; Default is 0.
;
; Ymap: The current vertical (row) index of this panel.
; Default is 0.
;
; KEYWORD PARAMETERS:
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
pro plot_panel_title, xmaps, ymaps, xmap, ymap, $
	lefttitle=lefttitle, righttitle=righttitle, $
	charsize=charsize, charthick=charthick, bar=bar, aspect=aspect

if n_params() lt 4 then begin
	if ~keyword_set(silent) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

pos = define_panel(xmaps, ymaps, xmap, ymap, aspect=aspect, bar=bar)
foreground  = get_foreground()

fmt = get_format(sardines=sd)
if sd then $
	ypos = pos[3]-.02 $
else $
	ypos = pos[3]+.01

if keyword_set(lefttitle) then $
	xyouts, pos[0]+0.01, ypos, $
		lefttitle, /NORMAL, $
		COLOR=foreground, SIZE=charsize, charthick=charthick

if keyword_set(righttitle) then $
	xyouts, pos[2]-0.01, ypos, $
		righttitle, $
		/NORMAL, COLOR=foreground, SIZE=charsize, charthick=charthick, align=1.

end
