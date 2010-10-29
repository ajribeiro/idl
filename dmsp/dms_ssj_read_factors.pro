pro dms_ssj_read_factors, sat, year, facts, path=path

if sat lt 6 or sat gt 18 or year gt 2010 or year lt 1983 then begin
	prinfo, '1983 <= year <= 2010 and 6<= sat <= 18'
	return
endif

IF ~keyword_set(path) THEN $
	path = getenv('RAD_RESOURCE_PATH')

if ~file_test(path, /dir) then begin
	prinfo, 'Cannot find path to DMSP calibration files.'
	return
endif
factors_fname = path + '/ssj_factors.dat'
if ~file_test(factors_fname) then begin
	prinfo, 'Cannot find DMSP calibration file: '+factors_fname
	return
endif
corrections_fname = path + '/j4_yearly_corrections.dat'
if ~file_test(corrections_fname) then begin
	prinfo, 'Cannot find DMSP calibration file: '+corrections_fname
	return
endif

openr, ilun, factors_fname, /get_lun
if ilun eq -1 then begin
	prinfo, 'Error opening conversion factors file: '+factors_fname
	return
endif

facts= { eeng:fltarr(20),ieng:fltarr(20), $
	ewid:fltarr(20),iwid:fltarr(20), $
	gfe:fltarr(20), gfi:fltarr(20),  $
	k1e:fltarr(20), k2e:fltarr(20),  $
	k1i:fltarr(20), k2i:fltarr(20) }

eeng1 = fltarr(10)
eeng2 = fltarr(10)
ieng1 = fltarr(10)
ieng2 = fltarr(10)
ewid1 = fltarr(10)
ewid2 = fltarr(10)
iwid1 = fltarr(10)
iwid2 = fltarr(10)
gfe1 = fltarr(10)
gfe2 = fltarr(10)
gfi1 = fltarr(10)
gfi2 = fltarr(10)
k1e1 = fltarr(10)
k1e2 = fltarr(10)
k2e1 = fltarr(10)
k2e2 = fltarr(10)
k1i1 = fltarr(10)
k1i2 = fltarr(10)
k2i1 = fltarr(10)
k2i2 = fltarr(10)

line = ""
sat_num = -5
WHILE sat_num NE sat and ~EOF(ilun) DO BEGIN
;	line = ""
;	readf, ilun, line
;	reads, line, sat_num
	readf, ilun, sat_num
	readf, ilun, eeng1
	readf, ilun, eeng2
	readf, ilun, ieng1
	readf, ilun, ieng2
	readf, ilun, ewid1
	readf, ilun, ewid2
	readf, ilun, iwid1
	readf, ilun, iwid2
	readf, ilun, gfe1
	readf, ilun, gfe2
	readf, ilun, gfi1
	readf, ilun, gfi2
	readf, ilun, k1e1
	readf, ilun, k1e2
	readf, ilun, k2e1
	readf, ilun, k2e2
	readf, ilun, k1i1
	readf, ilun, k1i2
	readf, ilun, k2i1
	readf, ilun, k2i2
ENDWHILE
free_lun, ilun

line = ""
; create correction factor array to contain factors for
;   EHI, ELO, IHI, ILO
factors = fltarr(4)

info = intarr(3)
openr, ilun, corrections_fname, /get_lun
if ilun eq -1 then begin
	prinfo, 'Error opening correction factors file: '+corrections_fname
	return
endif
; skip first line
readf, ilun, line
cnum = -5
WHILE sat_num NE cnum AND ~EOF(ilun) DO BEGIN
	; read in the satellite number and years
	readf, ilun, info
	cnum = info[0]
	IF (cnum EQ sat) THEN BEGIN
		if (year LT info[1]) THEN $
			info[2] = info[1]
		if ((year LT info[2]) AND (year GE info[1])) THEN $
			info[2] = year
	ENDIF
	FOR i = info[1], info[2] DO $
		readf, ilun, factors
ENDWHILE
free_lun, ilun

FOR i = 0,3 DO $
	IF ((factors[i] GT  1.) OR (factors[i] LE 0.001)) THEN $
		factors[i] = 1.

	FOR i=0,9 DO BEGIN
		facts.eeng[i] = eeng1[i]
		facts.eeng[10+i] = eeng2[i]
		facts.ieng[i] = ieng1[i]
		facts.ieng[10+i] = ieng2[i]
		facts.ewid[i] = ewid1[i]
		facts.ewid[10+i] = ewid2[i]
		facts.iwid[i] = iwid1[i]
		facts.iwid[10+i] = iwid2[i]
		facts.gfe[i] = gfe1[i] * factors[1]
		facts.gfe[10+i] = gfe2[i] * factors[0]
		facts.gfi[i] = gfi1[i] * factors[3]
		facts.gfi[10+i] = gfi2[i] * factors[2]
		facts.k1e[i] = k1e1[i] / factors[1]
		facts.k1e[10+i] = k1e2[i] / factors[0]
		facts.k2e[i] = k2e1[i] / factors[1]
		facts.k2e[10+i] = k2e2[i] / factors[0]
		facts.k1i[i] = k1i1[i] / factors[3]
		facts.k1i[10+i] = k1i2[i] / factors[2]
		facts.k2i[i] = k2i1[i] / factors[3]
		facts.k2i[10+i] = k2i2[i] * factors[2]
ENDFOR

end
