;+ 
; NAME: 
; EARTH_PLOT 
; 
; PURPOSE: 
; This procedure plots a earth at the center of an orbit plot.
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE: 
; EARTH_PLOT
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
pro earth_plot, xy=xy, xz=xz, yz=yz, $
	linestyle=linestyle, color=color, linethick=linethick

if ~keyword_set(linecolor) then $
	linecolor = get_foreground()

nn = 100
angs = findgen(nn)/(nn-1.)*2.*!pi

polyfill, sin(angs), cos(angs), color=get_background(), noclip=0

oplot, sin(angs), cos(angs), $
	thick=linethick, color=linecolor, linestyle=linestyle, noclip=0

if keyword_set(xy) or keyword_set(xz) then $
	polyfill, -sin(angs[0:nn/2]), cos(angs[0:nn/2]), color=color, noclip=0

end
