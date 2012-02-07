pro rad_cpid_read_table

common rad_data_blk

ifile = getenv('RAD_RESOURCE_PATH')+'/cpid_names.dat'
if ~file_test(ifile) then begin
	prinfo, 'Cannot find CPID file: '+ifile
	return
endif

nlines = file_lines(ifile)
cpids = intarr(nlines)
names = strarr(nlines)
counter = 0L
aline = ''

openr, ilun, ifile, /get_lun
for i=0L, nlines-1L do begin
	readf, ilun, aline
	aline = strtrim(aline,2)
	if strmid(aline, 0, 1) eq '#' then $
		continue
	tmp = strsplit(aline, byte('	'), /extract)
	if n_elements(tmp) ne 2 then begin
		prinfo, 'Error found in line '+strtrim(string(i),2)+' in '+ifile
		continue
	endif
	cpids[counter] = long(tmp[0])
	names[counter] = strtrim(tmp[1], 2)
	counter += 1L
endfor
free_lun, ilun

cpid_structure = { $
	cpids: intarr(counter), $
	names: strarr(counter) $
}
cpid_structure.cpids = cpids[0L:counter-1L]
cpid_structure.names = names[0L:counter-1L]

end