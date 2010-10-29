;+ 
; NAME: 
; PS_OPEN 
; 
; PURPOSE: 
; This procedure opens a PostScript file for plotting.
; 
; CATEGORY: 
; PostScript
; 
; CALLING SEQUENCE: 
; PS_OPEN, Filename
; 
; INPUTS: 
; Filename: The full filename (i.e. inlcuding path) of the PostScript
; file to open.
;
; If the path to the output file does not exist, this procedure will look whether the
; environment variable PS_PATH is set to a valid path. If yes, then the output
; file is placed there. If not, then the file is placed in ~/.
;
; If no filename is given, ~/piccy.ps is the default.
;
; KEYWORD PARAMETERS:
; COLOR: Set this keyword to indicate that the PostScript file supports colours.
;
; COLOR: Set this keyword to indicate that the PostScript file supports colors.
;
; BW: Set this keyword to indicate that the PostScript file supports only Black/White.
;
; SILENT: Set this keyword to surpress messages about the opened file.
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by: Lasse Clausen, 2007.
;-
pro ps_open, filename, color=color, bw=bw, silent=silent
	
IF N_PARAMS() EQ 0 THEN $
	filename = getenv('PS_OUTPUT_PATH')+'/piccy.ps'

if file_dirname(filename) eq '.' and ~strmatch(filename, './*') then $
		filename = getenv('PS_OUTPUT_PATH')+'/'+file_basename(filename)
odir = file_dirname(filename)

if ~file_test(odir, /dir) then begin
	if ~keyword_set(silent) then $
		prinfo, 'Output directory does not exist: '+file_dirname(filename), /force
	if ~file_test(getenv('PS_OUTPUT_PATH'), /dir) then $
		filename = '~/'+file_basename(filename) $
	else $
		filename = getenv('PS_OUTPUT_PATH')+'/'+file_basename(filename)
endif

SET_PLOT, 'ps'
if keyword_set(bw) then $
	DEVICE, FILENAME=filename, /HELVETICA, /BW, BITS=8 $
else $
	DEVICE, FILENAME=filename, /HELVETICA, /COLOR, BITS=8

!p.font = -1

ps_set_filename, filename
ps_set_isopen, !true

; set format of postscript file
fmt = get_format(landscape=ls)
if ls then $
	set_format, /landscape $
else $
	set_format, /portrait

; update colors, especially
; background and foreground
init_colors

if ~keyword_set(silent) then $
	prinfo, 'Opened ', filename
	
END
