;+ 
; NAME: 
; OVERLAY_TEC
; 
; PURPOSE: 
; This procedure overlays GPS TEC data on a stereographic polar map.
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
; OVERLAY_TEC
;
; KEYWORD PARAMETERS:
; JUL: Set this to a julian day number to select the scan to plot as that
; nearest to this date/time. Can be used instead of a combination of DATE/TIME.
;
; DATE: A scalar or 2-element vector giving the date range, 
; in YYYYMMDD or MMMYYYY format. Can be used in combination with TIME
; instead of JUL.
;
; TIME: The time range for which to read data. Must be a 2-element vector in 
; HHII format, or HHIISS format if the LONG keyword is set. If TIME is not set
; the default value [0000,2400] is assumed. Can be used in combination with DATE
; instead of JUL.
;
; LONG: Set this keyword to indicate that the Time value is in HHIISS
; format rather than HHII format.
;
; COORDS: Set this keyword to a string naming the coordinate system
; of the y axis. Allowable inputs are 'magn', 'geog', and 'mlt'.
; Default is 'magn'.
;
; SCALE: Set this keyword to change the scale of the plotted values.
;
; STARTJUL: Set this to a named variable that will contain the
; julian day number of the plotted scan.
;
; ROTATE: Set this keyword to a number of degree to rotate the scan by.
;
; HEMISPHERE: Set this keyword to one to plot the Northern hemisphere, -1 for Southern.
; Default is 1 (Northern).
;
; FORCE_DATA: Set this keyword to a [nb, ng] array holding the scan data to plot.
; this overrides the internal scan finding procedures. nb is the number of beams,
; ng is the number of gates.
;
; SYMSIZE: Size of the symbols used to mark the data positions.
;
; STARTJUL: Set this keyword to a named variable that will contain the
; timestamp of the first beam in teh scan as a julian day.
;
; SILENT: Set this keyword to surpress warnings but not error messages.
;
; ERROR: Set this keyword to plot TEC error values instead of TEC measurements.
;
; BLANK: Set this keyword to plot a blank map without any TEC values (only used with
; tec_plot_panel.pro).
;
; COMMON BLOCKS:
; TEC_DATA_BLK: The common block holding GPS TEC data.
;
; EXAMPLE: 
; 
; COPYRIGHT:
; Non-Commercial Purpose License
; Copyright © November 14, 2006 by Virginia Polytechnic Institute and State University
; All rights reserved.
; Virginia Polytechnic Institute and State University (Virginia Tech) owns the DaViT
; software and its associated documentation (“Software”). You should carefully read the
; following terms and conditions before using this software. Your use of this Software
; indicates your acceptance of this license agreement and all terms and conditions.
; You are hereby licensed to use the Software for Non-Commercial Purpose only. Non-
; Commercial Purpose means the use of the Software solely for research. Non-
; Commercial Purpose excludes, without limitation, any use of the Software, as part of, or
; in any way in connection with a product or service which is sold, offered for sale,
; licensed, leased, loaned, or rented. Permission to use, copy, modify, and distribute this
; compilation for Non-Commercial Purpose is hereby granted without fee, subject to the
; following terms of this license.
; Copies and Modifications
; You must include the above copyright notice and this license on any copy or modification
; of this compilation. Each time you redistribute this Software, the recipient automatically
; receives a license to copy, distribute or modify the Software subject to these terms and
; conditions. You may not impose any further restrictions on this Software or any
; derivative works beyond those restrictions herein.
; You agree to use your best efforts to provide Virginia Polytechnic Institute and State
; University (Virginia Tech) with any modifications containing improvements or
; extensions and hereby grant Virginia Tech a perpetual, royalty-free license to use and
; distribute such modifications under the terms of this license. You agree to notify
; Virginia Tech of any inquiries you have for commercial use of the Software and/or its
; modifications and further agree to negotiate in good faith with Virginia Tech to license
; your modifications for commercial purposes. Notices, modifications, and questions may
; be directed by e-mail to Stephen Cammer at cammer@vbi.vt.edu.
; Commercial Use
; If you desire to use the software for profit-making or commercial purposes, you agree to
; negotiate in good faith a license with Virginia Tech prior to such profit-making or
; commercial use. Virginia Tech shall have no obligation to grant such license to you, and
; may grant exclusive or non-exclusive licenses to others. You may contact Stephen
; Cammer at email address cammer@vbi.vt.edu to discuss commercial use.
; Governing Law
; This agreement shall be governed by the laws of the Commonwealth of Virginia.
; Disclaimer of Warranty
; Because this software is licensed free of charge, there is no warranty for the program.
; Virginia Tech makes no warranty or representation that the operation of the software in
; this compilation will be error-free, and Virginia Tech is under no obligation to provide
; any services, by way of maintenance, update, or otherwise.
; THIS SOFTWARE AND THE ACCOMPANYING FILES ARE LICENSED “AS IS”
; AND WITHOUT WARRANTIES AS TO PERFORMANCE OR
; MERCHANTABILITY OR ANY OTHER WARRANTIES WHETHER EXPRESSED
; OR IMPLIED. NO WARRANTY OF FITNESS FOR A PARTICULAR PURPOSE IS
; OFFERED. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF
; THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE,
; YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR
; CORRECTION.
; Limitation of Liability
; IN NO EVENT WILL VIRGINIA TECH, OR ANY OTHER PARTY WHO MAY
; MODIFY AND/OR REDISTRIBUTE THE PRORAM AS PERMITTED ABOVE, BE
; LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL,
; INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR
; INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS
; OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED
; BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE
; WITH ANY OTHER PROGRAMS), EVEN IF VIRGINIA TECH OR OTHER PARTY
; HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
; Use of Name
; Users will not use the name of the Virginia Polytechnic Institute and State University nor
; any adaptation thereof in any publicity or advertising, without the prior written consent
; from Virginia Tech in each case.
; Export License
; Export of this software from the United States may require a specific license from the
; United States Government. It is the responsibility of any person or organization
; contemplating export to obtain such a license before exporting.
;
; MODIFICATION HISTORY: 
; Based on Steve Milan's .
; Written by Lasse Clausen, Nov, 24 2009
; Modified by Evan Thomas, June, 10 2011
;-
pro overlay_tec, coords=coords, time=time, date=date, jul=jul, $
	scale=scale, rotate=rotate, hemisphere=hemisphere, $
	force_data=force_data, startjul=startjul, $
	north=north, south=south, ascale=ascale, $
	symsize=symsize, silent=silent, error=error, blank=blank

