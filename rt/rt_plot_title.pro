;+ 
; NAME: 
; RT_PLOT_TITLE
; 
; PURPOSE: 
; This procedure plots a generall title on the top of a page.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; RT_PLOT_TITLE
;
; OPTIONAL INPUTS:
; Title: A string used as the title, default is RAYTRACING PARAMETER PLOT.
;
; Subtitle: A string used as the subtitle, default radar name: parameter.
;
; KEYWORD PARAMETERS:
; NO_DATE: Set this keyword to surpress plotting of date/time information.
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
pro rt_plot_title, title, subtitle, no_date=no_date, param=param

common rt_data_blk

if n_elements(title) eq 0 then $
	title = ''

if n_elements(subtitle) eq 0 then $
	subtitle = ''

if strlen(title) eq 0 then $
	title = 'RAYTRACING PARAMETER PLOT'

if ~keyword_set(param) then $
	param = 'power'

if strlen(subtitle) eq 0 then begin
	if rt_info.nrecs gt 0L then $
		subtitle = rt_info.name+': '+param $
	else $
		subtitle = 'No data loaded.'
endif

if keyword_set(no_date) then begin
	right_title = ''
	right_subtitle = ''
endif else begin
	sdate = format_juldate(rt_info.sjul)
	right_title = sdate+'!C!5 to !C!5'+format_juldate(rt_info.fjul)
	right_subtitle = ''
endelse

plot_title, title, subtitle, top_right_title=right_title, top_right_subtitle=right_subtitle

end
