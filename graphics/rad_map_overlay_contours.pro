;+
; NAME: 
; RAD_MAP_OVERLAY_CONTOURS
;
; PURPOSE: 
; This procedure overlays the potential contours.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:
; RAD_MAP_OVERLAY_CONTOURS
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
; THICK: Set this keyword to an integer indicating the thickness of the contours.
;
; NEG_LINESTYLE: Set this keyword to an integer indicating the linestyle used for the negative contours.
;
; POS_LINESTYLE: Set this keyword to an integer indicating the linestyle used for the positive contours.
;
; NEG_COLOR: Set this keyword to an integer index indicating the color used for the negative contours.
;
; POS_COLOR: Set this keyword to an integer index indicating the color used for the positive contours.
;
; C_CHARSIZE: Set this to a value for the character size of the contour annotations.
;
; C_CHARTHICK: Set this to a value for the character thickness of the contour annotations.
;
; SILENT: Set this kewyword to surpress warning messages.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding map data.
;
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Dec, 11 2009
;-
pro rad_map_overlay_contours, date=date, time=time, long=long, jul=jul, $
	north=north, south=south, hemisphere=hemisphere, $
	index=index, coords=coords, $
	thick=thick, neg_linestyle=neg_linestyle, pos_linestyle=pos_linestyle, $
	neg_color=neg_color, pos_color=pos_color, $
	c_charsize=c_charsize, c_charthick=c_charthick, $
	silent=silent

common rad_data_blk

; set some default input
if ~keyword_set(thick) then $
	thick = 1

if n_elements(neg_linestyle) eq 0 then $
	neg_linestyle = 0

if n_elements(pos_linestyle) eq 0 then $
	pos_linestyle = 5

if n_elements(neg_color) eq 0 then $
	neg_color = get_foreground()

if n_elements(pos_color) eq 0 then $
	pos_color = get_foreground()

if ~keyword_set(c_charsize) then $
	c_charsize = get_mincharsize()

if ~keyword_set(c_charthick) then $
	c_charthick = 1

if ~keyword_set(coords) then $
	coords = get_coordinates()

if ~strcmp(coords, 'mlt') and ~strcmp(coords, 'magn') then begin
	prinfo, 'Coordinate system must be MLT or MAGN, setting to mlt'
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

if n_elements(time) lt 1 then $
	time = 0000

if n_elements(time) gt 1 then begin
	if ~keyword_set(silent) then $
		prinfo, 'TIME must be a scalar, selecting first element: '+string(time[0], format='(I4)')
	time = time[0]
endif

if ~keyword_set(jul) then $
	sfjul, date, time, jul, long=long
caldat, jul, month, day, year

; calculate index from date and time
if n_elements(index) eq 0 then $
	dd = min( abs( (*rad_map_data[int_hemi]).mjuls-jul ), index) $
else $
	dd = 0.

; check if time ditance is not too big
if dd*1440.d gt 60. then $
	prinfo, 'Map found, but '+string(dd*1440.d,format='(I4)')+' minutes off chosen time.'

; calculate potential data for chosen index and hemisphere
; IN MAGNETIC COORDINATES!!!!!!!!
pot_data = rad_map_calc_potential(int_hemi, index)
nlons = n_elements(pot_data.zonarr)
nlats = n_elements(pot_data.zatarr)

; get longitude shift
lon_shft = (*rad_map_data[int_hemi]).lon_shft[index]

utsec = (jul - julday(1, 1, year, 0, 0))*86400.d
; calculate lon_shft, i.e. shift magnetic longitude into mlt coordinates
if coords eq 'mlt' then begin
	lon_shft += mlt(year, utsec, 0.)*15.
	lons = ((pot_data.zonarr[*] + lon_shft)/15.) mod 24.
endif else $
	lons = (pot_data.zonarr[*] + lon_shft)

;print, pot_data.zatarr
;print, lon_shft
;print, pot_data.zonarr[*]
;print, lons

; Convert to polar grid in correct coordinates
polarx=FLTARR(nlons,nlats)
polary=FLTARR(nlons,nlats)
FOR j=0, nlats-1 DO BEGIN
	FOR i=0, nlons-1 DO BEGIN
		tmp = calc_stereo_coords(pot_data.zatarr[j], lons[i], mlt=(coords eq 'mlt'))
		polarx[i,j] = tmp[0]
		polary[i,j] = tmp[1]
	ENDFOR
ENDFOR

;print, polarx[*,0]

IF KEYWORD_SET(lots) THEN BEGIN
  noc   = 20
  diffc =  3
ENDIF ELSE BEGIN
  noc   = 10
  diffc =  6
ENDELSE

; get color preferences
foreground  = get_foreground()

; overlay contours
; negative
contour, pot_data.potarr, polarx, polary, $
	/overplot, xstyle=4, ystyle=4, $
	thick=thick, c_linestyle=neg_linestyle, color=neg_color, c_charsize=c_charsize, c_charthick=c_charthick, $
	levels=-57+findgen(noc)*diffc, max_value=100, /follow, noclip=0
; positive
contour,pot_data.potarr, polarx, polary, $
	/overplot, xstyle=4, ystyle=4, $
	thick=thick, c_linestyle=pos_linestyle, color=pos_color, c_charsize=c_charsize, c_charthick=c_charthick, $
	levels=3+findgen(noc)*diffc, max_value=100, /follow, noclip=0

; put in symbols at the maximum and minimum points
dims = size(pot_data.potarr, /dim)
pot_max = max(pot_data.potarr, maxind, min=pot_min, subscript_min=minind)
kref = maxind mod dims[0]
mref = fix(maxind/dims[0])
plots, polarx[kref,mref], polary[kref,mref], psym=1, symsize=0.75, thick=thick, $
	color=foreground, noclip=0

kref = minind mod dims[0]
mref = fix(minind/dims[0])
plots, polarx[kref,mref], polary[kref,mref], psym=7, symsize=0.75, thick=thick, $
	color=foreground, noclip=0

end