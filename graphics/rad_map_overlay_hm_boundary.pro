;+
; NAME: 
; RAD_MAP_OVERLAY_HM_BOUNDARY
;
; PURPOSE: 
; This procedure overlays the Hepner-Maynard boundary.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:
; RAD_MAP_OVERLAY_HM_BOUNDARY
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
; THICK: Set this keyword to an integer indicating the thickness of the boundary.
;
; LINESTYLE: Set this keyword to an integer indicating the linestyle used for boundary.
;
; COLOR: Set this keyword to an integer index indicating the color used for the boundary.
;
; SILENT: Set this kewyword to surpress warning messages.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding map data.
;
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Dec, 11 2009
;-
PRO rad_map_overlay_hm_boundary, date=date, time=time, long=long, $
	index=index, north=north, south=south, hemisphere=hemisphere, $
	coords=coords, color=color, thick=thick, linestyle=linestyle, $
	silent=silent
;;PRO overlay_hm_boundary
;;----------------------------------------------------------------------------------------
;;overlays the Hepner-Maynard convection boundary on any current mlat-MLT plot

common rad_data_blk
common recent_panel

; set some default input
if ~keyword_set(thick) then $
	thick = 1

if n_elements(color) eq 0 then $
	color = 120

if n_elements(linestyle) eq 0 then $
	linestyle = 2

if ~keyword_set(coords) then $
	coords = get_coordinates()

if ~strcmp(coords, 'mlt') and ~strcmp(coords, 'magn') then begin
	prinfo, 'Coordinate system must be MLT or MAGN, setting to MLT'
	coords = 'mlt'
endif

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
		prinfo, 'No DATE given, trying for map date.'
	caldat, (*rad_map_data[int_hemi]).sjuls[0], month, day, year
	date = year*10000L + month*100L + day
endif
parse_date, date, year, month, day

if n_elements(time) lt 1 then $
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

; check if time ditance is not too big
if dd*1440.d gt 60. then $
	prinfo, 'Map found, but '+string(dd*1440.d,format='(I4)')+' minutes off chosen time.'

; get boundary data
bnd = (*(*rad_map_data[int_hemi]).bvecs[index])
num_bnd = (*rad_map_data[int_hemi]).bndnum[index]

; get longitude shift
lon_shft = (*rad_map_data[int_hemi]).lon_shft[index]

utsec = (jul - julday(1, 1, year, 0, 0))*86400.d
; calculate lon_shft, i.e. shift magnetic longitude into mlt coordinates
if coords eq 'mlt' then begin
	lon_shft += mlt(year, utsec, 0.)*15.
	lons = ((bnd[*].lon+lon_shft)/15.) mod 24.
endif else $
	lons = (bnd[*].lon+lon_shft)

IF bnd[0].lat LT -999 THEN $
	prinfo, 'No H-M boundary data exists in Map file' $
ELSE BEGIN
	tmp = calc_stereo_coords(bnd[*].lat, lons, mlt=(coords eq 'mlt'))
	bnd_x = tmp[0,*]
	bnd_y = tmp[1,*]
;	bnd_x = -(90.-bnd[*].lat)*sin((bnd[*].lon+lon_shft)*!dtor)
;	bnd_y =  (90.-bnd[*].lat)*cos((bnd[*].lon+lon_shft)*!dtor)
	FOR l=0,num_bnd-2 DO BEGIN
		oplot,[bnd_x[l],bnd_x[l+1]],[bnd_y[l],bnd_y[l+1]],$
			thick=thick, color=get_foreground()
		oplot,[bnd_x[l],bnd_x[l+1]],[bnd_y[l],bnd_y[l+1]],$
			color=color, thick=thick, linestyle=linestyle
	ENDFOR
endelse
lat_hm = min(bnd[*].lat)
xyouts, !x.crange[0]+.05*(!x.crange[1]-!x.crange[0]), !y.crange[0]+.05*(!y.crange[1]-!y.crange[0]), $
	textoidl('\Lambda_{HM}='+( lat_hm lt 0. ? '-' : '' )+string(abs(lat_hm),format='(I2)')+'\circ'), $
	align=0, charsize=.75*get_charsize(rxmaps, rymaps)

END
