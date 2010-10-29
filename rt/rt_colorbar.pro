;+ 
; NAME: 
; RT_COLORBAR
;
; PURPOSE: 
; This function creates a colorbar for raytracing output
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; RT_COLORBAR, bottom=bottom, ncolors=ncolors, vert=vert, right=right, charthick=charthick, $
;								position=position, div=div, range=range, title=title
;
; INPUTS:
;
; OPTIONAL INPUTS:
;
; KEYWORDS:
;
; COMMON BLOCKS:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Written by Sebastien de Larquier, Sept. 2010
;-
pro     rt_colorbar, bottom=bottom, ncolors=ncolors, vert=vert, right=right, left=left, $
								charthick=charthick, charsize=charsize, no_labels=no_labels, $
								position=position, div=div, scale=scale, title=title

if ~keyword_set(vert) and ~keyword_set(horiz) then $
	vertical = 1

; get default from USER_PREFS
if ~keyword_set(scale) then $
	scale = [10.4,11.6]

if ~keyword_set(charsize) then $
	charsize = get_charsize(1,1)

if ~keyword_set(charthick) then $
	charthick = 2.

if keyword_set(vert) then $
	bar = 1

IF keyword_set(position) THEN $
	bpos = position $
else begin
	bpos = [.87,.1,.895,.22]
endelse

; get color preferences
foreground  = get_foreground()
if ~keyword_set(steps) then $
	color_steps = 254
ncolors     = get_ncolors()
bottom      = get_bottom()

cin =    FIX(FINDGEN(color_steps)/(color_steps-1.)*(ncolors-1))+bottom
lvl = scale[0]+FINDGEN(color_steps)*(scale[1]-scale[0])/color_steps

; VERTICAL COLORBAR
if keyword_set(vert) then begin

	xpos= bpos[0]
	ypos= bpos[1]
	xbox= bpos[2]-bpos[0]
	ybox_cols =(bpos[3]-bpos[1])/color_steps
	ybox_ticks=(bpos[3]-bpos[1])/color_steps
	ybox_gnd  =(bpos[3]-bpos[1])/10

	; Draw colored boxes
	FOR level=0,color_steps-1 DO begin
		POLYFILL,[xpos,xpos+xbox,xpos+xbox,xpos], $
			 [ypos+ybox_cols*level,ypos+ybox_cols*level, $
			  ypos+ybox_cols*(level+1),ypos+ybox_cols*(level+1)], $
			  COLOR=cin[level],/NORMAL
; 		PLOTS,xpos+xbox*[0,1,1,0,0],ypos+ybox_ticks*(level+[0,0,1,1,0]), $
; 			COLOR=foreground,/NORMAL, thick=!x.thick
	endfor

	; Plot levels
	IF ~KEYWORD_SET(level_format) THEN BEGIN
		IF FIX((scale[1]-scale[0])/color_steps) NE FLOAT((scale[1]-scale[0]))/color_steps THEN BEGIN
			level_format='(F4.1)'
		ENDIF ELSE BEGIN
			level_format='(I)'
		ENDELSE
	ENDIF
	lvl = scale[0]+FINDGEN(color_steps+1)*(scale[1]-scale[0])/color_steps
	FOR level=0,color_steps, floor(color_steps/div) DO BEGIN
		numb = STRTRIM(FIX(ABS(lvl[level])),2) + $
			'.'+STRTRIM(ABS(FIX(lvl[level]*10)) MOD 10,2)
		IF lvl[level] LT 0 THEN $
			numb='-'+numb
		numb=STRTRIM(STRING(lvl[level],FORMAT=level_format),2)
		lxpos = xpos+1.3*xbox
		align = 0.
		if keyword_set(left) then begin
			lxpos = xpos-0.3*xbox
			align = 1.
		endif
		lypos = ypos+ybox_ticks*level-0.25*ybox_ticks
		if ~keyword_set(no_labels) then $
			XYOUTS, lxpos, lypos, $
				numb, COLOR=foreground, CHARSIZE=.8*charsize,$
				align=align, /NORMAL,charthick=charthick
	ENDFOR
	
	if !d.name eq 'PS' then $
		toffset = .08 $
	else $
		toffset = .04

	; Plot title
	if ~keyword_set(no_labels) then begin
		txpos = xpos+toffset*charsize
		typos = ypos+color_steps*ybox_cols*0.5
		if keyword_set(left) then begin
			txpos = xpos-toffset
		endif
		XYOUTS, txpos, typos, title, COLOR=foreground, $
			ORIENTATION=270,CHARSIZE=charsize,$
			align=.5, /NORMAL,charthick=charthick
	endif
	line1=0.6
	line2=(.6+.3)
	
; HORIZONTAL COLORBAR
endif else if keyword_set(horizontal) then begin

	xpos= bpos[0]
	ypos= bpos[1]
	ybox= bpos[3]-bpos[1]
	xbox_cols =(bpos[2]-bpos[0])/color_steps
	xbox_ticks=(bpos[2]-bpos[0])/color_steps
	xbox_gnd  =(bpos[2]-bpos[0])/10
	
	; Draw colored boxes
	FOR level=0,color_steps-1 DO					$
		POLYFILL,[xpos+xbox_cols*level,xpos+xbox_cols*(1+level),$
			xpos+xbox_cols*(1+level),xpos+xbox_cols*level],	$
			 [ypos,ypos,ypos+ybox,ypos+ybox],	$
			  COLOR=cin[level],/NORMAL

	; Plot levels
	IF ~KEYWORD_SET(level_format) THEN BEGIN
		IF FIX((scale[1]-scale[0])/color_steps) NE FLOAT((scale[1]-scale[0]))/color_steps THEN BEGIN
			level_format='(F4.1)'
		ENDIF ELSE BEGIN
			level_format='(I)'
		ENDELSE
	ENDIF
	lvl = scale[0]+FINDGEN(color_steps+1)*(scale[1]-scale[0])/color_steps
	FOR level=0,color_steps,floor(color_steps/div) DO BEGIN
		numb = STRTRIM(FIX(ABS(lvl[level])),2) + $
			'.'+STRTRIM(ABS(FIX(lvl[level]*10)) MOD 10,2)
		IF lvl[level] LT 0 THEN $
			numb='-'+numb
		numb=STRTRIM(STRING(lvl[level],FORMAT=level_format),2)
		lxpos = xpos+xbox_ticks*level
		lypos = ypos+1.4*ybox
		if keyword_set(under) then begin
			lypos = ypos-0.5*ybox
		endif
		if ~keyword_set(no_labels) then $
			XYOUTS, lxpos, lypos, charthick=charthick,$
				numb,COLOR=foreground,CHARSIZE=.8*charsize,/NORMAL, align=.5
	ENDFOR
	
	; Plot title
	if ~keyword_set(no_labels) then begin
		txpos = xpos+color_steps*xbox_cols*0.5
		typos = ypos+0.06*charsize
		if keyword_Set(under) then $
			typos = ypos-0.05*charsize
		XYOUTS,txpos,typos,title,COLOR=foreground,	$
			ALIGNMENT=0.5,CHARSIZE=charsize,/NORMAL,charthick=charthick
	endif
	line1=0.6
	line2=(0.5+.5)
	
endif




END