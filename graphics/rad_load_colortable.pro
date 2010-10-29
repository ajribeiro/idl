;+ 
; NAME: 
; RAD_LOAD_COLORTABLE
; 
; PURPOSE: 
; This procedure loads colortables for various purposes. By default
; it loads a colortable based on AJ Ribiero's colors. Through keywords
; is can also load the Leicester/Cutlass/SuperDARN color table from the file
; GETENV('RAD_RESOURCE_PATH')+'/cut_col_tab.dat' and others.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; RAD_LOAD_COLORTABLE
;
; KEYWORDS:
; BW: Set this keyword to load the grayscale color table, ranging from light gray (lowest)
; to black (highest).
;
; WHITERED: Set this keyword to load a color table ranging from light gray (lowest) to red (highest).
;
; BLUEWHITERED: Set this keyword to load a color table ranging from blue (lowest)
; through light gray (middle) to red (highest).
;
; INVERSE: Set this keyword to 
;
; COMMON BLOCKS: 
; USER_PREFS: User preferences.
;
; COLOR_PREFS: Color preferences.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's CUT_COL_TAB.
; Written by Lasse Clausen, Nov, 24 2009
;-
pro rad_load_colortable, bw=bw, whitered=whitered, bluewhitered=bluewhitered, $
	leicester=leicester, themis=themis, aj=aj

common color_prefs

if keyword_set(leicester) then begin
	tab_file = GETENV('RAD_RESOURCE_PATH')+'/leicester_ct.dat'
	if ~file_test(tab_file) then begin
		prinfo, 'Cannot load colortable. File does not exist: ', tab_file, /force
		return
	endif
	restore, tab_file
	tvlct, red, green, blue
	cp_colortable = 'LEICESTER'
	return
endif

if keyword_set(themis) then begin
	loadct2, 43
	cp_colortable = 'THEMIS'
	return
endif

ncolors = get_ncolors()
bottom = get_bottom()
black = get_black()
white = get_white()
gray = get_gray()

red   = bytarr(ncolors)
green = bytarr(ncolors)
blue  = bytarr(ncolors)

if ~keyword_set(bw) and ~keyword_set(whitered) and ~keyword_set(bluewhitered) and ~keyword_set(aj) then $
	aj = 1

if keyword_set(whitered) then BEGIN
	gray_base=0.9
	red   = findgen(ncolors)*(1.-gray_base) + (ncolors-1.)*gray_base
	green = ((ncolors-1.)-findgen(ncolors))*gray_base
	blue  = ((ncolors-1.)-findgen(ncolors))*gray_base
	cp_colortable = 'WHITERED'
ENDIF ELSE if keyword_set(bluewhitered) then BEGIN
	gray_base=0.95
	red[0:ncolors/2-1]         = reverse(((ncolors-1.)-2.*findgen(ncolors/2))*gray_base)
	green[0:ncolors/2-1]       = reverse(((ncolors-1.)-2.*findgen(ncolors/2))*gray_base)
	blue[0:ncolors/2-1]        = reverse(2.*findgen(ncolors/2)*(1.-gray_base) + (ncolors-1.)*gray_base)
	red[ncolors/2:ncolors-1]   = 2.*findgen(ncolors/2+1)*(1.-gray_base) + (ncolors-1.)*gray_base
	green[ncolors/2:ncolors-1] = ((ncolors-1.)-2.*findgen(ncolors/2+1))*gray_base
	blue[ncolors/2:ncolors-1]  = ((ncolors-1.)-2.*findgen(ncolors/2+1))*gray_base
	cp_colortable = 'BLUEWHITERED'
endif else if keyword_set(aj) then begin
	rcol = reverse(shift(reverse([ 37,     255,     255,     255,     124,       0,       0,       0]), 4))
	gcol = reverse(shift(reverse([255,     248,     135,      23,       0,       6,     209,     255]), 4))
	bcol = reverse(shift(reverse([  0,       0,       0,       0,     255,     255,     255,     188]), 4))
	nncolors = n_elements(rcol)
	d = ncolors/(nncolors-1)
	for i=0, nncolors-2 do begin
		red[findgen(d+(i eq nncolors-2))+i*d] = rcol[i]+findgen(d+(i eq nncolors-2))/float(d-1+(i eq nncolors-2))*(rcol[i+1]-rcol[i])
		green[findgen(d+(i eq nncolors-2))+i*d] = gcol[i]+findgen(d+(i eq nncolors-2))/float(d-1+(i eq nncolors-2))*(gcol[i+1]-gcol[i])
		blue[findgen(d+(i eq nncolors-2))+i*d] = bcol[i]+findgen(d+(i eq nncolors-2))/float(d-1+(i eq nncolors-2))*(bcol[i+1]-bcol[i])
	endfor
	cp_colortable = 'AJ'
endif

ored   = bytarr(256)
ogreen = bytarr(256)
oblue  = bytarr(256)
ored[bottom:bottom+ncolors-1]   = red
ogreen[bottom:bottom+ncolors-1] = green
oblue[bottom:bottom+ncolors-1]  = blue

; Black and white
ored[black]   = 0
oblue[black]  = 0
ogreen[black] = 0
ored[white]   = 255
oblue[white]  = 255
ogreen[white] = 255

; Ground scatter colour (grey)
ored[gray]    = 160
oblue[gray]   = 160
ogreen[gray]  = 160

IF !D.NAME NE 'NULL' THEN $
	TVLCT,ored,ogreen,oblue

end
