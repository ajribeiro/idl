;+ 
; NAME: 
; ASI_PLOT_KEOGRAM
; 
; PURPOSE: 
; This procedure plots one panel with a keogram of the currently loaded
; All-Sky Imager data on a page and add a title and a colorbar.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; ASI_PLOT_KEOGRAM
;
; KEYWORD PARAMETERS:
; DATE: A scalar giving the date of the image to plot,
; in YYYYMMDD format.
;
; TIME: A scalar giving the time of the image to plot, in HHII format.
;
; LONG: Set this keyword to indicate that the TIME value is in HHIISS
; format rather than HHII format.
;
; SCALE: Set this keyword to a 2-element vector which contains the 
; upper and lower limit of the data range.
;
; SILENT: Set this keyword to surpress warnings but not error messages.
;
; CHARTHICK: Set this keyword to change the font thickness.
;
; CHARSIZE: Set this keyword to change the font size.
;
; YTICKS: Set this keyword to change the number of major y tick marks.
;
; YMINOR: Set this keyword to change the number of minor y tick marks.
;
; YRANGE: Set this keyword to change the range of the y axis.
;
; YTICKFORMAT: Set this keyword to change the formatting of the y axis values.
;
; YTICKNAME: Set this keyword to an array of strings to put on the major tickmarks of the x axis.
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
pro asi_plot_keogram, date=date, time=time, long=long, $
	scale=scale, silent=silent, $
	charthick=charthick, charsize=charsize, $
	yrange=yrange, yticks=yticks, yminor=yminor, ytickformat=ytickformat, $
	ytickname=ytickname

common asi_data_blk

if asi_info.nrecs eq 0L then begin
	prinfo, 'No data loaded.'
	return
endif

clear_page

asi_plot_keogram_panel, 1, 1, 0, 0, /bar, $
	date=date, time=time, long=long, $
	scale=scale, silent=silent, $
	charthick=charthick, charsize=charsize, $
	yrange=yrange, yticks=yticks, yminor=yminor, ytickformat=ytickformat, $
	ytickname=ytickname, /last

sdate = format_juldate(!x.crange[0])
right_title = sdate+'!C!5 to !C!5'+format_juldate(!x.crange[1])

plot_colorbar, 1, 1, 0, 0, $
	param='asi', scale=scale

plot_title, 'ASI Keogram', strupcase(asi_info.site), $
	top_right_title=right_title

end

