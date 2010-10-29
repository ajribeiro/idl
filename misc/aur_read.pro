;+ 
; NAME: 
; AUR_READ
;
; PURPOSE: 
; This procedure reads AU/AL/AE/AO/ASY_H/ASY_D/SYM_D/SYM_H index data (all of them) 
; into the variables of the structure AUR_DATA in
; the common block AUR_DATA_BLK. The time range for which data is read is controled by
; the DATE and TIME keywords.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; AUR_READ, Date
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
; AUR_DATA_BLK: The common block holding the currently loaded index data and 
; information about that data.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Based on Steve Milan's READ_FILES.
; Written by Lasse Clausen, Nov, 24 2009
;-
pro aur_read, date, time=time, long=long, $
	silent=silent, force=force

common aur_data_blk

; set nrecs to zero such that 
; you have a way of checking
; whether data was loaded.
aur_info.nrecs = 0L

; check if parameters are given
if n_params() lt 1 then begin
	prinfo, 'Must give date.'
	return
endif

if ~keyword_set(force) && aur_check_loaded(date, time=time, long=long) then $
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

nn = 60L*24L*31L*nm

tmp_au   = make_array(nn, /long, value=99999L)
tmp_al   = make_array(nn, /long, value=99999L)
tmp_ae   = make_array(nn, /long, value=99999L)
tmp_ao   = make_array(nn, /long, value=99999L)
tmp_sh   = make_array(nn, /long, value=99999L)
tmp_sd   = make_array(nn, /long, value=99999L)
tmp_ah   = make_array(nn, /long, value=99999L)
tmp_ad   = make_array(nn, /long, value=99999L)
tmp_juls = make_array(nn, /double, value=-9999.d)

for i=0L, nm-1L do begin

	caldat, julday(mm+i, 01, yy), nmm, dd, nyy

	ad = nyy*100L + nmm
	str_date = string(ad,format='(I6)')
	
	if ~keyword_set(datdi) then $
		adatdi = aur_get_path(nyy) $
	else $
		adatdi = datdi

	if ~file_test(adatdi, /dir) then begin
		prinfo, 'Data directory does not exist: ', adatdi, /force
		continue
	endif

	; -----
	; AU file
	aufilename = file_select(adatdi+'/'+str_date+'_au.dat', $
		success=ausuccess)
	if ~ausuccess then begin
		prinfo, 'AU data file not found.'
	endif
	if ~keyword_set(silent) then $
		prinfo, 'Reading ', aufilename
	; -----
	; AL file
	alfilename = file_select(adatdi+'/'+str_date+'_al.dat', $
		success=alsuccess)
	if ~alsuccess then begin
		prinfo, 'AL data file not found.'
	endif
	if ~keyword_set(silent) then $
		prinfo, 'Reading ', alfilename
	; -----
	; AE file
	aefilename = file_select(adatdi+'/'+str_date+'_ae.dat', $
		success=aesuccess)
	if ~aesuccess then begin
		prinfo, 'AE data file not found.'
	endif
	if ~keyword_set(silent) then $
		prinfo, 'Reading ', aefilename
	; -----
	; AO file
	aofilename = file_select(adatdi+'/'+str_date+'_ao.dat', $
		success=aosuccess)
	if ~aosuccess then begin
		prinfo, 'AO data file not found.'
	endif
	if ~keyword_set(silent) then $
		prinfo, 'Reading ', aofilename
	; -----
	; SYM_H file
	shfilename = file_select(adatdi+'/'+str_date+'_symh.dat', $
		success=shsuccess)
	if ~shsuccess then begin
		prinfo, 'SYM H data file not found.'
	endif
	if ~keyword_set(silent) then $
		prinfo, 'Reading ', shfilename
	; -----
	; SYM_D file
	sdfilename = file_select(adatdi+'/'+str_date+'_symd.dat', $
		success=sdsuccess)
	if ~sdsuccess then begin
		prinfo, 'SYM D data file not found.'
	endif
	if ~keyword_set(silent) then $
		prinfo, 'Reading ', sdfilename
	; -----
	; ASY_H file
	ahfilename = file_select(adatdi+'/'+str_date+'_asyh.dat', $
		success=ahsuccess)
	if ~ahsuccess then begin
		prinfo, 'ASY H data file not found.'
	endif
	if ~keyword_set(silent) then $
		prinfo, 'Reading ', ahfilename
	; -----
	; ASY_D file
	adfilename = file_select(adatdi+'/'+str_date+'_asyd.dat', $
		success=adsuccess)
	if ~adsuccess then begin
		prinfo, 'ASY D data file not found.'
	endif
	if ~keyword_set(silent) then $
		prinfo, 'Reading ', adfilename

	nmn = (days_in_month(nmm, year=nyy))[0]

	if ausuccess then $
		openr, auil, aufilename, /get_lun
	if alsuccess then $
		openr, alil, alfilename, /get_lun
	if aesuccess then $
		openr, aeil, aefilename, /get_lun
	if aosuccess then $
		openr, aoil, aofilename, /get_lun
	if shsuccess then $
		openr, shil, shfilename, /get_lun
	if sdsuccess then $
		openr, sdil, sdfilename, /get_lun
	if ahsuccess then $
		openr, ahil, ahfilename, /get_lun
	if adsuccess then $
		openr, adil, adfilename, /get_lun

	for d=0, nmn-1 do begin
		for h=0, 23 do begin
			if ausuccess then begin
				tau = lonarr(60)
				readf, auil, tau, $
					format='(14X,60I6)'
				si = i*60L*24L*31L + d*60L*24L + h*60L
				tmp_au[si:si+60L-1L] = tau
			endif
			if alsuccess then begin
				tau = lonarr(60)
				readf, alil, tau, $
					format='(14X,60I6)'
				si = i*60L*24L*31L + d*60L*24L + h*60L
				tmp_al[si:si+60L-1L] = tau
			endif
			if aesuccess then begin
				tau = lonarr(60)
				readf, aeil, tau, $
					format='(14X,60I6)'
				si = i*60L*24L*31L + d*60L*24L + h*60L
				tmp_ae[si:si+60L-1L] = tau
			endif
			if aosuccess then begin
				tau = lonarr(60)
				readf, aoil, tau, $
					format='(14X,60I6)'
				si = i*60L*24L*31L + d*60L*24L + h*60L
				tmp_ao[si:si+60L-1L] = tau
			endif
			if shsuccess then begin
				tau = lonarr(60)
				readf, shil, tau, $
					format='(14X,60I6)'
				si = i*60L*24L*31L + d*60L*24L + h*60L
				tmp_sh[si:si+60L-1L] = tau
			endif
			if sdsuccess then begin
				tau = lonarr(60)
				readf, sdil, tau, $
					format='(14X,60I6)'
				si = i*60L*24L*31L + d*60L*24L + h*60L
				tmp_sd[si:si+60L-1L] = tau
			endif
			if ahsuccess then begin
				tau = lonarr(60)
				readf, ahil, tau, $
					format='(14X,60I6)'
				si = i*60L*24L*31L + d*60L*24L + h*60L
				tmp_ah[si:si+60L-1L] = tau
			endif
			if adsuccess then begin
				tau = lonarr(60)
				readf, adil, tau, $
					format='(14X,60I6)'
				si = i*60L*24L*31L + d*60L*24L + h*60L
				tmp_ad[si:si+60L-1L] = tau
			endif
		endfor
	endfor

	if ausuccess then $
		free_lun, auil
	if alsuccess then $
		free_lun, alil
	if aesuccess then $
		free_lun, aeil
	if aosuccess then $
		free_lun, aoil
	if shsuccess then $
		free_lun, shil
	if sdsuccess then $
		free_lun, sdil
	if ahsuccess then $
		free_lun, ahil
	if adsuccess then $
		free_lun, adil
	
	tt = timegen(start=julday(nmm, 1, nyy, 0, 0, 0), final=julday(nmm+1, 0, nyy, 23, 59, 0), $
		unit='I', step=1)
	ntt = n_elements(tt)
	tmp_juls[i*60L*24L*31L:i*60L*24L*31L+ntt-1L] = tt

