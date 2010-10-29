;+ 
; NAME: 
; ACE_READ
;
; PURPOSE: 
; This procedure reads ACE MAG and SWEPAM data into the variables of the structure ACE_MAG_DATA and ACE_SWE_DATA in
; the common block ACE_DATA_BLK. It does so by simply calling ACE_MAG_READ and ACE_SWE_READ.
; If both are read correctly, it calculates the interplanetary
; electric field via e = -vxB and the plasma beta via beta = [(T*4.16/10**5) + 5.34] * Np / B**2
; Here T is the proton temperature, np is the proton number density and b is the magnetic magnitude.
; The time range for which data is read is controled by
; the DATE and TIME keywords.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; ACE_READ, Date
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
; FORCE: If this keyword is set, the data is even if it was already in
; memory, i.e. the output of ACE_MAG_CHECK_LOADED/ACE_SWE_CHECK_LOADED is ignored.
;
; PROCEDURE:
; If Date is a scalar
; and Time[0] < Time[1], the interval stretches from Time[0] on Date to Time[1] 
; on Date. If Time[0] > Time[1], the interval stretches from Time[0] on Date to
; Time[1] on the day after Date. If Date is a two element vector, the interval
; stretches from Time[0] on Date[0] to Time[1] on Date[1].
;
; COMMON BLOCKS:
; ACE_DATA_BLK: The common block holding the currently loaded ACE data and 
; information about that data.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Based on Steve Milan's READ_FILES.
; Written by Lasse Clausen, Nov, 24 2009
; Changed to 1 minute format, 13 Jan, 2010
;-
pro ace_read, date, time=time, long=long, $
	silent=silent, force=force

common ace_data_blk

ace_mag_read, date, time=time, long=long, $
	silent=silent, force=force

if ace_mag_info.nrecs eq 0L then $
	return

ace_swe_read, date, time=time, long=long, $
	silent=silent, force=force

if ace_swe_info.nrecs eq 0L then $
	return

;beta = [(T*4.16/10**5) + 5.34] * Np / B**2
mag_ginds = where(finite(ace_mag_data.bt), mc)
if mc lt 1L then $
	return
swe_ginds = where(finite(ace_swe_data.tpr) and finite(ace_swe_data.np), sc)
if sc lt 1L then $
	return
bt = interpol(ace_mag_data.bt[mag_ginds], ace_mag_data.juls[mag_ginds], ace_swe_data.juls[swe_ginds])
ace_swe_data.beta[swe_ginds] = 8.*!pi*1.38*ace_swe_data.tpr[swe_ginds]*ace_swe_data.np[swe_ginds]/bt^2*1e-6
ace_swe_data.beta[swe_ginds] = ((ace_swe_data.tpr[swe_ginds]*4.16/1e5)+5.34)*ace_swe_data.np[swe_ginds]/bt^2

swe_ginds = where(finite(ace_swe_data.vt), sc)
if sc lt 1L then $
	return
bx_gse = interpol(ace_mag_data.bx_gse[mag_ginds], ace_mag_data.juls[mag_ginds], ace_swe_data.juls[swe_ginds])
by_gse = interpol(ace_mag_data.by_gse[mag_ginds], ace_mag_data.juls[mag_ginds], ace_swe_data.juls[swe_ginds])
bz_gse = interpol(ace_mag_data.bz_gse[mag_ginds], ace_mag_data.juls[mag_ginds], ace_swe_data.juls[swe_ginds])
by_gsm = interpol(ace_mag_data.by_gsm[mag_ginds], ace_mag_data.juls[mag_ginds], ace_swe_data.juls[swe_ginds])
bz_gsm = interpol(ace_mag_data.bz_gsm[mag_ginds], ace_mag_data.juls[mag_ginds], ace_swe_data.juls[swe_ginds])

; calculate the sw electric field
ace_swe_data.ex_gse[swe_ginds] = -(ace_swe_data.vy_gse[swe_ginds]*bz_gse - ace_swe_data.vz_gse[swe_ginds]*by_gse)*1e-3
ace_swe_data.ey_gse[swe_ginds] = -(ace_swe_data.vz_gse[swe_ginds]*bx_gse - ace_swe_data.vx_gse[swe_ginds]*bz_gse)*1e-3
ace_swe_data.ez_gse[swe_ginds] = -(ace_swe_data.vx_gse[swe_ginds]*by_gse - ace_swe_data.vy_gse[swe_ginds]*bx_gse)*1e-3

ace_swe_data.ey_gsm[swe_ginds] = -(ace_swe_data.vz_gsm[swe_ginds]*bx_gse - ace_swe_data.vx_gse[swe_ginds]*bz_gsm)*1e-3
ace_swe_data.ez_gsm[swe_ginds] = -(ace_swe_data.vx_gse[swe_ginds]*by_gsm - ace_swe_data.vy_gsm[swe_ginds]*bx_gse)*1e-3

ace_swe_data.et[swe_ginds] = sqrt(ace_swe_data.ex_gse[swe_ginds]^2 + ace_swe_data.ey_gse[swe_ginds]^2 + ace_swe_data.ez_gse[swe_ginds]^2)

end
