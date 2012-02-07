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
; Based on Steve Milan's GET_SCAN.
; Written by Lasse Clausen, Nov, 24 2009
;-
function rad_fit_get_scan, scan_number, jul=jul, $
	channel=channel, scan_id=scan_id, $
	param=param, groundflag=groundflag, frequency=frequency, $
	scan_startjul=scan_startjul, silent=silent

common rad_data_blk

if n_elements(scan_number) eq 0 || scan_number lt 0 then begin
	if ~keyword_set(jul) then begin
		if ~keyword_set(silent) then $
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
	if ~keyword_set(silent) then $
		prinfo, 'Number of beams per scan higher than number of beams on radar.'
endif

if max((*rad_fit_data[data_index]).beam[scan_beams]) ge (*rad_fit_info[data_index]).nbeams then begin
	if ~keyword_set(silent) then $
		prinfo, 'Largest beams number higher than number of beams on radar.'
	scan_beams = where((*rad_fit_data[data_index]).beam[scan_beams] lt (*rad_fit_info[data_index]).nbeams, no_scan_beams)
	if no_scan_beams eq 0 then begin
		if ~keyword_set(silent) then $
			prinfo, 'All beam number higher than number of beams on radar.'
		return, 0
	endif
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
		else if param eq 'phi0' then $
			varr[(*rad_fit_data[data_index]).beam[scan_beams[beam]],gate] = (*rad_fit_data[data_index]).phi0[scan_beams[beam],gate] $
		else if param eq 'elevation' then $
			varr[(*rad_fit_data[data_index]).beam[scan_beams[beam]],gate] = (*rad_fit_data[data_index]).elevation[scan_beams[beam],gate] $
		else begin
			prinfo, 'Unknown parameter: '+param
			return, 0
		endelse
		groundflag[(*rad_fit_data[data_index]).beam[scan_beams[beam]],gate] = (*rad_fit_data[data_index]).gscatter[scan_beams[beam],gate]
	ENDFOR
ENDFOR

RETURN, varr

END
