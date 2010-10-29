;+
; NAME: 
; RAD_MAP_OVERLAY_FAN
;
; PURPOSE: 
; This procedure overlays fan plots on a map. This routines differs from RAD_FIT_OVERLAY_FAN 
; as it receives an array of numeric station ids and a julian day, reads the fit data for that
; radar and overlays the fan using RAD_FIT_OVERLAY_FAN. This routines is intended to use in combination
; with the RAD_MAP_* routines rather than the RAD_FIT_* routines.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:
; RAD_MAP_OVERLAY_FAN, St_ids, Jul
;
; INPUTS:
; St_ids: A scalar or array of numeric radar ids.
;
; Jul: A julian day number at which to read the data for the given radars.
;
; KEYWORD PARAMETERS:
; PARAM: Set this keyword to specify the parameter to plot. Allowable
; values are 'power', 'velocity', and 'width'. Default is 'power'.
;
; CHANNEL: Set this keyword to the channel number you want to plot.
;
; SCAN_ID: Set this keyword to the numeric scan id you want to plot.
;
; COORDS: Set this keyword to a string naming the coordinate system
; of the y axis. Allowable inputs are 'mag', 'geo', 'range' and 'gate'.
; Default is 'gate'.
;
; SCALE: Set this keyword to change the scale of the plotted values.
;
; SILENT: Set this keyword to surpress all messages/warnings.
;
; FREQ_BAND: Set this keyword to a 2-element vector indicating the
; frequency pass band you wish to plot.
;
; ROTATE: Set this keyword to rotate the scan plot by 90 degree clockwise.
;
; COMMON BLOCKS:
; RADARINFO: The common block holding information about the radars.
;
; MODIFICATION HISTORY: 
; Based on Steve Milan's OVERLAY_FAN.
; Written by Lasse Clausen, Dec, 22 2009
;-
pro rad_map_overlay_fan, st_ids, jul, $
	channel=channel, scan_id=scan_id, $
	coords=coords, scale=scale, param=param, $
	silent=silent, freq_band=freq_band, $
	rotate=rotate, fov=fov

common radarinfo

if n_params() ne 2 then begin
	prinfo, 'Give St_ids and Jul.'
	return
endif

if ~keyword_set(param) then $
	param = get_parameter()

if ~is_valid_parameter(param) then begin
	prinfo, 'Invalid plotting parameter: '+param
	return
endif

if ~keyword_set(freq_band) then $
	freq_band = [3.0, 30.0]

if ~keyword_set(coords) then $
	coords = get_coordinates()

if ~is_valid_coord_system(coords) then begin
	prinfo, 'Invalid coordinate system: '+coords
	return
endif

; check coordinate system
if coords ne 'magn' and coords ne 'geog' and coords ne 'mlt' then begin
	prinfo, 'Coordinate system not supported: '+coords
	prinfo, 'Using magnetic coordinates.'
	coords = 'magn'
endif

if ~keyword_set(scale) then begin
	if strcmp(get_parameter(), param) then $
		scale = get_scale() $
	else $
		scale = get_default_range(param)
endif

for i=0, n_elements(st_ids)-1 do begin
	njul = jul+[-1.d,1.d]*2.d/1440.d
	sfjul, ndate, ntime, njul[0], njul[1], /jul_to
	dd = where(network[*].id eq st_ids[i], cr)
	if cr ne 1 then begin
		prinfo, 'Radar '+string(st_ids[i],format='(I02)')+' not in network or not unique.'
		continue
	endif
	nradar = network[dd].code[0]
	rad_fit_read, ndate, nradar, time=ntime
	rad_fit_overlay_fan, jul=jul, coords=coords, param=param, scale=scale, $
		channel=channel, scan_id=scan_id, freq_band=freq_band
	if keyword_set(fov) then $
		overlay_fov, jul=jul, coords=coords, ids=st_ids[i], /no_fill, fov_linecolor=get_gray()
endfor



end