;+ 
; NAME: 
; RAD_FIT_DEFINE_BEAMS
;
; PURPOSE: 
; This procedure populates the variable FOV_LOC_CENTER and FOV_LOC_FULL of the structure RAD_FIT_INFO
; in the RAD_DATA_BLK common block. This variable holds the positions of the beams and 
; gates of a radar in the active coordinate system (see SET_COORDINATES). It will also change some of the other 
; variables in that block.
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE:
; RAD_FIT_DEFINE_BEAMS
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
; (RAD_FIT_INFO.ID).
;
; SILENT: Set this keyword to surpress warnings but not error messages.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding the currently loaded radar data and 
; information about that data.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Based on Steve Milan's DEFINE_BEAMS.
; Written by Lasse Clausen, Nov, 24 2009
;-
pro rad_fit_define_beams, beam_pos=beam_pos, force_coords=force_coords, $
	normal=normal, id=id, silent=silent, nbeams=nbeams

prinfo, 'DO NOT USE THIS FUNCTION'
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
	id = rad_fit_info.id

if id lt 1 then begin
	prinfo, 'Station ID is invalid: '+string(id)
	return
endif

; check time if available
if rad_fit_info.nrecs ne 0L then begin
	sjul = rad_fit_info.sjul
	fjul = rad_fit_info.fjul
	caldat, sjul, mm, dd, year
	yrsec = rad_fit_data.ysec[0]
; else set time to latest
endif else begin
	sjul = julday(12, 31, 2020, 0)
	fjul = sjul
	caldat, sjul, mm, dd, year
	yrsec = (day_no(year,mm,dd)-1)*86400L
endelse


if id ne rad_fit_info.id then begin
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
		prinfo, 'Uh-oh! Radar not in SuperDARN list: '+string(id)
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
	rad_fit_info.id = network[ind].id
	rad_fit_info.code = network[ind].code[network[ind].cnum]
	rad_fit_info.name = network[ind].name
	rad_fit_info.glat = network[ind].site[_snum].geolat
	rad_fit_info.glon = network[ind].site[_snum].geolon
	tpos = cnvcoord(rad_fit_info.glat,rad_fit_info.glon,1.)
	rad_fit_info.mlat = tpos[0]
	rad_fit_info.mlon = tpos[1]
	rad_fit_info.ngates = network[ind].site[_snum].maxrange
	rad_fit_info.nbeams = ( keyword_set(nbeams) ? nbeams : network[ind].site[_snum].maxbeam )
	rad_fit_info.bmsep = network[ind].site[_snum].bmsep
endif

; set up some default values
IF KEYWORD_SET(normal) THEN BEGIN
	lagfr0 = 1200.
	smsep0 = 300.
ENDIF else begin
	if rad_fit_info.nrecs lt 1 then begin
		if ~keyword_set(silent) then $
			prinfo, 'No radar data loaded. Using NORMAL keyword.'
		lagfr0 = 1200.
		smsep0 = 300.
	endif else begin
		IF n_elements(beam_pos) lt 1 THEN $
			beam_pos = 0
		lagfr0 = rad_fit_data.lagfr[beam_pos]
		smsep0 = rad_fit_data.smsep[beam_pos]
	endelse
ENDelse

rad_define_beams, rad_fit_info.id, rad_fit_info.nbeams, rad_fit_info.ngates, rad_fit_info.bmsep, year, yrsec, $
	coords=coord_system, $
	lagfr0=lagfr0, smsep0=smsep0, $
	fov_loc_full=fov_loc_full, fov_loc_center=fov_loc_center
if ptr_valid(rad_fit_info.fov_loc_full) then $
	ptr_free, rad_fit_info.fov_loc_full
rad_fit_info.fov_loc_full = ptr_new(fov_loc_full)
if ptr_valid(rad_fit_info.fov_loc_center) then $
	ptr_free, rad_fit_info.fov_loc_center
rad_fit_info.fov_loc_center =  ptr_new(fov_loc_center)

;help, rad_fit_info, /str

; check that fov arrays are the same size as ngates and nbeams
;if rad_fit_info.ngates+1 ne n_elements(rad_fit_info.fov_loc_center[0,0,*]) or $
;	rad_fit_info.nbeams+1 ne n_elements(rad_fit_info.fov_loc_center[0,*,0]) then begin
;	trad_fit_info = { $
;		sjul: rad_fit_info.sjul, $
;		fjul: rad_fit_info.fjul, $
;		name: rad_fit_info.name, $
;		code: rad_fit_info.code, $
;		id: rad_fit_info.id, $
;		scan_ids: rad_fit_info.scan_ids, $
;		channels: rad_fit_info.channels, $
;		glat: rad_fit_info.glat, $
;		glon: rad_fit_info.glon, $
;		mlat: rad_fit_info.mlat, $
;		mlon: rad_fit_info.mlon, $
;		nbeams: rad_fit_info.nbeams, $
;		ngates: rad_fit_info.ngates, $
;		bmsep: rad_fit_info.bmsep, $
;		fov_loc_full: fltarr(2, 4, rad_fit_info.nbeams+1, $
;			rad_fit_info.ngates+1), $
;		fov_loc_center: fltarr(2, rad_fit_info.nbeams+1, $
;			rad_fit_info.ngates+1), $
;		parameters: rad_fit_info.parameters, $
;		nscans: rad_fit_info.nscans, $
;		fitex: rad_fit_info.fitex, $
;		fitacf: rad_fit_info.fitacf, $
;		fit: rad_fit_info.fit, $
;		nrecs: rad_fit_info.nrecs $
;	}
;	rad_fit_info = trad_fit_info
;endif

;help, rad_fit_info, /str

end
