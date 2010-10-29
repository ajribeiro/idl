pro strip_symh, filename

if n_params() eq 0 then begin
	prinfo, 'Give filename.'
	return
endif

if n_elements(filename) gt 1 then begin
	for i=0, n_elements(filename)-1 do $
		strip_symh, filename[i]
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
cmp = ''
ind = ''
des = ''
hr_vals = lonarr(60)

;COLUMN	FORMAT 	SHORT DESCRIPTION
;1-12 	A12 	FILLER (IDENTIFIER) VALUE 'ASYSYM N6E01'
;13-14 	I2 	THE LAST TWO DIGITS OF THE YEAR
;15-16 	I2 	MONTH '01' TO '12'
;17-18 	I2 	DAY OF THE MONTH '01' TO '31'
;19	A1 	COMPONENT 'D' FOR D-comp. / 'H' FOR H-comp.
;20-21 	I2 	HOUR UT, '00' TO '23'
;22-24 	A3 	NAME OF INDEX, 'ASY'/'SYM'
;25-34 	A10 	FILLER (EDITION NUMBER) VALUE 'WDCC2KYOTO'
;35-394 	60I6 	60 ONE MINUTE VALUES , UNIT 1nT. VALUE ' 99999' FOR THE MISSING DATA
;( 35 40 ONE MINUTE VALUE FOR THE FIRST MINUTE OF THE HOUR)
;(389 394 ONE MINUTE VALUE FOR THE LAST MINUTE OF THE HOUR)
;395-400 	I6 	HOURLY MEAN VALUE. VALUE ' 99999' FOR THE MISSING DATA

format = '(12X,3(I2),A1,I2,A3,A10,60I6)'

nlines = file_lines(filename)
oyr = -1

openr, il, filename, /get_lun
for i=0L, nlines-1L do begin
	readf, il, ayr, amn, ady, cmp, ahr, ind, des, hr_vals, $
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
;	if amn eq 1 and ady eq 1 then $
;		print, ayr, amn, ind, cmp, string(ayr,format='(i4)')+string(amn, format='(i02)')+'_'+strlowcase(ind)+strlowcase(cmp)+'.dat'
	openw, ol, string(ayr,format='(i4)')+string(amn, format='(i02)')+'_'+strlowcase(ind)+strlowcase(cmp)+'.dat', /append, /get_lun
	printf, ol, ayr, amn, ady, ahr, hr_vals, format='(I4,3(1X,I02),1X,60I6)'
	free_lun, ol
;	print, ind
;	break
endfor
free_lun, il

end