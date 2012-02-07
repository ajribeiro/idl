;+ 
; NAME: 
; RAD_RAW_DEFINE_BEAMS
;
; PURPOSE: 
; This procedure populates the variable FOV_LOC_CENTER and FOV_LOC_FULL of the structure RAD_RAW_INFO
; in the RAD_DATA_BLK common block. This variable holds the positions of the beams and 
; gates of a radar in the active coordinate system (see SET_COORDINATES). It will also change some of the other 
; variables in that block.
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE:
; RAD_RAW_DEFINE_BEAMS
;
; KEYWORD PARAMETERS:
; BEAM_POS: The index of the data record in RAD_DATA_BLK data from which to
; take the values for LAGFR and SMSEP. If this value is not provided, the LAGFR and
; SMSEP of the first data record (if available) are taken).
;
; FORCE_COORDS: Set this keyword to a valid coordinate system (see SET_COORDINATES).
; If none if provided, the currently loaded coordinate system is used.
;
; NORMAL: Set this keyword to force the folowing values: LAGRF = 1200. and SMSEP = 300.
;
; ID: Set this to the numeric ID of the radar site for which the FOV locations will be
; calculated. If not provided, the FOV is calculated for the currently loaded radar 
; (RAD_RAW_INFO.ID).
;
; SILENT: Set this keyword to surpress warnings but not error messages.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding the currently loaded radar data and 
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
; Based on Steve Milan's DEFINE_BEAMS.
; Written by Lasse Clausen, Nov, 24 2009
;-
pro rad_raw_define_beams, beam_pos=beam_pos, force_coords=force_coords, $
	normal=normal, id=id, silent=silent

prinfo, 'DEPRECATED.'

return

common radarinfo
common rad_data_blk

; if no external coordinate system was set
; use the one from the USER_PREFS common block
if ~keyword_set(force_coords) then $
	coord_system = get_coordinates() $
else $
	coord_system = force_coords

; if no external station id was set
; use the one from the RAD_DATA_BLK block
if ~KEYWORD_SET(id) THEN $
	id = rad_raw_info.id

if id lt 1 then begin
	prinfo, 'Station ID is invalid: '+string(id)
	return
endif

; check time if available
if rad_raw_info.nrecs ne 0L then begin
	sjul = rad_raw_info.sjul
	fjul = rad_raw_info.fjul
	caldat, sjul, mm, dd, year
	yrsec = rad_raw_data.ysec[0]
; else set time to latest
endif else begin
	sjul = julday(12, 31, 2020, 0)
	fjul = sjul
	caldat, sjul, mm, dd, year
	yrsec = (day_no(year,mm,dd)-1)*86400L
endelse

if id ne rad_raw_info.id then begin
	; network in radarinfo contains information about the 
	; radar sites of the superdarn network. sometimes, radars
	; move about (i.e. change geographic location) or the hard/software
	; is upgraded, adding new capabilities. the current and the old
	; configs are in the network variable. we now find the config
	; appropriate for the time from which to read data.
	;
	; find radar in variable
	ind = where(network[*].id eq id, cc)
	if cc lt 1 then begin
		prinfo, 'Uh-oh! Radar not in SuperDARN list: '+id
		return
	endif
	; loop through all radar sites find the one appropriate for
	; the chosen time
	; if the config changed during the interval, tough!
	; we will then choose the older one
	; but we'll be nice and print a warning
	for i=0, network[ind].snum-1 do begin
		if network[ind].site[i].tval eq -1 then $
			break
		ret = TimeEpochToYMDHMS(yy, mm, dd, hh, ii, ss, network[ind].site[i].tval)
		sitechange = julday(mm, dd, yy, hh, ii, ss)
		if sjul lt sitechange and fjul gt sitechange then begin
			prinfo, 'Radar site configuration changed during interval.', /force
			prinfo, 'Radar site configuration changed: ' + $
				format_jul_date(sitechange), /force
			prinfo, 'To avoid confusion you might want to split the plotting in two parts.', /force
			prinfo, 'Choosing the latter one.', /force
		endif
		if fjul le sitechange then $
			break
	endfor
	_snum = i
	; set other parameters in the rad_fit_info structure
	rad_raw_info.id = network[ind].id
	rad_raw_info.code = network[ind].code[network[ind].cnum]
	rad_raw_info.name = network[ind].name
	rad_raw_info.glat = network[ind].site[_snum].geolat
	rad_raw_info.glon = network[ind].site[_snum].geolon
	tpos = cnvcoord(rad_raw_info.glat,rad_raw_info.glon,1.)
	rad_raw_info.mlat = tpos[0]
	rad_raw_info.mlon = tpos[1]
	rad_raw_info.ngates = network[ind].site[_snum].maxrange
	rad_raw_info.nbeams = network[ind].site[_snum].maxbeam
	rad_raw_info.bmsep = network[ind].site[_snum].bmsep
