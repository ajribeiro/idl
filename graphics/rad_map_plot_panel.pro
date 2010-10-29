;+
; NAME: 
; RAD_MAP_PLOT_PANEL
;
; PURPOSE: 
; This procedure plots a panel containing a map and 
; overlays the potential contours, the Hepner-Maynard boundary and velocity vectors.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:
; RAD_MAP_PLOT_PANEL
;
; OPTIONAL INPUTS
; Xmaps: The total number of columns of plots on the resulting page.
; Default is 1.
;
; Ymaps: The total number of rows of plots on the resulting page.
; Default is 1.
;
; Xmap: The current horizontal (column) index of this panel.
; Default is 0.
;
; Ymap: The current vertical (row) index of this panel.
; Default is 0.
;
; KEYWORD PARAMETERS:
; DATE: A scalar or 2-element vector giving the time range to plot, 
; in YYYYMMDD or MMMYYYY format.
;
; TIME: A 2-element vector giving the time range to plot, in HHII format.
;
; LONG: Set this keyword to indicate that the TIME value is in HHIISS
; format rather than HHII format.
;
; INDEX: The index number of the map to plot. If not set, that map with the timestamp closest
; to the gien input date will be plotted.
;
; NORTH: Set this keyword to plot the convection pattern for the northern hemisphere.
;
; SOUTH: Set this keyword to plot the convection pattern for the southern hemisphere.
;
; HEMISPHERE; Set this to 1 for the northern and to -1 for the southern hemisphere.
;
; COORDS: Set this to a string containing the name of the coordinate system to plot the map in.
; Allowable systems are geographic ('geog'), magnetic ('magn') and magnetic local time ('mlt').
;
; YRANGE: The y range of the map plot, default is [-31,31].
;
; XRANGE: The x range of the map plot, default is [-31,31].
;
; SCALE: Set this keyword to a 2-element vector containing the minimum and maximum velocity 
; used for coloring the vectors.
;
; COAST: Set this keyword to plot coast lines.
;
; NO_FILL: Set this keyword to surpress filling of the coastal lines.
;
; CROSS: Set this keyword to plot a coordinate cross rather than a box.
;
; MODEL: Set this keyword to include velocity vectors added by the model.
;
; MERGE: Set this keyword to plot velocity vectors
;
; TRUE: Set this keyword to plot velocity vectors
;
; LOS: Set this keyword to plot velocity vectors
;
; GRAD: Set this keyword to plot velocity vectors calculated from the ExB drift using the coefficients
; of the potential.
;
; FACTOR: Set this keyword to alter the length of vectors.
;
; SIZE: Set this keyword to adjust thickness of vector and size of dot.
;
; VEC_RADAR_IDS: Set this keyword to a numeric id or an array of numeric ids
; of a radar to only plot vectors originating from that radar.
;
; ORIG_FAN: Set this keyword to plot fan-plots of the original fit data.
;
; FAN_RADAR_IDS: Set this keyword to a numeric id or an array of numeric ids
; of a radar to only plot fan (if ORIG_FOV is set) 
; originating from that radar.
;
; IGNORE_BND: Set this keyword to ignore the HM boundary. If this keyword is NOT set, 
; velocity vectors below the HM boundary will be drawn in gray.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding map data.
;
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Dec, 11 2009
;-
pro rad_map_plot_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	position=position, $
	index=index, north=north, south=south, hemisphere=hemisphere, $
	coords=coords, xrange=xrange, yrange=yrange, scale=scale, $
	coast=coast, no_fill=no_fill, cross=cross, $
	model=model, merge=merge, true=true, los=los, grad=grad, $
	factor=factor, size=size, vec_radar_ids=vec_radar_ids, $
	orig_fan=orig_fan, fan_radar_ids=fan_radar_ids, $
	ignore_bnd=ignore_bnd, $
	silent=silent

common rad_data_blk

; check hemisphere and north and south
if ~keyword_set(hemisphere) then begin
	if keyword_set(north) then $
		hemisphere = 1. $
	else if keyword_set(south) then $
		hemisphere = -1. $
	else $
		hemisphere = 1.
endif

; this makes int_hemi 0 for north and 1 for south
int_hemi = (hemisphere lt 0)

if rad_map_info[int_hemi].nrecs eq 0L then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data loaded.'
	return
endif

if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for scan date.'
	caldat, (*rad_map_data[int_hemi]).sjuls[0], month, day, year
	date = year*10000L + month*100L + day
endif
parse_date, date, year, month, day

if ~keyword_set(time) then $
	time = 0000

if n_elements(time) gt 1 then begin
	if ~keyword_set(silent) then $
		prinfo, 'TIME must be a scalar, selecting first element: '+string(time[0], format='(I4)')
	time = time[0]
