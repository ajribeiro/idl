pro strip_auleo, filename

if n_params() eq 0 then begin
	prinfo, 'Give filename.'
	return
endif

if n_elements(filename) gt 1 then begin
	for i=0, n_elements(filename)-1 do $
		strip_aeluo, filename[i]
	return
endif

if ~file_test(filename) then begin
	prinfo, 'Cannot find file: '+filename
	return
endif

ayr = 0
amn = 0
ady = 0
ahr = 0
ind = ''
des = ''
hr_vals = lonarr(60)

format = '(12X,3(I2),1X,I2,A2,A11,60I6)'

nlines = file_lines(filename)
oyr = -1

openr, il, filename, /get_lun
for i=0L, nlines-1L do begin
	readf, il, ayr, amn, ady, ahr, ind, des, hr_vals, $
		format=format
	if ayr lt 20 then $
		ayr += 2000 $
	else $
		ayr += 1900
	; sometimes the input file contains data from more than one year
	; make sure that only one year is worked on
	if oyr eq -1 then $
		oyr = ayr
	if ayr ne oyr then $
		continue
	openw, ol, string(ayr,format='(i4)')+string(amn, format='(i02)')+'_'+strlowcase(ind)+'.dat', /append, /get_lun
	printf, ol, ayr, amn, ady, ahr, hr_vals, format='(I4,3(1X,I02),1X,60I6)'
	free_lun, ol
;	print, ind
;	break
endfor
free_lun, il

end