;+ 
; NAME: 
; RT_READ_EDENS
;
; PURPOSE: 
; This procedure reads electron density for rt_plot_rays
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; RT_READ_EDENS, edens, lats, lons, alts
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
pro rt_read_edens, edens, lats, lons, alts
; print,'running rt_read_edens.pro'
openr, lun, 'edens.dat', /get_lun

readf, lun, npoints

readf, lun, salt, ealt, dalt, nalt, $
	format='(3(1X,F5.1),I5)'

alts = salt + findgen(nalt+1)*dalt

edens = dblarr(npoints, nalt)
tdens = dblarr(nalt)
for i=0, npoints-1 do begin
	readf, lun, tdens, format='('+strtrim(string(fix(nalt)),2)+'E25.11)'
	edens[i,*]  =tdens
endfor

lats = dblarr(npoints)
readf, lun, lats, format='('+strtrim(string(fix(npoints)),2)+'E19.11)'
lons = dblarr(npoints)
readf, lun, lons, format='('+strtrim(string(fix(npoints)),2)+'E19.11)'

free_lun, lun

lats = lats[0:npoints-2]
lons = lons[0:npoints-2]

end
