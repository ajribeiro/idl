;+ 
; NAME: 
; KPI_READ
;
; PURPOSE: 
; This procedure reads KP index data into the variables of the structure KPI_DATA in
; the common block KPI_DATA_BLK. The time range for which data is read is controled by
; the DATE and TIME keywords.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; KPI_READ, Date
;
; INPUTS:
; Date: The date of which to read data. Can be a scalar in YYYYMMDD format or
; a 2-element vector in YYYYMMDD format.
;
; KEYWORD PARAMETERS:
; TIME: The time range for which to read data. Must be a 2-element vector in 
; HHII format, or HHIISS format if the LONG keyword is set. If TIME is not set
; the default value [0000,2400] is assumed.
;
; LONG: Set this keyword to indicate that the Time value is in HHIISS
; format rather than HHII format.
;
; SILENT: Set this keyword to surpress warnings but not error messages.
;
; PROCEDURE:
; If Date is a scalar
; and Time[0] < Time[1], the interval stretches from Time[0] on Date to Time[1] 
; on Date. If Time[0] > Time[1], the interval stretches from Time[0] on Date to
; Time[1] on the day after Date. If Date is a two element vector, the interval
; stretches from Time[0] on Date[0] to Time[1] on Date[1].
;
; COMMON BLOCKS:
; KPI_DATA_BLK: The common block holding the currently loaded radar data and 
; information about that data.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Based on Steve Milan's READ_FILES.
; Written by Lasse Clausen, Nov, 24 2009
;-
pro kpi_read, date, time=time, long=long, $
	silent=silent, force=force

common kpi_data_blk

; set nrecs to zero such that 
; you have a way of checking
; whether data was loaded.
kpi_info.nrecs = 0L

; check if parameters are given
if n_params() lt 1 then begin
	prinfo, 'Must give date.'
	return
endif

if ~keyword_set(force) && kpi_check_loaded(date, time=time, long=long) then $
	return

; set deault time if neccessary
if ~keyword_set(time) then $
	time = [0000,2400]

if size(date, /type) eq 7 then begin
	parse_str_date, date, ndate
	if n_elements(ndate) eq 0 then $
		return
	date = ndate
endif

sfjul, date, time, sjul, fjul, no_months=nm
caldat, sjul, mm, dd, yy, hh, ii, ss

tmp_kpi  = make_array(8L*31L*nm, /float, value=-9999.)
tmp_juls = make_array(8L*31L*nm, /double, value=-9999.d)

for i=0L, nm-1L do begin

	caldat, julday(mm+i, 01, yy), nmm, dd, nyy

	ad = (nyy mod 100L)*100L + nmm
	str_date = string(ad,format='(I04)')
	
	if ~keyword_set(datdi) then $
		adatdi = kpi_get_path(nyy) $
	else $
		adatdi = datdi

	if ~file_test(adatdi, /dir) then begin
		prinfo, 'Data directory does not exist: ', adatdi, /force
		continue
	endif

	filename = file_select(adatdi+'/kp'+str_date+'.tab', $
		success=success)
	if ~success then begin
		prinfo, 'Data file not found.'
		continue
	endif
	
	if ~keyword_set(silent) then $
		prinfo, 'Reading ', filename
	
	tkpi = fltarr(8*31)
	tdate = 0L
	tlkpi = strarr(8)
	openr, il, filename, /get_lun
	for k=0, (days_in_month(nmm, year=nyy))[0]-1 do begin
		readf, il, tdate, tlkpi, $
			format='(I6,2(1X,4(A3)))'
		tkpi[k*8:(k+1)*8-1] = str2kpi(tlkpi)
	endfor
	free_lun, il
	
	tmp_kpi[i*8L*31L:(i+1L)*8L*31L-1L] = tkpi
	;tt = timegen(start=julday(nmm, 1, nyy, 0), final=julday(nmm+1, 1, nyy, 0, 1), $
	;	unit='H', step=3)
	tt = timegen(start=julday(nmm, 1, nyy, 0, 0, 0), final=julday(nmm+1, 0, nyy, 21, 0, 0), $
		unit='H', step=3)
	ntt = n_elements(tt)
	tmp_juls[i*8L*31L:i*8L*31L+ntt-1L] = tt

endfor

good = where(tmp_juls gt -9999.d, ng)
if ng eq 0 then $
	return
tjuls = tmp_juls[good]
tkpi  = tmp_kpi [good]

jinds = where(tjuls ge sjul and tjuls le fjul, cc)
if cc eq 0 then begin
	prinfo, 'No data found.'
	return
endif

juls = tjuls[jinds]
kpi  = tkpi [jinds]

tkpi_data = { $
	juls: dblarr(cc), $
	kp_index: fltarr(cc) $
}

tkpi_data.juls = juls
tkpi_data.kp_index = kpi
kpi_data = tkpi_data

kpi_info.sjul = juls[0L]
kpi_info.fjul = juls[cc-1L]
kpi_info.nrecs = cc

end
