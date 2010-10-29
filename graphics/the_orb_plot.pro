;+ 
; NAME: 
; THE_ORB_PLOT
;
; PURPOSE: 
; The procedure plots an overview page of Themis orbit data with a title.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:  
; THE_ORB_PLOT
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
pro the_orb_plot, date=date, time=time, long=long, $
	probe=probe, xrange=xrange, yrange=yrange, bar=bar, $
	xy=xy, xz=xz, yz=yz, coords=coords, $
	bowshock=bowshock, magnetopause=magnetopause, $
	silent=silent, mark_interval=mark_interval, $
	mark_charsize=mark_charsize, mark_charthick=mark_charthick

if ~keyword_set(probe) then $
	probe = ['a','b','c','d','e']

clear_page

the_orb_plot_panel, 1, 1, 0, 0, date=date, time=time, long=long, $
	probe=probe, xrange=xrange, yrange=yrange, bar=bar, $
	xy=xy, xz=xz, yz=yz, coords=coords, $
	silent=silent, mark_interval=mark_interval, $
	mark_charsize=mark_charsize, mark_charthick=mark_charthick, /last, /first

if keyword_set(bowshock) then $
	overlay_bs, xy=xy, xz=xz, yz=yz

if keyword_set(magnetopause) then $
	overlay_mp, xy=xy, xz=xz, yz=yz

sfjul, date, time, sjul, fjul

plot_title, 'Themis Orbit', '', top_right_title=format_juldate(sjul)+'!C'+format_juldate(fjul)

end