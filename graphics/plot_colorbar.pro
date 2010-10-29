;+ 
; NAME: 
; PLOT_COLORBAR 
; 
; PURPOSE: 
; This procedure plots a colorbar next to a plot panel. If no position
; is given, the DEFINE_CB_POSITION function is used.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; PLOT_COLORBAR
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
; POSITION: Set this to a 4-elements array specifying the colorbar's position
; if you don't want this routine to calculate where to put it.
;
; LEGEND: Set this to a string to overwrite the default of the colorbar's title
; depending on the loaded parameter.
;
; LEVEL_FORMAT: Set this to a format code to use for the labels.
;
; NO_GND: Set this keyword to surpress the plotting of a ground scatter box.
;
; CHARSIZE: Set this to a number to override the default charsize.
;
; SCALE: Set this to a 2-element vector indicating the scale of the colorbar.
; If omitted, the scale from the common block USER_PREFS is used. 
;
; PARAMETER: Set this to a string to indicate the parameter for which this colorbar
; is valid. If omitted, the parameter from the common block USER_PREFS is used.
;
; WITH_INFO: Set this keyword to leave some extra space on the top for plotting noise
; and frequency info panels.
;
; VERTICAL: Set this keyword to plot a vertical colorbar right of the panel. This is the default.
;
; HORIZONTAL: Set this keyword to plot a horizontal colorbar above the panel.
;
; SQUARE: Set this keyword to indicate that the panel is a square.
;
; LEFT: Set this keyword to put labels on the left of a vertical colorbar, rather than on the right.
;
; UNDER: Set this keyword to put labels under a horizontal colorbar, rather than on top.
;
; CHARTHICK: Set this to a number to override the default character thickness.
;
; GROUND: Set this to a velocity value. In the colorbar all velocities within [-GROUND, GROUND] 
; will then be colored gray. Use this keyword in conjunction with the GROUND keyword
; in RAD_FIT_PLOT_RTI.
;
; BAR: Set this keyword to indicate that the panel position next to which you 
; wish to place the colorbar was calculated using the BAR keyword.
;
; GAP: Set this keyword to the size of the gap between the panel and the
; colorbar in normal coordinates (default is 5% of the panel width).
;
; WIDTH: Set this keyword to the width of the colorbar in normalized coordinates.
; Default is 0.015.
;
; NO_LABELS:
;
; NO_ROTATE: This routine plots the colorbar for the parameter given in the
; PARAM keyword. If that keyword is not provided, the parameter is determined
; using GET_PARAMETER(). If the parameter is 'velocity', the default colortable
; is rotated, such that negative values (i.e. motion away from the radar) is 
; colored in reds, whereas motion towards (positive velocity values) is colored
; in blues. Set this keyword to prevent PLOT_COLORBAR from rotating the colorbar.
;
; STEPS: Set this keyword to give the number of steps in the colorbar. If not
; provided, the output from GET_COLORSTEPS() is used.
;
; NO_TITLE: Set this keyword to use the NO_TITLE keyword when calculating the
; position of the panel besides which the colorbar is placed.
;
; PANEL_POSITION: Set this keyword to a 4-element vector containing the normalized
; coordinates of the panel besides which you whcih to place the colorbar.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's PLOT_COLOURBAR.
; Written by Lasse Clausen, Nov, 24 2009
;-
pro plot_colorbar, xmaps, ymaps, xmap, ymap, position=position, panel_position=panel_position, $
	legend=legend, level_format=level_format, charsize=charsize, $
	charthick=charthick, ground=ground, bar=bar, gap=gap, width=width, $
	no_gnd=no_gnd, scale=scale, parameter=parameter, with_info=with_info, $
	square=square, horizontal=horizontal, vertical=vertical, $
	no_labels=no_labels, no_rotate=no_rotate, left=left, under=under, $
	steps=steps, no_title=no_title, leg_offset=leg_offset

; Allow several color bars to be stacked
IF N_PARAMS() NE 4 THEN BEGIN 
	xmaps = 1
	xmap  = 0 
	ymaps = 1
	ymap  = 0
ENDIF

if ~keyword_set(vertical) and ~keyword_set(horizontal) then $
	vertical = 1

; get default from USER_PREFS
if ~keyword_set(parameter) then $
	parameter = get_parameter()

if ~keyword_set(scale) then $
	scale = get_default_range(parameter)

if ~keyword_set(legend) then $
	legend = get_default_title(parameter)

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if keyword_set(vertical) then $
	bar = 1

IF KEYWORD_SET(position) THEN $
	bpos = position $
else begin
	if ~keyword_set(panel_position) then $
		panel_position = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, square=square, with_info=with_info, no_title=no_title)
	bpos = define_cb_position(panel_position, vertical=vertical, horizontal=horizontal, gap=gap, width=width)
endelse

if !d.name eq 'PS' then $
	toffset = .08 $
else $
	toffset = .032
