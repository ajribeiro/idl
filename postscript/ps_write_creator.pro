;+ 
; NAME: 
; PS_WRITE_CREATOR
; 
; PURPOSE: 
; This procedure writes a small comment into the header of a PostScript file.
; This enables the user to identify the program name that created that
; particular PostScript.
;
; It will also add the PostScript comment %%Orientation, because IDL does not 
; routinely add it.
;
; Basically, the contents of the call stack
; is written into the file. That works because PostScript files are
; ASCII files.
;
; This routine writes the comment by reading the original PostScript file
; line by line, adding the comment at the right place. This can take long
; (a couple of seconds) if your PostScript file is several MB big.
;
; The comment might look like this:
; %CreatorScript: At PS_WRITE_CREATOR   36 /home/lbnc1/idl_lib/graphics/ps_write_creator.pro
; %CreatorScript: PS_CLOSE2           3 /home/lbnc1/idl_lib/graphics/ps_close2.pro
; %CreatorScript: PLOT_ACE2         340 /home/lbnc1/idl_lib/graphics/plot_ace2.pro
; %CreatorScript: $MAIN$             11 /home/lbnc1/idl/tim.pro
;
; The above comment tells me that the comment (and hence the plot) was 
; created by PLOT_ACE2 which was called by $MAIN$, located in tim.pro.
; 
; CATEGORY: 
; PostScript
; 
; CALLING SEQUENCE: 
; PS_WRITE_CREATOR, Filename
;
; INPUTS:
; Filename: The full filename (including path) of the PostScript file into
; which the header will be inserted.
;
; KEYWORD PARAMETERS:
; FORCE_PAPER_SIZE: Set this keyword to Letter or A4 depending on what paper size
; you want to force. Use this carefully! If DocumentPaperSizes is set to A4 and 
; someone in the US, where Letter is standard, tries to print
; this document, this will not work! The printer will ask for 
; A4 paper before printing. The only use is when your postscript
; renderer on your computer ignores output outside the BoundingBox
; and you want to make sure that you can see it.
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by: Lasse Clausen, 2007.
;-
pro ps_write_creator, filename, force_paper_size=force_paper_size

if n_params() ne 1 then $
	fname = ps_get_filename() $
else $
	fname = filename

supported_paper_sizes = ['A4', 'Letter']

if keyword_set(force_paper_size) then begin
	tmp = where(supported_paper_sizes eq force_paper_size)
	if tmp[0] eq -1 then $
		prinfo, 'FORCE_PAPER_SIZE set but ignored.' $
	else $
		spapersize = '%%DocumentPaperSizes: '+strtrim(force_paper_size,2)
endif

; find caller function/routine
help, /traceback, output=hout
creator = strtrim(strmid(hout,4),2)

; do some testing
; nothing of the following should go wrong
if ps_get_isopen() then begin
	prinfo, 'Cannot write comment: File is still open.'
	return
end

if ~file_test(fname) then begin
	prinfo, 'Cannot write comment: File does not exist.'
	return
end

; open original file
openr, fin, fname, /get_lun, error=ioerr
if ioerr ne 0 then begin
	prinfo, 'Could not open input file: ', fname
	return
end

; open new file
openw, fout, fname+'.new', /get_lun, error=ioerr
if ioerr ne 0 then begin
	prinfo, 'Could not open output file: ', fname+'.new'
	free_lun, fin
	return
end

info_written = !false
end_comments = !false
line = ''

; search for the follwoing line
; %%Creator: IDL Version 
; after which our line is inserted
while ~eof(fin) do begin
	readf, fin, line

	; if end of comments has been reached, just continue writing the 
	; original stuff
	if end_comments then begin
		printf, fout, line
		continue
	endif

	; the Title line has been found, insert filename
	; this makes looking at the file in Evince viewer easier
	if strmatch(line, '%%Title:*') then begin
		printf, fout, line+': '+file_basename(fname)

	; delete old entries of CreatorScript; the Creator line has been found, insert info
	endif else if strmatch(line, '%%Creator:*') then begin
		printf, fout, line
		for i=0, n_elements(creator)-1 do $
			printf, fout, '%CreatorScript: '+creator[i]
			if n_elements(spapersize) eq 1 then $
				printf, fout, spapersize
			fmt = get_format(landscape=ls, portrait=pt)
			if pt then $
				printf, fout, '%%Orientation: Portrait'
			if ls then $
				printf, fout, '%%Orientation: Landscape'
			info_written = !true

	; delete old entries of CreatorScript
	endif else if strmatch(line, '%CreatorScript:*') then begin
		; do nothing
		continue
	; in case no Creator comments is present, look for 
	; EndComments
	endif else if strmatch(line, '%%EndComments*') then begin
		if ~info_written then begin
			for i=0, n_elements(creator)-1 do $
				printf, fout, '%CreatorScript: '+creator[i]
			if n_elements(spapersize) eq 1 then $
				printf, fout, spapersize
			info_written = !true
		endif
		printf, fout, line
		end_comments = !true

	; print all the other header stuff
	endif else $
		printf, fout, line

endwhile
free_lun, fin
free_lun, fout

; effectively rename old file
file_delete, fname
file_move,  fname+'.new', fname

if not(info_written) then $
	prinfo, 'Info could not be written.'

end
