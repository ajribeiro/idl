PRO rad_map_plot_vector_scale, xmaps, ymaps, xmap, ymap, gap=gap, $
	position=position, factor=factor, thick=thick, $
	xrange=xrange, charsize=charsize, $
	color=color, scale=scale, tposition=tposition

load_usersym, /circle

if n_params() lt 4 then begin
	if ~keyword_set(silent) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif
if ~keyword_set(tposition) then begin
	tposition = define_panel(xmaps, ymaps, xmap, ymap, /square)
endif

; to have the length of the vector in the same 
; length as those on the map plot, we need to know
; the xrange of the map plot and the scale used in 
; that plot, as well as the factor
; the length of a velocity vector in degrees is
; factor*abs(vdata[2,i]/!re/1e3)
; hence if we divide that by the xrange
; we get the length of the vector in normal
; coordinates (i think)
if n_elements(xrange) ne 2 then begin
	prinfo, 'Need XRANGE.'
	return
endif
if n_elements(scale) ne 2 then begin
	prinfo, 'Need SCALE.'
	return
endif
range = scale[1]-scale[0]
if n_elements(factor) ne 1 then begin
	prinfo, 'Need FACTOR.'
	return
endif
size = (factor*abs(range/!re/1e3)*!radeg)/(xrange[1]-xrange[0])*(tposition[2]-tposition[0])

if ~keyword_set(position) then $
	position = define_imfpanel(tposition, size=size, gap=gap, /low)

if ~keyword_set(color) then $
	color = 253

if ~keyword_set(thick) then $
	thick = 1

if ~keyword_set(charsize) then $
	charsize = 1

range = scale[1]-scale[0]

; plot coordinate system without axis
plot, [0,0], /nodata, position=position, xstyle=5, ystyle=5, $
	xrange=[0,1], yrange=[-1,1]

plots, 0, 0, psym=8, color=color, symsize=.6
oplot, [0,1], [0,0], color=color

xyouts, -0.1, .4, align=.0, $
	strtrim(range,2)+' ms!E-1!N',charsize=.6*get_charsize(xmaps,ymaps), color=color

END