endif
sfjul, date, time, jul, long=long

; calculate index from date and time
if n_elements(index) eq 0 then $
	dd = min( abs( (*rad_map_data[int_hemi]).mjuls-jul ), index) $
else $
	dd = 0.

if ~keyword_set(scale) then $
	scale = [0,2000]

if n_elements(yrange) ne 2 then $
	yrange = [-46,46]

if n_elements(xrange) ne 2 then $
	xrange = [-46,46]

; check if time distance is not too big
if dd*1440.d gt 60. then $
	prinfo, 'Map found, but '+string(dd*1440.d,format='(I4)')+' minutes off chosen time.'

if n_params() lt 4 then begin
	if ~keyword_set(silent) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif
aspect = float(xrange[1]-xrange[0])/float(yrange[1]-yrange[0])
if ~keyword_set(position) then $
	position = define_panel(xmaps, ymaps, xmap, ymap, aspect=aspect, /bar, /with_info)

if ~keyword_set(coords) then $
	coords = get_coordinates()

if ~strcmp(coords, 'geog') and ~strcmp(coords, 'magn') and ~strcmp(coords, 'mlt') then begin
	prinfo, 'Coordinate system must be GEOG, MAGN or MLT. Setting to MLT'
	coords = 'mlt'
endif

;help, north, south, hemisphere

; plot map panel with coast
map_plot_panel, xmaps, ymaps, xmap, ymap, position=position, $
	date=date, time=time, long=long, $
	coords=coords, xrange=xrange, yrange=yrange, $
	no_coast=~keyword_set(coast), no_fill=no_fill, $
	no_axis=keyword_set(cross), coast_linecolor=get_gray(), $
  hemisphere=hemisphere, south=south, north=north

info_str = 'FitOrder: '+string((*rad_map_data[int_hemi]).fit_order[index],format='(I1)') + $
	', '+(rad_map_info[int_hemi].mapex ? 'mapEX' : 'APLmap')+' format'
xyouts, position[0]-0.003, position[1], info_str, /norm, orient=90, charsize=get_charsize(1,3)

pot_str = textoidl('\Phi_{pc}')+' = '+string((*rad_map_data[int_hemi]).pot_drop[index]/1000., format='(I4)')+' kV'
xyouts, position[2]-.3*get_charsize(xmaps,ymaps), position[1]-0.025*get_charsize(xmaps,ymaps), pot_str, /norm, $
	charsize=get_charsize(xmaps,ymaps), align=-1., $
	charthick=2.

; overlay original radar data
if keyword_set(orig_fan) then begin
	st_ids = (*(*rad_map_data[int_hemi]).gvecs[index])[*].st_id
	if n_elements(st_ids) gt 0 then begin
		if keyword_set(merge) then begin
			vecs = rad_map_calc_merge_vecs(int_hemi, index, indeces=indeces)
			st_ids = reform(st_ids[indeces], n_elements(indeces))
		endif
		orig_ids = st_ids[uniq(st_ids, sort(st_ids))]
		if keyword_set(fan_radar_ids) then begin
			for i=0, n_elements(fan_radar_ids)-1 do begin
				dd = where(orig_ids eq fan_radar_ids[i], cc)
				if cc gt 0l then begin
					if n_elements(inx) eq 0 then $
						inx = dd $
					else $
						inx = [inx, dd]
				endif
			endfor
			if n_elements(inx) gt 0 then $
				orig_ids = orig_ids[inx] $
			else $
				orig_ids = -1
		endif
		if orig_ids[0] ne -1 then begin
			nscale = .5*[-scale[1], scale[1]]
			sfjul, date, time, jul
			rad_map_overlay_scan, orig_ids, jul, scale=nscale, coords=coords, $
				param='velocity', /fov
		endif
	endif
endif

; overlay velocity vectors
rad_map_overlay_vectors, date=date, time=time, long=long, $
	index=index, north=north, south=south, hemisphere=hemisphere, $
	coords=coords, scale=scale, ignore_bnd=ignore_bnd, $
	model=model, merge=merge, true=true, los=los, grad=grad, $
	factor=factor, size=size, radar_ids=vec_radar_ids

; overlay potential contours
rad_map_overlay_contours, date=date, time=time, long=long, $
	index=index, north=north, south=south, hemisphere=hemisphere, $
	coords=coords, thick=2

; overlay the Hepner-Maynard boundary
rad_map_overlay_hm_boundary, date=date, time=time, long=long, $
	index=index, north=north, south=south, hemisphere=hemisphere, $
	coords=coords, thick=2

end
