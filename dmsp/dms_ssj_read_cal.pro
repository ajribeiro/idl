;+
; NAME: 
; DMS_SSJ_READ_CAL
; 
; PURPOSE:
; This procedure reads calibration data for DMSP SSJ/4 data.
; 
; CATEGORY:
; DMSP
; 
; CALLING SEQUENCE: 
; DMS_SSJ_READ_CAL, Year, Sat
;
; INPUTS:
; Year: A scalar year for which to load the calibration data, 
; in YYYY format.
;
; Sat: The DMSP satellite number, currently active are 12-18.
;
; KEYWORD PARAMETERS:
; PATH: A directory  name in which to look for the calibration files.
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
; Written by Lasse Clausen, Apr, 4 2010
;-
pro dms_ssj_read_cal, year, sat, path=path

common dms_data_blk

if sat lt 6 or sat gt 18 or year lt 1983 then begin
	prinfo, '1983 <= year and 6<= sat <= 18'
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

fact= { eeng:fltarr(20),ieng:fltarr(20), $
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
		fact.eeng[i] = eeng1[i]
		fact.eeng[10+i] = eeng2[i]
		fact.ieng[i] = ieng1[i]
		fact.ieng[10+i] = ieng2[i]
		fact.ewid[i] = ewid1[i]
		fact.ewid[10+i] = ewid2[i]
		fact.iwid[i] = iwid1[i]
		fact.iwid[10+i] = iwid2[i]
		fact.gfe[i] = gfe1[i] * factors[1]
		fact.gfe[10+i] = gfe2[i] * factors[0]
		fact.gfi[i] = gfi1[i] * factors[3]
		fact.gfi[10+i] = gfi2[i] * factors[2]
		fact.k1e[i] = k1e1[i] / factors[1]
		fact.k1e[10+i] = k1e2[i] / factors[0]
		fact.k2e[i] = k2e1[i] / factors[1]
		fact.k2e[10+i] = k2e2[i] / factors[0]
		fact.k1i[i] = k1i1[i] / factors[3]
		fact.k1i[10+i] = k1i2[i] / factors[2]
		fact.k2i[i] = k2i1[i] / factors[3]
		fact.k2i[10+i] = k2i2[i] * factors[2]
ENDFOR

;***************************************************************************************************
;       k1e(i) = ewidth(i) /2.0 /egf(i) /0.098     ;Jne
;       k2e(i) = k1e(i) * een(i)
v = transpose(fltarr(19))
z = 0.0
f0 = {fact_t, $
	eeng:v,   ieng:v, $
	ewid:v,   iwid:v, $
	gfe:v,    gfi:v,  $
	k1e:v,    k1i:v,  $
	k2e:v,    k2i:v,  $
	jne:v,    jni:v,  $
	jee:v,    jei:v,  $
	edef:v,   idef:v $
}
facts = f0
if sat le 15 then begin                              ;*** SSJ4 ***
	facts.eeng = [fact.eeng[0:8], fact.eeng[10:19]]
	facts.ieng = [fact.ieng[0:9], fact.ieng[11:19]]
	facts.ewid = [fact.ewid[0:8], fact.ewid[10:19]]
	facts.iwid = [fact.iwid[0:9], fact.iwid[11:19]]
	facts.gfe = [fact.gfe[0:8], fact.gfe[10:19]]
	facts.gfi = [fact.gfi[0:9], fact.gfi[11:19]]
	facts.k1e = [fact.k1e[0:8], fact.k1e[10:19]]
	facts.k1i = [fact.k1i[0:9], fact.k1i[11:19]]
	facts.k2e = [fact.k2e[0:8], fact.k2e[10:19]]
	facts.k2i = [fact.k2i[0:9], fact.k2i[11:19]]
	facts.jne = facts.k1e
	facts.jni = facts.k1i
	facts.jee = 1000.*facts.k2e
	facts.jei = 1000.*facts.k2i
	facts.edef = (facts.eeng/facts.gfe)/0.098
	facts.idef = (facts.ieng/facts.gfi)/0.098
endif else begin                                   ;*** SSJ5 ***
	facts.eeng = [fact.eeng[0:8], fact.eeng[10:19]]
	facts.ieng = [fact.ieng[0:8], fact.ieng[10:19]]
	facts.ewid = [fact.ewid[0:8], fact.ewid[10:19]]
	facts.iwid = [fact.iwid[0:8], fact.iwid[10:19]]
	facts.gfe = [fact.gfe[0:8], fact.gfe[10:19]]
	facts.gfi = [fact.gfi[0:8], fact.gfi[10:19]]
	facts.k1e = [fact.k1e[0:8], fact.k1e[10:19]]
	facts.k1i = [fact.k1i[0:8], fact.k1i[10:19]]
	facts.k2e = [fact.k2e[0:8], fact.k2e[10:19]]
	facts.k2i = [fact.k2i[0:8], fact.k2i[10:19]]
	facts.jne = facts.k1e
	facts.jni = facts.k1i
	facts.jee = 1000.*facts.k2e
	facts.jei = 1000.*facts.k2i
	facts.edef = (facts.eeng/facts.gfe)/0.05
	facts.idef = (facts.ieng/facts.gfi)/0.05
endelse

if ptr_valid(dms_ssj_info.calibration) then $
	ptr_free, dms_ssj_info.calibration

dms_ssj_info.calibration = ptr_new(facts)

end
