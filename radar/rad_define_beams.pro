;+ 
; NAME: 
; RAD_DEFINE_BEAMS
;
; PURPOSE: 
; This procedure calculates the position of beam/gate cells using the
; RBPOS function from the RST. It returns the values in FOV_LOC_FULL and 
; FOV_LOC_CENTER.
;
; INPUTS:
; Id: The numeric station id, usually found in rad_fit/raw_info.id.
;
; Nbeams: The number of beams to calculate, usually found in rad_fit/raw_info.nbeams
;
; Ngates: The number of gates to calculate, usually found in rad_fit/raw_info.ngates
;
; Year: Set this to the year for which to calculate the cell position.
; Sometimes, radar parameters change, hence you need to specify which date
; you are interested in.
;
; Yrsec: The number of seconds since Jan 1st, 00:00:00 of the year you are
; interested in. Sometimes, radar parameters change, hence you need to 
; specify which date you are interested in. You can use TimeYMDHMStoYrsec of the RST
; to calculate this value.
;
; KEYWORD PARAMETERS:
; COORDS: Set this keyword to a valid coordinate system (see SET_COORDINATES).
; If none if provided, the currently loaded coordinate system is used.
;
; NORMAL: Set this keyword to force the folowing values: LAGRF = 1200. and SMSEP = 300.
;
; BMSEP: The separation between beams, usually found in rad_fit/raw_info.bmsep.
;
; LAGFR0: Some value, if set, it overrides the /NORMAL keyword.
;
; SMSEP0: Some value, if set, it overrides the /NORMAL keyword.
;
; SILENT: Set this keyword to surpress warnings but not error messages.
;
; FOV_LOC_FULL: Set this keyword to a named variable which will contain the locations
; of the four corners of each radar cell.
;
; FOV_LOC_CENTER: Set this keyword to a named variable which will contain the locations
; of the center of each radar cell.
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
pro rad_define_beams, id, nbeams, ngates, year, yrsec, $
	coords=coords, height=height, bmsep=bmsep, $
	normal=normal, silent=silent, lagfr0=lagfr0, smsep0=smsep0, $
	fov_loc_full=fov_loc_full, fov_loc_center=fov_loc_center

common radarinfo
;common rad_data_blk

if n_params() ne 5 then begin
	prinfo, 'Must give radar id, nbeams and ngates, year and yrsec.'
	return
endif

;prinfo, strjoin(string([id, nbeams, ngates, bmsep, year, yrsec]), ',')

if ~keyword_set(height) then $
	height = 300.

; if no external coordinate system was set
; use the one from the USER_PREFS common block
if ~keyword_set(coords) then $
	coord_system = get_coordinates() $
else $
	coord_system = coords

case coord_system of
	'rang': cflag=0
	'geog': cflag=1
	'magn': cflag=2
	'gate': cflag=3
	else : begin
		prinfo, 'Incorrect coordinate system type: '+coord_system
		return
	end
endcase

if id lt 1 then begin
	prinfo, 'Station ID is invalid: '+string(id)
	return
endif

if ~keyword_set(normal) and ~keyword_set(lagfr0) and ~keyword_set(smsep0) then begin
	prinfo, 'Setting NORMAL keyword.'
	normal = 1
endif

; set up some default values
IF KEYWORD_SET(normal) THEN BEGIN
	_lagfr0 = 1200.
	_smsep0 = 300.
	_bmsep = 3.24
ENDIF

; explicitly setting the keyword overrides /NORMAL
if keyword_set(lagfr0) then $
	_lagfr0 = lagfr0

if keyword_set(smsep0) then $
	_smsep0 = smsep0

if keyword_set(bmsep) then $
	_bmsep = bmsep

; actually, fov_loc_center should only have ngates elements, but we make one more
; so that rad_fit_plot_rti works properly
fov_loc_center = make_array(2, nbeams, ngates+1)
fov_loc_full   = make_array(2, 4, nbeams+1, ngates+1)
	
