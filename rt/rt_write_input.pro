;+ 
; NAME: 
; RT_WRITE_INPUT
;
; PURPOSE: 
; This procedure generates input file for raytracing code
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; RT_WRITE_INPUT
;
; INPUTS:
; RADAR: the radar code for which you want to run the raytracing
;
; KEYWORD PARAMETERS:
; DATE
; FREQ
; BEAM
; OUTDIR
; FILENAME
; EL_BEG
; EL_END
; EL_STP
;
; KEYWORDS:
;
; COMMON BLOCKS:
; RADARINFO
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Written by Sebastien de Larquier, Sept. 2010
;	Last modified 17-09-2010
;-
PRO	rt_write_input, radar, date=date, freq=freq, beam=beam, outdir=outdir, filename=filename, $
	    el_beg=el_beg, el_end=el_end, el_stp=el_stp

common radarinfo

print, 'Generating input file for raytracing'

; Read radar location and boresight
radID = where(network.code[0,*] eq radar)
radarsite = network[radID].site[where(network[radID].site.tval eq -1)]

if ~keyword_set(outdir) then $
  outdir = '/tmp'

if ~file_test(outdir, /dir) then begin
  prinfo, 'Output directory does not exist: '+outdir
  return
endif

if ~keyword_set(filename) then $
  filename = 'Input'+radar+STRTRIM(date,2)+STRTRIM(beam)+'.inp'

davit_lib = getenv("DAVIT_LIB")
; Read base input file
openr, unit, davit_lib+'/vt/rt/IRI/Input_LowLevel.inp', /get_lun

; Skip first 1st line and read next 5 lines
bla = ''
readf, unit, bla, format='(A)'
fmt_mod	= '(I3/I3/I3/I3/I3)'
data_mod= intarr(5)
readf, unit, data_mod, format=fmt_mod

; Then go on until end of file
fmt 	= '(I3,E14.7,5I1)'
tdata 	= {ID:0S, VAL:0.0, CONV:intarr(5)}
data 	= REPLICATE(tdata,400)
j = 0
status = FSTAT(unit)
POINT_LUN, -unit, pos 
WHILE (~EOF(unit) AND pos lt status.size - 6) DO BEGIN
	readf, unit, tdata, format=fmt
	data[j] = tdata
	j++
	POINT_LUN, -unit, pos 
ENDWHILE

free_lun, unit

; Set new radar position
data[where(data.ID eq 4)].VAL = radarsite.geolat
data[where(data.ID eq 5)].VAL = radarsite.geolon
data[where(data.ID eq 11)].VAL = radarsite.boresite
data[where(data.ID eq 12)].VAL = radarsite.boresite

; Set qzimuth (waiting for a real beam selection)
if keyword_set(beam) then begin
	az = rt_get_azim(radar, beam)
	data[where(data.ID eq 11)].VAL = az 
	data[where(data.ID eq 12)].VAL = az
endif
print,radar+':', data[where(data.ID eq 4)].VAL, data[where(data.ID eq 5)].VAL, data[where(data.ID eq 11)].VAL


; Set new radar frequency
if keyword_set(freq) then $
	data[where(data.ID eq 7)].VAL = freq

; Set new elevation range
if (keyword_set(el_beg) OR keyword_set(el_end)) then BEGIN
	if ~keyword_set(el_beg) OR ~keyword_set(el_end) THEN BEGIN
		print, 'You need to provide first, last and step elevation' 
		return
	endif
	data[where(data.ID eq 15)].VAL = el_beg 
	data[where(data.ID eq 16)].VAL = el_end 
endif

if keyword_set(el_stp) THEN $
	data[where(data.ID eq 17)].VAL = el_stp
  
; Write input file
openw, unit, outdir+'/'+filename, /get_lun

printf, unit, bla 
printf, unit, data_mod, format=fmt_mod
FOR i=0, j DO BEGIN
	tdata = data[i]
	printf, unit, tdata, format=fmt
ENDFOR

free_lun, unit

END