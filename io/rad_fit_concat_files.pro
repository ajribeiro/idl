function rad_fit_concat_files, files, $
	fitex=fitex, fitacf=fitacf, oldfit=oldfit, $
	silent=silent

outdir = getenv('RAD_TMP_PATH')
if strlen(outdir) eq 0 then $
	outdir = getenv('HOME')
outdir += '/'

if ~file_test(outdir, /dir) then begin
	prinfo,'Cannot find directory to put zipped files.'
	return, ''
endif

fc = n_elements(files)
o_files = strarr(fc)
ending = ''

if ~keyword_set(silent) then $
	prinfo, 'Concatenating'

for i=0, fc-1 do begin
	o_files[i] = rad_unzip_file(files[i])
	if strcmp(o_files[i], '') then $
		continue
	tmp = strsplit(file_basename(o_files[i]), '.', /extract)
	ntmp = n_elements(tmp)
	if ntmp lt 2 then begin
		prinfo, 'File is weird: '+o_files[i]
		return, ''
	endif
	if i eq 0 then $
		ending = tmp[ntmp-1] $
	else begin
		if ~strcmp(ending, tmp[ntmp-1], /fold) then begin
			prinfo, 'File endings do not match: '+o_files[i]
			return, ''
		endif
	endelse
	if ~keyword_set(silent) then $
		prinfo, '  '+files[i]+' -> '+o_files[i], /force
endfor

jo_files = strjoin(o_files, ' ')
ret_file = outdir+'concat'+strtrim(string(systime(/sec), format='(I11)'),2)+'.'+ending

; check if file exists
; if yes, add five random characters to the file name
; until the new filename is not found in the
; output directory
while file_test(ret_file) do begin
	random_char = string(byte(randomu(systime(/sec), 5)*25.)+97b)
	ret_file = outdir+'concat'+strtrim(string(systime(/sec), format='(I11)'),2)+random_char+'.'+ending
endwhile

if keyword_set(fitacf) or keyword_set(fitex) then $
	spawn, 'cat '+jo_files+' > '+ret_file $
else $
	spawn, 'cat_fit '+jo_files+' '+ret_file

file_delete, o_files

return, ret_file

end