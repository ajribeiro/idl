;+ 
; NAME: 
; RAD_GRD_PLOT_TITLE
; 
; PURPOSE: 
; This procedure plots a more specific title on the top of a grd panel.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; RAD_GRD_PLOT_TITLE
;
; OPTIONAL INPUTS:
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
; INDEX: The index of the map that was plotted
;
; INT_HEMISPHERE: 0 for north, 1 for south
;
; CHARSIZE: The size of the title.
;
; CHARTHICK: The thickness of the title.
;
; POSITION: The position of the panel on which the title will be plotted.
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Oct, 21 2010
;-
pro rad_grd_plot_title, xmaps, ymaps, xmap, ymap, $
	index=index, int_hemisphere=int_hemisphere, $
	charsize=charsize, charthick=charthick, $
	position=position

common rad_data_blk

if n_params() lt 4 then begin
	if ~keyword_set(silent) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if n_elements(index) eq 0 then $
	index = 0

if n_elements(int_hemisphere) eq 0 then $
	int_hemisphere = 0

if int_hemisphere eq 0 then $
	str_hemi = 'North' $
else $
	str_hemi = 'South'

foreground  = get_foreground()

if ~keyword_set(position) then $
	pos = define_panel(xmaps, ymaps, xmap, ymap, /square, /bar) $
else $
	pos = position

fmt = get_format(sardines=sd)
if sd then $
	ypos = pos[3]-.02 $
else $
	ypos = pos[3]+.01

sjul = (*rad_grd_data[int_hemisphere]).sjuls[index]
fjul = (*rad_grd_data[int_hemisphere]).fjuls[index]

sdate = format_juldate(sjul, /date)
stime = format_juldate(sjul, /short_time)
ftime = format_juldate(fjul, /short_time)

info_str = sdate+' '+stime+'-'+ftime+' UT'; + $
;	', FitOrder: '+string((*rad_map_data[int_hemisphere]).fit_order[index],format='(I1)') + $
;	', '+(rad_map_info[int_hemisphere].mapex ? 'mapEX' : 'APLmap')+' format'

xyouts, pos[0]+0.01, ypos, $
	info_str, /NORMAL, $
	COLOR=foreground, SIZE=charsize, charthick=charthick

end