; Determine range
IF cflag EQ 0 THEN BEGIN
	height2 = 300.0^2
	rxrise  = 100.
	b = FINDGEN(nbeams+1)-0.5
	g = FINDGEN(ngates+1)-0.5
  s    = TimeYrsecToYMDHMS(year,mo,dy,hr,mt,sc,yrsec)
  rid  = RadarGetRadar(network,id)
  site = RadarYMDHMSGetSite(rid,year,mo,dy,hr,mt,sc)
	if size(site, /type) eq 3 then begin
		prinfo, 'Cannot find site at given date: '+rid.name+' at '+strjoin(strtrim(string([year,mo,dy,hr,mt,sc]),2),'-')
		return
	endif
        ;Changed nbeams to nbeams-1 to avoid subscripting error /30NOV2011//NAF
	FOR m=0,nbeams-1 DO BEGIN
		FOR n=0,ngates DO BEGIN
			ang   = (b[m] - site.maxbeam/2.)*site.bmsep*!dtor
			range = (_lagfr0 - rxrise + n*_smsep0)*0.150
			IF rad_get_scatterflag() EQ 1 THEN BEGIN
				IF range GT 600.0 THEN BEGIN
					hdistance = SQRT(range*range/4.0-height2)
					distance = !RE*ASIN(hdistance/!RE)
				ENDIF ELSE $
					distance=0.0
			ENDIF ELSE $
			distance=range
			if m lt nbeams then $
				fov_loc_center[0,m,n] = range;*SIN(ang)
			fov_loc_center[1,m,n] = range*COS(ang)
		ENDFOR
	ENDFOR
ENDIF

; RADARPOS(CENTER, BCRD, RCRD, SITE, FRANG, RSEP, RXRISE, HEIGHT, RHO, LAT, LNG)
; Determine latitude and longitude positions	
IF cflag EQ 1 OR cflag EQ 2 THEN BEGIN
	; Use rbpos library - check that not SPEAR radar
	IF id NE 128 THEN BEGIN
  	s    = TimeYrsecToYMDHMS(year,mo,dy,hr,mt,sc,yrsec)
  	rid  = RadarGetRadar(network,id)
  	site = RadarYMDHMSGetSite(rid,year,mo,dy,hr,mt,sc)
		if size(site, /type) eq 3 then begin
			prinfo, 'Cannot find site at given date: '+rid.name+' at '+strjoin(strtrim(string([year,mo,dy,hr,mt,sc]),2),'-')
			return
		endif

		if keyword_set(bmsep) then $
			site.bmsep = _bmsep

		tg = indgen(ngates+1)
		tb = indgen(nbeams)
		bmarr = rebin(tb, nbeams, ngates+1)
		rgarr = transpose(rebin(tg, ngates+1, nbeams))
		pos = radarPos(1, bmarr, rgarr, site, _lagfr0*.15, _smsep0*.15, site.recrise, height, rho, lat, lon)
		if cflag eq 2 then begin
			s = AACGMConvert(lat, lon, replicate(height,ngates+1,nbeams), mlat, mlon, mrho)
			lat = mlat
			lon = mlon
			rho = mrho
		endif
		fov_loc_center[0,*,*] = lat
		fov_loc_center[1,*,*] = lon

		tg = indgen(ngates+2)
		tb = indgen(nbeams+2)
		bmarr = rebin(tb, nbeams+2, ngates+2)
		rgarr = transpose(rebin(tg, ngates+2, nbeams+2))
		pos = radarPos(0, bmarr, rgarr, site, _lagfr0*.15, _smsep0*.15, site.recrise, height, rho, lat, lon)
		if cflag eq 2 then begin
			s = AACGMConvert(lat, lon, replicate(height,ngates+2,nbeams+2), mlat, mlon, mrho)
			lat = mlat
			lon = mlon
			rho = mrho
		endif
		fov_loc_full[0,0,*,*] = lat[0:nbeams,0:ngates]
		fov_loc_full[0,1,*,*] = lat[1:nbeams+1,0:ngates]
		fov_loc_full[0,2,*,*] = lat[1:nbeams+1,1:ngates+1]
		fov_loc_full[0,3,*,*] = lat[0:nbeams,1:ngates+1]
		fov_loc_full[1,0,*,*] = lon[0:nbeams,0:ngates]
		fov_loc_full[1,1,*,*] = lon[1:nbeams+1,0:ngates]
		fov_loc_full[1,2,*,*] = lon[1:nbeams+1,1:ngates+1]
		fov_loc_full[1,3,*,*] = lon[0:nbeams,1:ngates+1]

	ENDIF
ENDIF

; Determine gate numbers
IF cflag EQ 3 THEN BEGIN
	FOR m=0,nbeams-1 DO $
		fov_loc_center[0,m,0:ngates] = FINDGEN(ngates+1)
ENDIF

end