if ~keyword_set(leg_offset) then begin
	if keyword_set(vertical) then begin
		if keyword_set(left) then $
			leg_offset = -(toffset*charsize - (bpos[2]-bpos[0])) $
		else $
			leg_offset = toffset*charsize
	endif else begin
		if keyword_set(under) then $
			leg_offset = -(toffset) $ ;+charsize) $
		else $
			leg_offset = toffset
	endelse
endif

; get color preferences
foreground  = get_foreground()
if ~keyword_set(steps) then $
	color_steps = get_colorsteps() $
else $
	color_steps = steps
ncolors     = get_ncolors()
bottom      = get_bottom()

; and some user preferences
scatterflag = rad_get_scatterflag()

cin =    FIX(FINDGEN(color_steps)/(color_steps-1.)*(ncolors-1))+bottom
lvl = scale[0]+FINDGEN(color_steps)*(scale[1]-scale[0])/color_steps
; Switch color map for velocity plot, to maintain the red shift
; convention as well as the radar convention
if ~keyword_set(no_rotate) then begin
	IF parameter EQ 'velocity' then begin
		if strcmp(get_colortable(), 'bluewhitered', /fold) or strcmp(get_colortable(), 'leicester', /fold) THEN $
			cin = ROTATE(cin, 2) $
		else $
			cin = shift(cin, color_steps/2)
	endif
endif
;	and ~keyword_set(no_rotate) and ~strcmp(get_colortable(), 'bluewhitered', /fold) THEN $
;	cin = shift(cin, color_steps/2)
;	cin = ROTATE(cin, 2)