common tec_data_blk


if ~keyword_set(symsize) then $
	symsize = .8

if ~keyword_set(coords) then $
	coords = get_coordinates()

if ~is_valid_coord_system(coords) then begin
	prinfo, 'Invalid coordinate system: '+coords
	return
endif

; check coordinate system
if coords ne 'magn' and coords ne 'geog' and coords ne 'mlt' then begin
	prinfo, 'Coordinate system not supported: '+coords
	prinfo, 'Using magnetic coordinates.'
	coords = 'magn'
endif

if tec_info.nrecs eq 0L and ~keyword_set(force_data) then begin
	if ~keyword_set(silent) then begin
		prinfo, 'No data loaded.'
	endif
	return
endif

; Check hemisphere
if ~keyword_set(hemisphere) then begin
  if keyword_set(north) then $
    hemisphere = 1. $
  else if keyword_set(south) then $
    hemisphere = -1. $
  else $
    hemisphere = 1.
endif

; Allow the user to pass their own data array
IF KEYWORD_SET(force_data) THEN begin
	varr = force_data
	grnd = byte(force_data)
	grnd[*,*] = 0b
	if keyword_set(jul) then $
		sfjul, date, time, jul, /jul_to_date
	if ~keyword_set(date) then begin
		prinfo, 'Must give date when using FORCE_DATA keyword.'
		return
	endif
	if ~keyword_set(time) then begin
		prinfo, 'Must give time when using FORCE_DATA keyword.'
		return
	endif
	sfjul, date, time, jul
endif else begin
	if ~keyword_set(date) then begin
		caldat, tec_info.sjul, mm, dd, yy
		date = yy*10000L + mm*100L + dd
	endif
	if ~keyword_set(time) then begin
		if median_info.dlat eq 0 then begin		; Added Oct 21 2011 to fix issue in tec_four_plot.pro when using time=0000
			caldat, tec_data.juls[0], month, day, year, hh, ii
			time = hh*100 + ii
		endif
	endif
	if ~keyword_set(jul) then $
		sfjul, date, time, jul

	tmp = min(abs(tec_data.juls - jul), minind)

	; Check hemisphere
	if hemisphere eq 1. then $
		index = where(tec_data.juls eq tec_data.juls[minind] and tec_data.glat ge 0, sz) $
	else $
		index = where(tec_data.juls eq tec_data.juls[minind] and tec_data.glat le 0, sz)
	last=sz-1
endelse

if keyword_set(blank) then begin
	startjul = tec_data.juls[index[0]]
	return
endif

; we need this later
if coords eq 'mlt' then begin
	in_mlt = !true
	_coords = 'magn'
endif else begin
	_coords = coords
	in_mlt = !false
endelse

; get time
caldat, jul, mm, dd, year
yrsec = (jul-julday(1,1,year,0,0,0))*86400.d

