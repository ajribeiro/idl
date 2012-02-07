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
; COPYRIGHT:
; Non-Commercial Purpose License
; Copyright © November 14, 2006 by Virginia Polytechnic Institute and State University
; All rights reserved.
; Virginia Polytechnic Institute and State University (Virginia Tech) owns the DaViT
; software and its associated documentation (“Software”). You should carefully read the
; following terms and conditions before using this software. Your use of this Software
; indicates your acceptance of this license agreement and all terms and conditions.
; You are hereby licensed to use the Software for Non-Commercial Purpose only. Non-
; Commercial Purpose means the use of the Software solely for research. Non-
; Commercial Purpose excludes, without limitation, any use of the Software, as part of, or
; in any way in connection with a product or service which is sold, offered for sale,
; licensed, leased, loaned, or rented. Permission to use, copy, modify, and distribute this
; compilation for Non-Commercial Purpose is hereby granted without fee, subject to the
; following terms of this license.
; Copies and Modifications
; You must include the above copyright notice and this license on any copy or modification
; of this compilation. Each time you redistribute this Software, the recipient automatically
; receives a license to copy, distribute or modify the Software subject to these terms and
; conditions. You may not impose any further restrictions on this Software or any
; derivative works beyond those restrictions herein.
; You agree to use your best efforts to provide Virginia Polytechnic Institute and State
; University (Virginia Tech) with any modifications containing improvements or
; extensions and hereby grant Virginia Tech a perpetual, royalty-free license to use and
; distribute such modifications under the terms of this license. You agree to notify
; Virginia Tech of any inquiries you have for commercial use of the Software and/or its
; modifications and further agree to negotiate in good faith with Virginia Tech to license
; your modifications for commercial purposes. Notices, modifications, and questions may
; be directed by e-mail to Stephen Cammer at cammer@vbi.vt.edu.
; Commercial Use
; If you desire to use the software for profit-making or commercial purposes, you agree to
; negotiate in good faith a license with Virginia Tech prior to such profit-making or
; commercial use. Virginia Tech shall have no obligation to grant such license to you, and
; may grant exclusive or non-exclusive licenses to others. You may contact Stephen
; Cammer at email address cammer@vbi.vt.edu to discuss commercial use.
; Governing Law
; This agreement shall be governed by the laws of the Commonwealth of Virginia.
; Disclaimer of Warranty
; Because this software is licensed free of charge, there is no warranty for the program.
; Virginia Tech makes no warranty or representation that the operation of the software in
; this compilation will be error-free, and Virginia Tech is under no obligation to provide
; any services, by way of maintenance, update, or otherwise.
; THIS SOFTWARE AND THE ACCOMPANYING FILES ARE LICENSED “AS IS”
; AND WITHOUT WARRANTIES AS TO PERFORMANCE OR
; MERCHANTABILITY OR ANY OTHER WARRANTIES WHETHER EXPRESSED
; OR IMPLIED. NO WARRANTY OF FITNESS FOR A PARTICULAR PURPOSE IS
; OFFERED. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF
; THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE,
; YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR
; CORRECTION.
; Limitation of Liability
; IN NO EVENT WILL VIRGINIA TECH, OR ANY OTHER PARTY WHO MAY
; MODIFY AND/OR REDISTRIBUTE THE PRORAM AS PERMITTED ABOVE, BE
; LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL,
; INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR
; INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS
; OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED
; BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE
; WITH ANY OTHER PROGRAMS), EVEN IF VIRGINIA TECH OR OTHER PARTY
; HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
; Use of Name
; Users will not use the name of the Virginia Polytechnic Institute and State University nor
; any adaptation thereof in any publicity or advertising, without the prior written consent
; from Virginia Tech in each case.
; Export License
; Export of this software from the United States may require a specific license from the
; United States Government. It is the responsibility of any person or organization
; contemplating export to obtain such a license before exporting.
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
tau  = float(tmp_au [good])
tal  = float(tmp_al [good])
tae  = float(tmp_ae [good])
tao  = float(tmp_ao [good])
tsh  = float(tmp_sh [good])
tsd  = float(tmp_sd [good])
tah  = float(tmp_ah [good])
tad  = float(tmp_ad [good])

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

ninds = where(au gt 99990., ncc)
if ncc ge 1L then $
	au[ninds] = !values.f_nan
ninds = where(al gt 99990., ncc)
if ncc ge 1L then $
	al[ninds] = !values.f_nan
ninds = where(ae gt 99990., ncc)
if ncc ge 1L then $
	ae[ninds] = !values.f_nan
ninds = where(ao gt 99990., ncc)
if ncc ge 1L then $
	ao[ninds] = !values.f_nan
ninds = where(sh gt 99990., ncc)
if ncc ge 1L then $
	sh[ninds] = !values.f_nan
ninds = where(sd gt 99990., ncc)
if ncc ge 1L then $
	sd[ninds] = !values.f_nan
ninds = where(ah gt 99990., ncc)
if ncc ge 1L then $
	ah[ninds] = !values.f_nan
ninds = where(ad gt 99990., ncc)
if ncc ge 1L then $
	ad[ninds] = !values.f_nan

taur_data = { $
	juls: dblarr(cc), $
	au_index: fltarr(cc), $
	al_index: fltarr(cc), $
	ae_index: fltarr(cc), $
	ao_index: fltarr(cc), $
	sym_h: fltarr(cc), $
	sym_d: fltarr(cc), $
	asy_h: fltarr(cc), $
	asy_d: fltarr(cc) $
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
