;+ 
; NAME: 
; PRINFO
; 
; PURPOSE: 
; This procedure prints information to the standard output, i.e. the window
; in which IDL runs. The message is prefaced by the procedure/function in which PRINFO was
; called and is shorted if it is longer than
; GETENV('RAD_DISPLAY_CHAR_WIDTH').
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE: 
; PRINFO, Message
;
; INPUTS:
; Str_message: A string containing the message you want to display.
;
; OPTIONAL INPUTS:
; Filename: Use this input to supply a filename is messages like "File not found:
; somedir/someotherdir/somefilename.dat".
;
; KEYWORD PARAMETERS:
; FORCE: Set this to prevent message shortening.
; 
; MODIFICATION HISTORY: 
; Written by: Lasse Clausen, 2009
;-
pro prinfo, str_message, filename, force=force

if n_params() lt 1 then begin
	prinfo, 'Must give Str_message.'
	return
endif

routs = scope_traceback()
nrouts = n_elements(routs)
if nrouts lt 2 then $
	caller = (strsplit(routs[nrouts-1], ' ',/extract))[0] $
else $
	caller = (strsplit(routs[nrouts-2], ' ',/extract))[0]
pre_message = '% '+caller+': '

if n_params() lt 2 then $
	filename = ''

pnum = strlen(pre_message)
snum = strlen(str_message)
fnum = strlen(filename)
cnum = fix(getenv('RAD_DISPLAY_CHAR_WIDTH'))

mnum = pnum+snum+fnum

if mnum gt cnum and ~keyword_set(force) then begin
	if fnum gt 0 then begin
		rnum = cnum-(pnum+snum+5)
		tot_message = pre_message+str_message+$
			strmid(filename,0,floor(rnum/3.))+'[...]'+strmid(filename, fnum-ceil(rnum*2./3.))
	endif else begin
		rnum = cnum-(pnum+5)
		tot_message = pre_message+$
			strmid(str_message,0,floor(rnum/3.))+'[...]'+strmid(str_message, snum-ceil(rnum*2./3.))
	endelse
endif else if mnum lt cnum then begin
	tot_message = pre_message+strjoin(replicate(' ',((cnum-mnum)/2) > 1))+str_message+filename
endif else $
	tot_message = pre_message+str_message+filename

print, tot_message

end

; verizon
; 301 282 0539
; 747726585
; 888 762 3585
