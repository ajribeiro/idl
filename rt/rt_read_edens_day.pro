;+ 
; NAME: 
; RT_READ_EDENS_DAY
;
; PURPOSE: 
; This procedure reads electron density for rt_plot_rays
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; RT_READ_EDENS_DAY, edens, lat, lon, alt
;
; INPUTS:
;
; OPTIONAL INPUTS:
;
; KEYWORDS:
;
; COMMON BLOCKS:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;-
pro rt_read_edens_day, edens, lat, lon, alt
openr, lun, 'day_edens.dat', /get_lun

readf, lun, alt,lat,lon, $
	 format='(3E19.11)'

edens = dblarr(24)
readf, lun, edens, format='(24E25.11)'

free_lun, lun

; print,lat, lon, alt
; print,edens

end