if ~keyword_set(scale) then begin
	if keyword_set(error) then begin
		avg=round(mean(tec_data.dtec[index]))
		scale = [0.0,avg+2*stddev(tec_data.dtec[index])]
	endif else begin
		avg=round(mean(tec_data.tec[index]))
		scale = [0.0,avg+2*stddev(tec_data.tec[index])]
	endelse
endif

; get color preferences
foreground  = get_foreground()
color_steps = get_colorsteps()
ncolors     = get_ncolors()
bottom      = get_bottom()


; Set color bar and levels
cin =    FIX(FINDGEN(color_steps)/(color_steps-1.)*(ncolors-1))+bottom
lvl = scale[0]+FINDGEN(color_steps)*(scale[1]-scale[0])/color_steps

; array for the positions of the corners
xx = fltarr(4)
yy = fltarr(4)


; plot TEC data
for i=index[0],index[last] do begin
 	alats = [tec_data.glat[i]+[-0.5,-0.5,0.5,0.5,-0.5]]
 	alons = [tec_data.glon[i]+[-0.5,0.5,0.5,-0.5,-0.5]]

 	if strcmp(coords, 'geog') then begin
 		lat = alats
 		lon = alons
 	endif else if strcmp(coords, 'magn') then begin
 		tmp = CNVCOORD(alats,alons,[1.,1.,1.,1.,1.])
 		lat = reform(tmp[0,*])
 		lon = reform(tmp[1,*])
 	endif else if strcmp(coords, 'mlt') then begin
 		tmp = CNVCOORD(alats,alons,[1.,1.,1.,1.,1.])
 		lat = reform(tmp[0,*])
 		lon = fltarr(n_elements(alons))
 		for j=0,n_elements(alons)-1 do $
 			lon[j] = mlt(year, yrsec, tmp[1,j])
 	endif

 	if hemisphere eq 1 then begin
		check_bound = where(lat le 0, cc)
		if cc gt 0 then continue
 	endif else begin
		check_bound = where(lat ge 0, cc)
		if cc gt 0 then continue
	endelse
	check_bound = 0
	cc = 0

 	tmp = calc_stereo_coords(lat, lon, mlt=in_mlt)
	if n_elements(tmp) eq 2 then continue
 	; Plot either vertically integrated electron density or error in vertically integrated electron density
 	if ~keyword_set(error) then $
 		color_ind = (max(where(lvl le ((tec_data.tec[i] > scale[0]) < scale[1])))) $
 	else $
 		color_ind = (max(where(lvl le ((tec_data.dtec[i] > scale[0]) < scale[1]))))
 	col = cin[color_ind]

 	polyfill, tmp[0,*], tmp[1,*], color=cin[color_ind], noclip=0

; This is for the old way of plotting TEC values using colored dots instead of polyfilled rectangles
;   	if strcmp(coords, 'geog') then begin
;   		lat = tec_data.glat[i]
;   		lon = tec_data.glon[i]
;   	endif else if strcmp(coords, 'magn') then begin
;   		mag1 = CNVCOORD(tec_data.glat[i],tec_data.glon[i],1)
;   		lat = mag1[0]
;   		lon = mag1[1]
;   	endif else if strcmp(coords, 'mlt') then begin
;   		mag1 = CNVCOORD(tec_data.glat[i],tec_data.glon[i],1)
;   		lat = mag1[0]
;    		lon = mlt(year, yrsec, mag1[1])
;   	endif
;   
;   	tmp = calc_stereo_coords(lat,lon,mlt=in_mlt)
;   	xx = tmp[0]
;   	yy = tmp[1]
;   	if n_elements(rotate) ne 0 then begin
;   		_x1 = cos(rotate*!dtor)*xx - sin(rotate*!dtor)*yy
;   		_y1 = sin(rotate*!dtor)*xx + cos(rotate*!dtor)*yy
;   		xx = _x1
;   		yy = _y1
;   	endif
;   	
;   	; Plot either vertically integrated electron density or error in vertically integrated electron density
;   	if ~keyword_set(error) then $
;   		color_ind = (max(where(lvl le ((tec_data.tec[i] > scale[0]) < scale[1])))) $
;   	else $
;   		color_ind = (max(where(lvl le ((tec_data.dtec[i] > scale[0]) < scale[1]))))
;   	col = cin[color_ind]
;   
;   	load_usersym, /circle
;   	plots, xx, yy, psym=8, symsize=.5*symsize, color=col, $
;   		noclip=0
endfor

; I removed this here and put it in tec_plot_panel
;overlay_coast, coords=coords, jul=jul, hemisphere=hemisphere, /no_fill
;map_overlay_grid, grid_linestyle=grid_linestyle, grid_linethick=grid_linethick, grid_linecolor=grid_linecolor
;map_label_grid, coords=coords, hemisphere=hemisphere

; "return" the date/time of the plotted scan and scale used
startjul = tec_data.juls[index[0]]
ascale = scale

END
