pro user_prefs_read

pfile = getenv('DAVIT_PREFS')
if strlen(pfile) ne 0 then begin
	if ~file_test(pfile) then begin
		prinfo, 'Cannot find user preference file: '+pfile
		return
	endif
	if ~file_test(pfile, /read) then begin
		prinfo, 'Cannot read user preference file: '+pfile
		return
	endif
	line = ''
	openr, ilun, pfile, /get_lun
	lcount = 0L
	while ~eof(ilun) do begin
		readf, ilun, line
		lcount += 1L
		line = strtrim(line, 2)
		if strlen(line) eq 0 then $
			continue
		if strmid(line, 0, 1) eq ';' then $
			continue
		tmp = strsplit(line, ';', /extract)
		d = execute(tmp[0]);, 1, 1)
		if d eq 0 then $
			prinfo, 'Error in user preference file in line '+strtrim(string(lcount),2)+' ('+pfile+')', /force
	endwhile
	free_lun, ilun
endif else begin
	print, '  -------------------------------------------------------'
	print, '  > You can set set IDL user preferences by creating an <'
	print, '  > environment variable called DAVIT_PREFS and having  <'
	print, '  > it point to a file containing IDL instructions, one <'
	print, '  > per line.                                           <'
	print, '  > So if you like the standard character thickness to  <'
	print, '  > be 3 instead of 1, create a file and write          <'
	print, '  > !p.charthick = 3 in it and have DAVIT_PREFS point   <'
	print, '  > to that file.                                       <'
	print, '  > Get it?                                             <'
	print, '  -------------------------------------------------------'
endelse

; help, lala2

end