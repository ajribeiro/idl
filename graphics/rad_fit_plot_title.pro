;+ 
; NAME: 
; RAD_FIT_PLOT_TITLE
; 
; PURPOSE: 
; This procedure plots a generall title on the top of a page.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; RAD_FIT_PLOT_TITLE
;
; OPTIONAL INPUTS:
; Title: A string used as the title, default is SUPERDARN PARAMETER PLOT.
;
; Subtitle: A string used as the subtitle, default radar name: parameter.
;
; KEYWORD PARAMETERS:
; NO_DATE: Set this keyword to surpress plotting of date/time information.
;
; SCAN_ID: Set this keyword to the numeric scan id to plot in the title.
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
pro rad_fit_plot_title, title, subtitle, no_date=no_date, scan_id=scan_id, param=param

common rad_data_blk

; get index for current data
data_index = rad_fit_get_data_index()
if data_index eq -1 then $
	return

if n_elements(title) eq 0 then $
	title = ''

if n_elements(subtitle) eq 0 then $
	subtitle = ''

if strlen(title) eq 0 then $
	title = 'SUPERDARN PARAMETER PLOT'

if ~keyword_set(param) then $
	param = get_parameter()

fitstr = 'N/A'
if (*rad_fit_info[data_index]).fitex then $
	fitstr = 'fitEX'

if (*rad_fit_info[data_index]).fitacf then $
	fitstr = 'fitACF'

if (*rad_fit_info[data_index]).fit then $
	fitstr = 'fit'

if (*rad_fit_info[data_index]).filtered then $
	filterstr = 'filtered ' $
else $
	filterstr = ''

if strlen(subtitle) eq 0 then begin
	if (*rad_fit_info[data_index]).nrecs gt 0L then $
		subtitle = (*rad_fit_info[data_index]).name+': '+param+' ('+filterstr+fitstr+')' $
	else $
		subtitle = 'No data loaded.'
endif

if keyword_set(no_date) then begin
	right_title = ''
	right_subtitle = ''
endif else begin
	sdate = format_juldate((*rad_fit_info[data_index]).sjul)
	right_title = sdate+'!C!5 to !C!5'+format_juldate((*rad_fit_info[data_index]).fjul)
	right_subtitle = ''
endelse

plot_title, title, subtitle, top_right_title=right_title, top_right_subtitle=right_subtitle

end
