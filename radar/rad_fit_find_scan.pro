;+ 
; NAME: 
; RAD_FIT_FIND_SCAN
; 
; PURPOSE: 
; This function returns the scan number(s) of the scan closest to the given date.
; 
; CATEGORY:  
; Radar
; 
; CALLING SEQUENCE: 
; Result = RAD_FIT_FIND_SCAN(Juls)
;
; INPUTS:
; Juls: A scalar specifying the julian date to which the number of the closest 
; scan will be found. It can also be a 2-element vector specifying the date/time 
; range between which all scan numbers will be returned.
;
; KEYWORD PARAMETERS:
; CHANNEL: Set this keyword to the channel in which you want to find the scan.
;
; SCAN_ID: Set this keyword to the numeric scan id where you want to find the scan.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding radar data.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's GO.
; Written by Lasse Clausen, Nov, 24 2009
;-
function rad_fit_find_scan, juls, channel=channel, scan_id=scan_id

common rad_data_blk

if n_elements(juls) eq 0 then begin
	prinfo, 'Must give Juls.'
	return, -1L
endif

; get index for current data
data_index = rad_fit_get_data_index()
if data_index eq -1 then $
	return, -1L

if (*rad_fit_info[data_index]).nrecs lt 1 then begin
	prinfo, 'No data in index '+string(data_index)
	return, -1L
endif

if ~keyword_set(scan_id) then $
	scan_id = -1

if n_elements(channel) eq 0 and scan_id eq -1 then $
		channel = (*rad_fit_info[data_index]).channels[0]

if n_elements(channel) ne 0 then begin
	inds = WHERE((*rad_fit_data[data_index]).channel eq channel, $
		cc)
endif else if scan_id ne -1 then begin
	inds = WHERE((*rad_fit_data[data_index]).scan_id eq scan_id, $
		cc)
endif
if cc eq 0 then begin
	prinfo, 'No scan information.'
	return, -1L
endif

; find minimum distance between provided juls
; and beam times
smin = min( abs( (*rad_fit_data[data_index]).juls[inds]-juls[0]), sminind)

if n_elements(juls) gt 1 then $
	fmin = min( abs( (*rad_fit_data[data_index]).juls[inds]-juls[1]), fminind) $
else begin
	fmin = 0.d
	fminind = sminind
endelse

; check if distance is "reasonable"
; i.e. within 5 minutes
if smin*1440.d gt 5. then $
	prinfo, 'Found scan but it is '+$
		strtrim(string(smin*1440.d),2)+' mins away from given date.'

; check if distance is "reasonable"
; i.e. within 5 minutes
if fmin*1440.d gt 5. then $
	prinfo, 'Found scan but it is '+$
		strtrim(string(fmin*1440.d),2)+' mins away from given date.'

tmp = ((*rad_fit_data[data_index]).beam_scan[inds])[sminind:fminind]

return, tmp[uniq(tmp, sort(tmp))]

end
