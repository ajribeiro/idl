;+ 
; NAME: 
; RAD_FIT_GET_SCAN
; 
; PURPOSE: 
; This function returns an [nb, ng] array holding the data of the current
; scan. nb/ng is the number of beams, gates.
; 
; CATEGORY:
; Radar
; 
; CALLING SEQUENCE:
; Result = RAD_FIT_GET_SCAN(Scan_number)
;
; INPUTS:
; Scan_number: An integer giving the number of the scan to return. When
; fit data is loaded, RAD_FIT_READ parses through the data and simply
; numbers scans sequentially, the first scan of the loaded data being 
; number 1. If you do not provide the scan number and instead set this
; to a named variable and use the
; JUL keyword, the named variable will contain the number of the selected scan.
;
; KEYWORD PARAMETERS:
; JUL: If you do not know the Scan_number, give the juldian day number
; of the date/time that you are interested in via this keyword and 
; RAD_FIT_GET_SCAN will return that scan nearest in time to the given time.
; If the timestamp of the nearest scan found differs from the given time 
; by more than 10 minutes, a warning is printed. This keyword is ignored if you
; set Scan_number.
;
; CHANNEL: Set this keyword to the channel number you want to return data for.
;
; SCAN_ID: Set this keyword to the numeric scan id you want to return data for.
;
; PARAM: Set this keyword to a string to indicate the parameter of 
; which the data will be returned.
;
; GROUNDFLAG: Set this keyword to a named variable in which the ground flag is returned.
;
; FREQUENCY: Set this keyword to a named variable in which the frequency is returned.
;
; SCAN_STARTJUL: Set this keyword to a named variable that will contain the
; timestamp of the first beam in teh scan as a julian day.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding radar data.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's GET_SCAN.
; Written by Lasse Clausen, Nov, 24 2009
;-
function rad_fit_get_scan, scan_number, jul=jul, $
	channel=channel, scan_id=scan_id, $
	param=param, groundflag=groundflag, frequency=frequency, $
	scan_startjul=scan_startjul

common rad_data_blk

if n_elements(scan_number) eq 0 || scan_number lt 0 then begin
	if ~keyword_set(jul) then begin
		prinfo, 'Must give Scan_number of JUL keyword.'
		return, 0
	endif
	scan_number = rad_fit_find_scan(jul, channel=channel, scan_id=scan_id)
	if scan_number eq -1L then $
		return, 0
endif

if ~keyword_set(scan_id) then $
	scan_id = -1

; get index for current data
data_index = rad_fit_get_data_index()
if data_index eq -1 then $
	return, 0

if n_elements(channel) eq 0 and scan_id eq -1 then begin
		channel = (*rad_fit_info[data_index]).channels[0]
endif

if ~keyword_set(param) then $
	param = get_parameter()

if n_elements(channel) ne 0 then begin
	scan_beams = WHERE((*rad_fit_data[data_index]).beam_scan EQ scan_number and $
		(*rad_fit_data[data_index]).channel eq channel, $
		no_scan_beams)
endif else if scan_id ne -1 then begin
	scan_beams = WHERE((*rad_fit_data[data_index]).beam_scan EQ scan_number and $
		(*rad_fit_data[data_index]).scan_id eq scan_id, $
		no_scan_beams)
endif
IF no_scan_beams EQ 0 THEN BEGIN
	prinfo, 'No scan information.'
	return, 0
ENDIF
scan_startjul = (*rad_fit_data[data_index]).juls[scan_beams[0]]
if ~keyword_set(scan_id) then $
	scan_id = (*rad_fit_data[data_index]).scan_id[scan_beams[0]]

if no_scan_beams gt (*rad_fit_info[data_index]).nbeams then begin
	prinfo, 'Number of beams per scan higher than number of beams on radar.'	
	;	print, no_scan_beams, rad_fit_info.nbeams
endif

frequency  = INTARR((*rad_fit_info[data_index]).nbeams)
varr       = FLTARR((*rad_fit_info[data_index]).nbeams,(*rad_fit_info[data_index]).ngates)+10000.
groundflag = INTARR((*rad_fit_info[data_index]).nbeams,(*rad_fit_info[data_index]).ngates)+10000
FOR beam=0L, no_scan_beams-1L DO BEGIN
	frequency[(*rad_fit_data[data_index]).beam[scan_beams[beam]]] = (*rad_fit_data[data_index]).tfreq[scan_beams[beam]]
	FOR gate=(*rad_fit_info[data_index]).ngates-1, 0, -1 DO BEGIN
		if param eq 'power' then $
			varr[(*rad_fit_data[data_index]).beam[scan_beams[beam]],gate] = (*rad_fit_data[data_index]).power[scan_beams[beam],gate] $
		else if param eq 'velocity' then $
			varr[(*rad_fit_data[data_index]).beam[scan_beams[beam]],gate] = (*rad_fit_data[data_index]).velocity[scan_beams[beam],gate] $
		else if param eq 'width' then $
			varr[(*rad_fit_data[data_index]).beam[scan_beams[beam]],gate] = (*rad_fit_data[data_index]).width[scan_beams[beam],gate] $
		else begin
			prinfo, 'Unknown parameter: '+param
			return, 0
		endelse
		groundflag[(*rad_fit_data[data_index]).beam[scan_beams[beam]],gate] = (*rad_fit_data[data_index]).gscatter[scan_beams[beam],gate]
	ENDFOR
ENDFOR

RETURN, varr

END
