

;-------------------------------------------------------------

PRO rad_map_plot_imf, xmaps, ymaps, xmap, ymap, gap=gap, $
	position=position, tposition=tposition, $
	int_hemisphere=int_hemisphere, index=index, $
	imf=imf, size=size, thick=thick, $
	timelag=timelag, charsize=charsize, $
	color=color, scale=scale

common rad_data_blk

if n_params() lt 4 then begin
	if ~keyword_set(silent) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif

if ~keyword_set(tposition) then $
	tposition = define_panel(xmaps, ymaps, xmap, ymap, /square)

if ~keyword_set(size) then $
	size = .15*(tposition[2]-tposition[0])

if ~keyword_set(position) then $
	position = define_imfpanel(tposition, gap=gap, size=size)

if ~keyword_set(scale) then $
	scale = [-5,5]
range = scale[1]-scale[0]

if ~keyword_set(imf) then begin
	if n_elements(index) lt 1 then begin
		prinfo, 'I have no idea from what time to take the IMF. I am guessing the first.'
		index = 0
	endif
	if n_elements(int_hemisphere) lt 1 then $
		int_hemisphere = 0
	imf = reform((*rad_map_data[int_hemisphere]).b_imf[index,1:2])
endif

if ~keyword_set(delay) then begin
	if n_elements(index) lt 1 then begin
		prinfo, 'I have no idea from what time to take the IMF. I am guessing the first.'
		index = 0
	endif
	if n_elements(int_hemisphere) lt 1 then $
		int_hemisphere = 0
	delay = (*rad_map_data[int_hemisphere]).imf_delay[index]
endif

if ~keyword_set(color) then $
	color = 253

if ~keyword_set(thick) then $
	thick = 1

if ~keyword_set(charsize) then $
	charsize = get_charsize(1,3)

gray = get_gray()

; plot coordinate system without axis
plot, [0,0], /nodata, position=position, xstyle=5, ystyle=5, $
	xrange=scale, yrange=scale
; plot cross
oplot, [0,0], !y.crange, color=gray
oplot, !x.crange, [0,0], color=gray
; make some tickmarks
for i=scale[0], scale[1] do begin
	oplot, [i,i], [0, -.02*range], color=gray
	oplot, [0,.02*range], [i,i], color=gray
endfor

; draw IMF vector
arrow, 0, 0, imf[0], imf[1], /data, color=color, $
	hthick=thick, thick=thick, hsize=300./(1.+(!d.name eq 'X')*64.)*charsize

; label axes
xyouts, .1*range, scale[1], '+Z', $
	charsize=charsize, alignment=0.0, color=color
xyouts, scale[1], -.1*range, '+Y', $
	charsize=charsize, alignment=0.0, color=color

; tell about delay
xyouts, (position[2]+position[0])/2., position[1]-.3*charsize*(position[3]-position[1])-.01*get_charsize(xmaps,ymaps), $
;xyouts, 0., scale[0]-charsize, $
	'(-'+strtrim(delay,2)+' min)!C('+(*rad_map_data[int_hemisphere]).imf_model[index]+')', /norm, $
  charsize=charsize, alignment=0.5, color=color

; tell about delay
;xyouts, (position[2]+position[0])/2., position[1]-.3*charsize*(position[3]-position[1])-3.*.01*get_charsize(xmaps,ymaps), $
;xyouts, 0., scale[0]-charsize, $
;	'('+(*rad_map_data[int_hemisphere]).imf_model[index]+')', /norm, $
;  charsize=charsize, alignment=0.5, color=color

END