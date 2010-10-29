;+ 
; NAME: 
; THE_FGM_PLOT_OVERVIEW
;
; PURPOSE: 
; The procedure plots a overview of Themis FGM data. It plots three panels, BX_GSE, BY_GSM, BZ_GSM, BT.
; If more than one spacecraft number is given, the data is for each parameter is
; overplotted in one panel. It simply calls THE_FGM_PLOT_PANEL.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:  
; THE_FGM_PLOT_OVERVIEW
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
; BAR: Set this keyword to allow for space right of the panel for a colorbar.
;
; SILENT: Set this keyword to surpress all messages/warnings.
;
; CHARTHICK: Set this keyword to change the font thickness.
;
; CHARSIZE: Set this keyword to change the font size. 
;
; PSYM: Set this keyword to change the symbol used for plotting.
;
; XTICKS: Set this keyword to change the number of major x tick marks.
;
; XMINOR: Set this keyword to change the number of minor x tick marks.
;
; YTICKS: Set this keyword to change the number of major y tick marks.
;
; YMINOR: Set this keyword to change the number of minor y tick marks.
;
; LINESTYLE: Set this keyword to change the style of the line.
; Default is 0 (solid).
;
; LINECOLOR: Set this keyword to a color index to change the color of the line.
; Default is black.
;
; LINETHICK: Set this keyword to change the thickness of the line.
; Default is 1.
;
; XTICKFORMAT: Set this keyword to change the formatting of the time fopr the x axis.
;
; YTICKFORMAT: Set this keyword to change the formatting of the y axis values.
;
; WITH_INFO: Set this keyword to leave some extra space on the top for plotting noise
; and frequency info panels.
;
; EXAMPLE:
; 
; MODIFICATION HISTORY: 
; Written by: Lasse Clausen, 2010.
;-
pro the_fgm_plot_overview, $
	date=date, time=time, long=long, $
	probe=probe, silent=silent, coords=coords, $
	charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	with_info=with_info

common the_data_blk

if ~keyword_set(probe) then begin
	if ~keyword_set(silent) then $
		prinfo, 'PROBE not set, using all.'
	_probe = ['a', 'b', 'c', 'd', 'e']
endif else $
	_probe = strlowcase(probe)
npr = n_elements(_probe)
if npr gt 1 then $
	bar = 1 $
else $
	bar = 0

num_probe = byte(_probe) - (byte('a'))[0]

d = get_format(sard=sard, gupp=gupp)
set_format, /sardines
clear_page

for p=0, npr-1 do begin


	if n_elements(linecolor) gt 0 then $
		_linecolor = linecolor $
	else $
		_linecolor = the_color(num_probe[p])

	if num_probe[p] lt 0 or num_probe[p] gt 4 then  begin
		prinfo, 'PROBE must be a <= PROBE <= e.'
		continue
	endif

	if the_fgm_info[num_probe[p]].nrecs eq 0L then begin
		prinfo, 'No data loaded for PROBE: '+string(_probe[p])
		continue
	endif

	xstyle = 5
	ystyle = 5
	if p eq 0 then begin
		xstyle = 1
		ystyle = 1
	endif

	the_fgm_plot_panel, 1, 4, 0, 0, param='bx_gse', $
		date=date, time=time, long=long, coords=coords, $
		probe=_probe[p], silent=silent, bar=bar, $
		charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
		linestyle=linestyle, linecolor=_linecolor, linethick=linethick, $
		xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
		with_info=with_info, xstyle=xstyle, ystyle=ystyle, /first

	the_fgm_plot_panel, 1, 4, 0, 1, param='by_gsm', $
		date=date, time=time, long=long, coords=coords, $
		probe=_probe[p], silent=silent, bar=bar, $
		charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
		linestyle=linestyle, linecolor=_linecolor, linethick=linethick, $
		xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
		with_info=with_info, xstyle=xstyle, ystyle=ystyle, /first

	the_fgm_plot_panel, 1, 4, 0, 2, param='bz_gsm', $
		date=date, time=time, long=long, coords=coords, $
		probe=_probe[p], silent=silent, bar=bar, $
		charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
		linestyle=linestyle, linecolor=_linecolor, linethick=linethick, $
		xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
		with_info=with_info, xstyle=xstyle, ystyle=ystyle, /first

	the_fgm_plot_panel, 1, 4, 0, 3, param='bt', $
		date=date, time=time, long=long, coords=coords, $
		probe=_probe[p], silent=silent, bar=bar, $
		charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
		linestyle=linestyle, linecolor=_linecolor, linethick=linethick, $
		xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
		with_info=with_info, xstyle=xstyle, ystyle=ystyle, /first, /last

endfor

if npr gt 1 then begin
	position = define_panel(1, 4, 0, 0, bar=bar, with_info=with_info)
	line_legend, [position[2]+0.01,position[1]], ['ThA','ThB','ThC','ThD','ThE'], $
		color=[the_color(0), the_color(1), the_color(2), the_color(3), the_color(4)], thick=linethick, $
		charthick=charthick, charsize=.6*charsize
endif

plot_title, 'Themis FGM Overview', $
	top_right_title=format_juldate(the_fgm_info[num_probe[0]].sjul)+'!C!5 to !C!5'+format_juldate(the_fgm_info[num_probe[0]].fjul)

set_format, sard=sard, gupp=gupp
end
