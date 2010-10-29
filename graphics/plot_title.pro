;+ 
; NAME: 
; PLOT_TITLE
; 
; PURPOSE: 
; This procedure plots a generall title on the top of a page.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; PLOT_TITLE
;
; OPTIONAL INPUTS:
; Title: A string used as the title.
;
; Subtitle: A string used as the subtitle.
;
; KEYWORD PARAMETERS:
; TOP_RIGHT_TITLE: A title string to put on the top right
;
; TOP_RIGHT_SUBTITLE: A subtitle string to put on the top right
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
pro plot_title, title, subtitle, $
	top_right_title=top_right_title, top_right_subtitle=top_right_subtitle

if n_elements(title) eq 0 then $
	title = ''

if n_elements(subtitle) eq 0 then $
	subtitle = ''

if !d.name eq 'X' then $
	fac = 2. $
else $
	fac = 1.

foreground  = get_foreground()

XYOUTS,0.05,0.91,'!5'+title+'!3',/NORMAL,$
	COLOR=foreground,charSIZE=fac*1.5
XYOUTS,0.05,0.87,'!5'+subtitle+'!3',/NORMAL,$
	COLOR=foreground,charSIZE=fac

if keyword_set(top_right_title) then $
	xyouts, 0.87, 0.94, '!5'+top_right_title+'!3', /NORMAL,ALIGNMENT=0.5, $
		COLOR=foreground,charSIZE=fac*.85

if keyword_set(top_right_subtitle) then $
	XYOUTS, 0.87, 0.85, top_right_subtitle, $
		/NORMAL, ALIGNMENT=0.5, CHARSIZE=fac*0.7,COLOR=foreground

end