endfor

good = where(tmp_juls gt -9999.d, ng)
if ng eq 0 then $
	return
tjuls = tmp_juls[good]
tau  = tmp_au [good]
tal  = tmp_al [good]
tae  = tmp_ae [good]
tao  = tmp_ao [good]
tsh  = tmp_sh [good]
tsd  = tmp_sd [good]
tah  = tmp_ah [good]
tad  = tmp_ad [good]

jinds = where(tjuls ge sjul and tjuls le fjul, cc)
if cc eq 0 then begin
	prinfo, 'No data found.'
	return
endif

juls = tjuls[jinds]
au  = tau[jinds]
al  = tal[jinds]
ae  = tae[jinds]
ao  = tao[jinds]
sh  = tsh[jinds]
sd  = tsd[jinds]
ah  = tah[jinds]
ad  = tad[jinds]

ninds = where(au eq 99999L, ncc)
if ncc ge 1L then $
	au[ninds] = !values.f_nan
ninds = where(al eq 99999L, ncc)
if ncc ge 1L then $
	al[ninds] = !values.f_nan
ninds = where(ae eq 99999L, ncc)
if ncc ge 1L then $
	ae[ninds] = !values.f_nan
ninds = where(ao eq 99999L, ncc)
if ncc ge 1L then $
	ao[ninds] = !values.f_nan
ninds = where(sh eq 99999L, ncc)
if ncc ge 1L then $
	sh[ninds] = !values.f_nan
ninds = where(sd eq 99999L, ncc)
if ncc ge 1L then $
	sd[ninds] = !values.f_nan
ninds = where(ah eq 99999L, ncc)
if ncc ge 1L then $
	ah[ninds] = !values.f_nan
ninds = where(ad eq 99999L, ncc)
if ncc ge 1L then $
	ad[ninds] = !values.f_nan

taur_data = { $
	juls: dblarr(cc), $
	au_index: lonarr(cc), $
	al_index: lonarr(cc), $
	ae_index: lonarr(cc), $
	ao_index: lonarr(cc), $
	sym_h: lonarr(cc), $
	sym_d: lonarr(cc), $
	asy_h: lonarr(cc), $
	asy_d: lonarr(cc) $
}

taur_data.juls = juls
taur_data.au_index = au
taur_data.al_index = al
taur_data.ae_index = ae
taur_data.ao_index = ao
taur_data.sym_h = sh
taur_data.sym_d = sd
taur_data.asy_h = ah
taur_data.asy_d = ad

aur_data = taur_data

aur_info.sjul = juls[0L]
aur_info.fjul = juls[cc-1L]
aur_info.nrecs = cc

end