endif

; check that fov arrays are the same size as ngates and nbeams
;if rad_raw_info.ngates+1 ne n_elements(rad_raw_info.fov_loc_center[0,0,*]) or $
;	rad_raw_info.nbeams+1 ne n_elements(rad_raw_info.fov_loc_center[0,*,0]) then begin
;	trad_raw_info = { $
;		sjul: rad_raw_info.sjul, $
;		fjul: rad_raw_info.fjul, $
;		name: rad_raw_info.name, $
;		code: rad_raw_info.code, $
;		id: rad_raw_info.id, $
;		scan_ids: rad_raw_info.scan_ids, $
;		channels: rad_raw_info.channels, $
;		glat: rad_raw_info.glat, $
;		glon: rad_raw_info.glon, $
;		mlat: rad_raw_info.mlat, $
;		mlon: rad_raw_info.mlon, $
;		nbeams: rad_raw_info.nbeams, $
;		ngates: rad_raw_info.ngates, $
;		bmsep: rad_raw_info.bmsep, $
;		fov_loc_full: fltarr(2, 4, rad_raw_info.nbeams+1, $
;			rad_raw_info.ngates+1), $
;		fov_loc_center: fltarr(2, rad_raw_info.nbeams+1, $
;			rad_raw_info.ngates+1), $
;		parameters: rad_raw_info.parameters, $
;		nscans: rad_raw_info.nscans, $
;		fitex: rad_raw_info.fitex, $
;		fitacf: rad_raw_info.fitacf, $
;		fit: rad_raw_info.fit, $
;		nrecs: rad_raw_info.nrecs $
;	}
;	rad_raw_info = trad_raw_info
;endif

; set up some default values
IF KEYWORD_SET(normal) THEN BEGIN
	lagfr0 = 1200.
	smsep0 = 300.
ENDIF else begin
	if rad_raw_info.nrecs lt 1 then begin
		prinfo, 'No radar data loaded. Must use ID and NORMAL keyword: ID: '+string(id)
		return
	endif
	IF n_elements(beam_pos) lt 1 THEN $
		beam_pos = 0
	lagfr0 = rad_raw_data.lagfr[beam_pos]
	smsep0 = rad_raw_data.smsep[beam_pos]
ENDelse

rad_define_beams, rad_raw_info.id, rad_raw_info.nbeams, rad_raw_info.ngates, rad_raw_info.bmsep, year, yrsec, $
	coords=coord_system, $
	lagfr0=lagfr0, smsep0=smsep0, $
	fov_loc_full=fov_loc_full, fov_loc_center=fov_loc_center
if ptr_valid(rad_raw_info.fov_loc_full) then $
	ptr_free, rad_raw_info.fov_loc_full
rad_raw_info.fov_loc_full = ptr_new(fov_loc_full)
if ptr_valid(rad_raw_info.fov_loc_center) then $
	ptr_free, rad_raw_info.fov_loc_center
rad_raw_info.fov_loc_center =  ptr_new(fov_loc_center)

end
