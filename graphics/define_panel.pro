;+ 
; NAME: 
; DEFINE_PANEL
; 
; PURPOSE: 
; This function returns the coordinates of ONE plotting panel 
; according to the total amount of plots on a page in normalized coordinates.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; Result = DEFINE_PANEL(Xmaps, Ymaps, Xmap, Ymap)
;
; OPTIONAL INPUTS:
; Xmaps: The total number of columns of plots on the resulting page.
; Default is 1.
;
; Ymaps: The total number of rows of plots on the resulting page.
; Default is 1.
;
; Xmap: The current horizontal (column) index of the plot for which 
; to calculate the position.
; Default is 0.
;
; Ymap: The current vertical (row) index of the plot for which to
; calculate the position.
; Default is 0.
;
; KEYWORD PARAMETERS:
; ASPECT: Set this keyword to force the aspect ratio, i.e. the ratio
; width/height.
;
; BAR: Set this to allow for room of a colorbar on the
; right of your plots.
;
; NO_CENTRE: Set this and panels will not be centred on the page.
;
; NO_TITLE: Set this to indicate that no big title will
; be written above the plot, hence giving more vertical space to fill with the plot.
;
; SQUARE: It constrains the panels to be square.
;
; WITH_INFO: Set this keyword to leave some extra space on the top for plotting noise
; and frequency info panels.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's DEFINE_PANEL.
; Written by Lasse Clausen, Nov, 24 2009
;-
function define_panel, xmaps, ymaps, xmap, ymap,$
	square=square, bar=bar, aspect=aspect, $
	no_centre=no_centre,no_title=no_title, with_info=with_info, $
	next=next, same=same, $
	xsize=xsize, ysize=ysize, xorigin=xorigin, yorigin=yorigin

if keyword_set(next) then begin
	get_recent_panel, rxmaps, rymaps, rxmap, rymap
	xmaps = rxmaps
	ymaps = rymaps
	xmap = ( (rxmap+1) eq rxmaps ? 0 : rxmap+1 )
	ymap = ( (rxmap+1) eq rxmaps ? rymap+1 : rymap )
endif

if keyword_set(same) then begin
	get_recent_panel, rxmaps, rymaps, rxmap, rymap
	xmaps = rxmaps
	ymaps = rymaps
	xmap = rxmap
	ymap = rymap
endif

; Check for bad x and y
if xmap ge xmaps then begin
	prinfo, 'xmap out of bounds: '+strjoin(strtrim(string([xmaps, ymaps, xmap, ymap]),2),',')
	return, [0.,0.,1.,1.]
endif
if ymap ge ymaps then begin
	prinfo, 'ymap out of bounds: '+strjoin(strtrim(string([xmaps, ymaps, xmap, ymap]),2),',')
	return, [0.,0.,1.,1.]
endif

; Default is one panel on screen
IF N_PARAMS() NE 4 and ~keyword_set(next) THEN BEGIN 
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
ENDIF

; Initialize plotting preferences
; x,ysize	-	proportion of screen to put panels in
; x,yorigin	-	where to start page from
; l,r,t,bmargin -	left, right, top and bottom margins around plot
;			window as fractions of the panel
; If set_panel_format,/sardines is in force then 
; tmargin=bmargin=0 and move
; things about slightly
if ~keyword_set(xsize) then begin
	IF KEYWORD_SET(bar) THEN $
		xsize = 0.83 $
	else $
		xsize = 0.95
endif
if ~keyword_set(ysize) then begin
	IF KEYWORD_SET(no_title) THEN $
		ysize = 0.93 $
	else if keyword_set(with_info) then $
		ysize = 0.7 $
	else $
		ysize = 0.83
endif
if ~keyword_set(xorigin) then $
	xorigin = 0.03
if ~keyword_set(yorigin) then $
	yorigin = 0.05

lmargin = 0.15
rmargin = 0.05
tmargin = 0.10
bmargin = 0.15

; guppies or sardines
fmt = get_format(sardines=sd, square=sq, tokyo=ty)
IF sd THEN BEGIN
	tmargin = 0.03
	bmargin = 0.03
	ysize   = ysize/1.1
	yorigin = 0.1
ENDIF
; tokyo or kansas
IF ty THEN BEGIN
	lmargin = 0.03
	rmargin = 0.03
	xsize   = xsize/1.1
	xorigin = 0.1
ENDIF
	
; Calculate size of each panel
xframe = xsize/xmaps
yframe = ysize/ymaps	

; If /SQUARE option is set then constrain plotting window to be square -
; recalculate xframe and yframe accordingly, taking into account the
; device aspect ratio
IF KEYWORD_SET(square) OR sq THEN $
	aspect_ratio = float(!D.Y_SIZE)/float(!D.X_SIZE) $
else if keyword_set(aspect) then $
	aspect_ratio = aspect*float(!D.Y_SIZE)/float(!D.X_SIZE)

if keyword_set(aspect_ratio) then begin
	; calculate size of plotting area
	xpanel = xframe*(1.-lmargin-rmargin)
	ypanel = yframe*(1.-tmargin-bmargin)
	; check if total width when using aspect ratio
	; on panel width would exceed total width
	; if yes, make height smaller
	IF xmaps*ypanel*aspect_ratio/(1.-lmargin-rmargin) GT xsize THEN $
		ypanel = xpanel/aspect_ratio $
	ELSE $
		xpanel = ypanel*aspect_ratio
	; calculate size of panel
	xframe = xpanel/(1.-lmargin-rmargin)
	yframe = ypanel/(1.-tmargin-bmargin)
endif

x1 = (xmap + lmargin)*xframe
y1 = (ymaps - ymap - 1. + bmargin)*yframe
x2 = (xmap + 1. - rmargin)*xframe
y2 = (ymaps - ymap - tmargin)*yframe

; If panels are forced square, then centre plotting area
IF KEYWORD_SET(NO_CENTRE) THEN BEGIN
	xcentre = 0.
	ycentre = 0.
ENDIF ELSE BEGIN
	xcentre = (xsize - xframe*xmaps)*0.5
	ycentre = (ysize - yframe*ymaps)*0.5
ENDELSE
	
pos = [ $
	x1+xcentre+xorigin, $
	y1+ycentre+yorigin, $
	x2+xcentre+xorigin, $
	y2+ycentre+yorigin $
]

set_recent_panel, xmaps, ymaps, xmap, ymap

return, pos

END
