;+ 
; NAME: 
; PS_CLOSE
; 
; PURPOSE: 
; This procedure closes the currently open PostScript file. 
;
; It will also call PS_WRITE_CREATOR which will add
; some comments into the written PostScript file, giving the name of the 
; IDL source file that created the plot. Such you can avoid situations where
; you find a plot and have no idea which program produced it.
; 
; CATEGORY: 
; PostScript
; 
; CALLING SEQUENCE: 
; PS_CLOSE
;
; KEYWORD PARAMETERS:
; SILENT: Set this keyword to surpress messages about the closed file.
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by: Lasse Clausen, 2007.
;-
pro ps_close, silent=silent, nofilename=nofilename

IF ~ps_get_isopen() THEN begin
	prinfo, 'PostScript is not enabled'
	return
endif

set_plot, 'ps'
; write filename into file so that when you just have a hard copy of it, you still know what the fielname was
if ~keyword_set(nofilename) then $
	xyouts, .93, .02, ps_get_filename(), align=1., charsize=.5, /norm
device, /close
ps_set_isopen, !false
if ~keyword_set(silent) then $
	prinfo, 'Closed ', ps_get_filename()
ps_write_creator, force_paper_size='Letter'

ps_set_filename, ''
set_plot, 'X'

!p.font = -1

; update colors, especially
; background and foreground
init_colors

end
