;+ 
; NAME: 
; RAD_FIT_PLOT_SCAN_TITLE
; 
; PURPOSE: 
; This procedure plots a more specific title on the top of a fan panel.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; RAD_FIT_PLOT_SCAN_TITLE
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
; SCAN_ID: Set this keyword to the numeric scan id to plot in the title.
; 
; SCAN_STARTJUL: Set this keyword to the start julian day number of the scan.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
pro rad_fit_plot_scan_title, xmaps, ymaps, xmap, ymap, $
	scan_id=scan_id, scan_startjul=scan_startjul, $
	charsize=charsize, charthick=charthick, bar=bar, aspect=aspect

common rad_data_blk

; get index for current data
data_index = rad_fit_get_data_index()
if data_index eq -1 then $
	return

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

if ~keyword_set(scan_id) then $
	scan_id = (*rad_fit_info[data_index]).scan_ids[0]

if ~keyword_set(scan_startjul) then $
	scan_startjul = (*rad_fit_info[data_index]).juls[0]

odate = format_juldate(scan_startjul,/time)

plot_panel_title, xmaps, ymaps, xmap, ymap, $
	lefttitle=odate, righttitle='('+STRTRIM(string(scan_id),2)+')', $
	charsize=charsize, charthick=charthick, bar=bar, aspect=aspect

end
