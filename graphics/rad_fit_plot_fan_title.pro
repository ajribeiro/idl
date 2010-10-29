;+ 
; NAME: 
; RAD_FIT_PLOT_FAN_TITLE
; 
; PURPOSE: 
; This procedure plots a more specific title on the top of a fan panel.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; RAD_FIT_PLOT_FAN_TITLE
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
pro rad_fit_plot_fan_title, xmaps, ymaps, xmap, ymap, $
	scan_id=scan_id, scan_startjul=scan_startjul, $
	charsize=charsize, charthick=charthick, bar=bar, aspect=aspect

prinfo, 'DEPRECATED. Use RAD_FIT_PLOT_SCAN_TITLE.'

rad_fit_plot_scan_title, xmaps, ymaps, xmap, ymap, $
	scan_id=scan_id, scan_startjul=scan_startjul, $
	charsize=charsize, charthick=charthick, bar=bar, aspect=aspect

prinfo, 'DEPRECATED. Use RAD_FIT_PLOT_SCAN_TITLE.'

end