; VERTICAL COLORBAR
if keyword_set(vertical) then begin

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
		PLOTS,xpos+xbox*[0,1,1,0,0],ypos+ybox_ticks*(level+[0,0,1,1,0]), $
			COLOR=foreground,/NORMAL, thick=!x.thick
	endfor

	if keyword_set(ground) and parameter eq 'velocity' then begin
		if ground gt 0 then begin
			ybox_grd  = ground*(bpos[3]-bpos[1])/(scale[1]-scale[0])
			POLYFILL,[xpos,xpos+xbox,xpos+xbox,xpos], $
				[ypos+ybox_cols*color_steps/2-ybox_grd,ypos+ybox_cols*color_steps/2-ybox_grd, $
				ypos+ybox_cols*color_steps/2+ybox_grd,ypos+ybox_cols*color_steps/2+ybox_grd], $
				COLOR=get_gray(),/NORMAL
			PLOTS,xpos+xbox*[0,1,1,0,0],[ $
				ypos+ybox_cols*color_steps/2-ybox_grd, $
				ypos+ybox_cols*color_steps/2-ybox_grd, $
				ypos+ybox_cols*color_steps/2+ybox_grd, $
				ypos+ybox_cols*color_steps/2+ybox_grd, $
				ypos+ybox_cols*color_steps/2-ybox_grd], $
				COLOR=foreground,/NORMAL, thick=!x.thick
			plots, xpos+xbox*[0,1.], [ypos+ybox_cols*color_steps/2, $
				ypos+ybox_cols*color_steps/2], $
				COLOR=foreground,/NORMAL, thick=!x.thick
		endif
	endif

	; Plot levels
	IF ~KEYWORD_SET(level_format) THEN BEGIN
		IF FIX((scale[1]-scale[0])/color_steps) NE FLOAT((scale[1]-scale[0]))/color_steps THEN BEGIN
			level_format='(F10.1)'
		ENDIF ELSE BEGIN
			level_format='(I)'
		ENDELSE
	ENDIF
	lvl = scale[0]+FINDGEN(color_steps+1)*(scale[1]-scale[0])/color_steps
	FOR level=(parameter EQ 'velocity' and scatterflag eq 3),color_steps DO BEGIN
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

	; Plot title
	if ~keyword_set(no_labels) then begin
		txpos = xpos+leg_offset
		;plots, [txpos, txpos], [0,1], /norm
		typos = ypos+color_steps*ybox_cols*0.5
		XYOUTS, txpos, typos, legend, COLOR=foreground, $
			ORIENTATION=( keyword_set(left) ? 90 : 270 ),CHARSIZE=charsize,$
			align=.5, /NORMAL,charthick=charthick
	endif
	line1=0.6
	line2=(.6+.3)
	
	; Add ground scatter box (or other annotation...)
	IF ~KEYWORD_SET(no_gnd) THEN BEGIN
		IF parameter EQ 'velocity' AND scatterflag EQ 3 THEN BEGIN
			POLYFILL,[xpos,xpos+xbox,xpos+xbox,xpos],		$
				 [ypos-0.15*ybox_gnd,ypos-0.15*ybox_gnd,		$
				  ypos-(0.15+.5)*ybox_gnd,ypos-(0.15+.5)*ybox_gnd],		$
				  COLOR=get_gray(),/NORMAL
			gxpos = xpos+1.4*xbox
			align = 0.
			if keyword_set(left) then begin
				gxpos = xpos-.4*xbox
				align = 1.
			endif
			XYOUTS,gxpos,ypos-line1*ybox_gnd,'Ground',/NORMAL,$
				COLOR=foreground,CHARSIZE=0.8*charsize, align=align,charthick=charthick
			XYOUTS,gxpos,ypos-line2*ybox_gnd,'Scatter',/NORMAL,$
				COLOR=foreground,CHARSIZE=0.8*charsize, align=align,charthick=charthick
		ENDIF
		IF scatterflag EQ 1 and parameter EQ 'velocity' THEN BEGIN
			XYOUTS,xpos,ypos-line1*ybox_gnd,'Ground',/NORMAL,COLOR=foreground,$
				CHARSIZE=0.8*charsize,charthick=charthick
			XYOUTS,xpos,ypos-line2*ybox_gnd,'scat only',/NORMAL,COLOR=foreground,$
				CHARSIZE=0.8*charsize,charthick=charthick
		ENDIF
		IF scatterflag EQ 2 and parameter EQ 'velocity' THEN BEGIN
			XYOUTS,xpos,ypos-line1*ybox_gnd,'Ionospheric',/NORMAL,COLOR=foreground,$
				CHARSIZE=0.8*charsize,charthick=charthick
			XYOUTS,xpos,ypos-line2*ybox_gnd,'scat only',/NORMAL,COLOR=foreground,$
				CHARSIZE=0.8*charsize,charthick=charthick
		ENDIF
	ENDIF
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

	; Draw outline
	FOR level=0,color_steps-1 DO 					$
		PLOTS,xpos+xbox_ticks*(level+[0,0,1,1,0]),ypos+ybox*[0,1,1,0,0], $
			COLOR=foreground,/NORMAL, thick=!x.thick

	; Plot levels
	IF ~KEYWORD_SET(level_format) THEN BEGIN
		IF FIX((scale[1]-scale[0])/color_steps) NE FLOAT((scale[1]-scale[0]))/color_steps THEN BEGIN
			level_format='(F10.1)'
		ENDIF ELSE BEGIN
			level_format='(I)'
		ENDELSE
	ENDIF
	lvl = scale[0]+FINDGEN(color_steps+1)*(scale[1]-scale[0])/color_steps
	FOR level=(parameter EQ 'velocity' and scatterflag eq 3),color_steps DO BEGIN
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
		typos = ypos+leg_offset
		XYOUTS,txpos,typos,legend,COLOR=foreground,	$
			ALIGNMENT=0.5,CHARSIZE=charsize,/NORMAL,charthick=charthick
	endif
	line1=0.6
	line2=(0.5+.5)
	
	; Add ground scatter box (or other annotation...)
	IF ~KEYWORD_SET(no_gnd) THEN BEGIN
		IF parameter EQ 'velocity' AND scatterflag EQ 3 THEN BEGIN
			POLYFILL, [xpos-0.15*xbox_gnd,xpos-0.15*xbox_gnd,		$
				  xpos-(0.15+.5)*xbox_gnd,xpos-(0.15+.5)*xbox_gnd],		$
					[ypos,ypos+ybox,ypos+ybox,ypos],		$
				  COLOR=get_gray(),/NORMAL
			gypos1 = ypos+line2*xbox_gnd
			gypos2 = ypos+line1*xbox_gnd
			if keyword_set(under) then begin
				gypos1 = ypos-line1*xbox_gnd
				gypos2 = ypos-line2*xbox_gnd
			endif
			XYOUTS,xpos-(0.15+0.25)*xbox_gnd,gypos1,'Ground',/NORMAL,$
				COLOR=foreground,CHARSIZE=0.8*charsize, align=.5,charthick=charthick
			XYOUTS,xpos-(0.15+0.25)*xbox_gnd,gypos2,'Scatter',/NORMAL,$
				COLOR=foreground,CHARSIZE=0.8*charsize, align=.5,charthick=charthick
		ENDIF
		sypos1 = ypos+line2*xbox_gnd
		sypos2 = ypos+line1*xbox_gnd
		if keyword_set(under) then begin
			sypos1 = ypos-line1*xbox_gnd
			sypos2 = ypos-line2*xbox_gnd
		endif
		IF scatterflag EQ 1 and parameter EQ 'velocity' THEN BEGIN
			XYOUTS,xpos-(0.15+0.25)*xbox_gnd,sypos1,'Ground',/NORMAL,COLOR=foreground,$
				CHARSIZE=0.8*charsize, align=1.,charthick=charthick
			XYOUTS,xpos-(0.15+0.25)*xbox_gnd,sypos2,'scat only',/NORMAL,COLOR=foreground,$
				CHARSIZE=0.8*charsize, align=1.,charthick=charthick
		ENDIF
		IF scatterflag EQ 2 and parameter EQ 'velocity' THEN BEGIN
			XYOUTS,xpos-(0.15+0.25)*xbox_gnd,sypos1,'Ionospheric',/NORMAL,COLOR=foreground,$
				CHARSIZE=0.8*charsize, align=1.,charthick=charthick
			XYOUTS,xpos-(0.15+0.25)*xbox_gnd,sypos2,'scat only',/NORMAL,COLOR=foreground,$
				CHARSIZE=0.8*charsize, align=1.,charthick=charthick
		ENDIF
	ENDIF
endif
END
