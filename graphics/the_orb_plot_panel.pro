;+ 
; NAME: 
; THE_ORB_PLOT_PANEL
;
; PURPOSE: 
; The procedure plots a panel of Themis orbit data.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:  
; THE_ORB_PLOT_PANEL
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
; DATE: A scalar or 2-element vector giving the time range to plot, 
; in YYYYMMDD or MMMYYYY format.
;
; TIME: A 2-element vector giving the time range to plot, in HHII format.
;
; LONG: Set this keyword to indicate that the TIME value is in HHIISS
; format rather than HHII format.
;
; PROBE: Set this to the character of the spacecraft you would like to plot data from. Can be an array.
;
; BAR: Set this keyword to allow for space right of the panel for a colorbar.
;
; YRANGE: Set this keyword to change the range of the y axis.
;
; SILENT: Set this keyword to surpress all messages/warnings.
;
; CHARTHICK: Set this keyword to change the font thickness.
;
; CHARSIZE: Set this keyword to change the font size. 
;
; PSYM: Set this keyword to change the symbol used for plotting.
;
; XSTYLE: Set this keyword to change the style of the x axis.
;
; YSTYLE: Set this keyword to change the style of the y axis.
;
; XTITLE: Set this keyword to change the title of the x axis.
;
; YTITLE: Set this keyword to change the title of the y axis.
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
; POSITION: Set this keyword to a 4-element vector of normalized coordinates 
; if you want to override the internal
; positioning calculations.
;
; FIRST: Set this keyword to indicate that this panel is the first panel in
; a ROW of plots. That will force Y axis labels.
;
; LAST: Set this keyword to indicate that this is the last panel in a column,
; hence XTITLE and XTICKNAMES will be set.
;
; WITH_INFO: Set this keyword to leave some extra space on the top for plotting noise
; and frequency info panels.
;
; INFO: Set this keyword to plot the panel above a panel which position has been
; defined using DEFINE_PANEL(XMAPS, YMAP, XMAP, YMAP, /WITH_INFO).
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
; Written by: Lasse Clausen, 2009.
;-
pro the_orb_plot_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	probe=probe, xrange=xrange, yrange=yrange, bar=bar, $
	xy=xy, xz=xz, yz=yz, coords=coords, no_legend=no_legend, $
	silent=silent, mark_interval=mark_interval, $
	mark_charsize=mark_charsize, mark_charthick=mark_charthick, $
	charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	xtickformat=xtickformat, ytickformat=ytickformat, $
	xtickname=xtickname, ytickname=ytickname, $
	position=position, all=all, $
	last=last, first=first, with_info=with_info, info=info, no_title=no_title

common the_data_blk

if keyword_set(all) then $
	probe = ['a','b','c','d','e']

if ~keyword_set(probe) then begin
	if ~keyword_set(silent) then $
		prinfo, 'probe not set, using A.'
	probe = 'a'
endif

_probe = strlowcase(probe)
inds = where(_probe ne 'a' and _probe ne 'b' and _probe ne 'c' and _probe ne 'd' and _probe ne 'e', cc)
if cc gt 0l then begin
	prinfo, 'probe must be a, b, c, d or e'
	print, _probe[inds]
	return
endif

if ~keyword_set(coords) then $
	coords = get_coordinates()
_coords = strupcase(coords)

num_probe = byte(_probe) - (byte('a'))[0]
tnum_probe = num_probe
nprobe = n_elements(num_probe)
if _coords ne 'GSE' and _coords ne 'GSM' then begin
	prinfo, 'Coordinate system must be GSE or GSM, using GSE.'
	_coords = strupcase(the_pos_info[tnum_probe[0]].coords)
endif

for p=0, n_elements(tnum_probe)-1 do begin
	if the_pos_info[tnum_probe[p]].nrecs eq 0L then begin
		prinfo, 'No data loaded for probe '+_probe[p]
		if nprobe eq 1 then $
			return
		num_probe = num_probe[where(num_probe ne tnum_probe[p], nprobe)]
	endif else if strupcase(the_pos_info[tnum_probe[p]].coords) ne _coords then begin
		prinfo, 'Data in wrong coordinate system for probe '+_probe[p]
		if nprobe eq 1 then $
			return
		num_probe = num_probe[where(num_probe ne tnum_probe[p], nprobe)]
	endif
endfor

if n_params() lt 4 then begin
	if ~keyword_set(silent) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif

if ~keyword_set(xy) and ~keyword_set(xz) and ~keyword_set(yz) then begin
	if ~keyword_set(silent) then $
		prinfo, 'XY, XZ and YZ not set, using XZ.'
	xz = 1
endif

if ~keyword_set(date) then begin
	caldat, (*the_pos_data[num_probe[0]]).juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then $
	time = [0000,2400]

sfjul, date, time, sjul, fjul, long=long
jrange = [sjul, fjul]

if ~keyword_set(mark_interval) then $
	mark_interval = -1.

if ~keyword_set(xrange) then begin
	if keyword_set(xy) then $
		xrange = [31,-31] $
	else if keyword_set(xz) then $
		xrange = [31,-31] $
	else if keyword_set(yz) then $
		xrange = [-31,31]
endif

if ~keyword_set(yrange) then begin
	if keyword_set(xy) then $
		yrange = [31,-31] $
	else if keyword_set(xz) then $
		yrange = [-31,31] $
	else if keyword_set(yz) then $
		yrange = [-31,31]
endif

if ~keyword_set(xtitle) then begin
	if keyword_set(xy) then $
		_xtitle = 'X '+_coords $
	else if keyword_set(xz) then $
		_xtitle = 'X '+_coords $
	else if keyword_set(yz) then $
		_xtitle = 'Y '+_coords
endif else $
	_xtitle = xtitle

if ~keyword_set(ytitle) then begin
	if keyword_set(xy) then $
		_ytitle = 'Y '+_coords $
	else if keyword_set(xz) then $
		_ytitle = 'Z '+_coords $
	else if keyword_set(yz) then $
		_ytitle = 'Z '+_coords
endif else $
	_ytitle = ytitle

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if ~keyword_set(linethick) then $
	linethick = 1.

if ~keyword_set(linecolor) then begin
	linecolor = strarr(nprobe)
	for p=0, nprobe-1 do begin
		if probe[p] eq 'a' then $
			linecolor[p] = 'm' $
		else if probe[p] eq 'b' then $
			linecolor[p] = 'r' $
		else if probe[p] eq 'c' then $
			linecolor[p] = 'g' $
		else if probe[p] eq 'd' then $
			linecolor[p] = 'c' $
		else if probe[p] eq 'e' then $
			linecolor[p] = 'b'
	endfor
endif

orb_plot_panel, xmaps, ymaps, xmap, ymap, $
	xrange=xrange, yrange=yrange, bar=bar, $
	xy=xy, xz=xz, yz=yz, coords=coords, $
	silent=silent, $
	charthick=charthick, charsize=charsize, $ 
	xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	xtickformat=xtickformat, ytickformat=ytickformat, $
	xtickname=xtickname, ytickname=ytickname, $
	position=position, $
	last=last, first=first, with_info=with_info, info=info, $
	/no_earth, no_title=no_title

for p=0, nprobe-1 do begin
	; get data
	if keyword_set(xy) then begin
		xtag = 'rx'
		ytag = 'ry'
		ztag = 'rz'
	endif else if keyword_set(xz) then begin
		xtag = 'rx'
		ytag = 'rz'
		ztag = 'ry'
	endif else if keyword_set(yz) then begin
		xtag = 'ry'
		ytag = 'rz'
		ztag = 'rx'
	endif
	
	if ~tag_exists((*the_pos_data[num_probe[p]]), xtag) then begin
		prinfo, 'Parameter '+xtag+' does not exist in THE_POS_DATA.'
		return
	endif
	if ~tag_exists((*the_pos_data[num_probe[p]]), ytag) then begin
		prinfo, 'Parameter '+ytag+' does not exist in THE_POS_DATA.'
		return
	endif
	if ~tag_exists((*the_pos_data[num_probe[p]]), ztag) then begin
		prinfo, 'Parameter '+ztag+' does not exist in THE_POS_DATA.'
		return
	endif
	dd = execute('xdata = (*the_pos_data[num_probe[p]]).'+xtag)
	dd = execute('ydata = (*the_pos_data[num_probe[p]]).'+ytag)
	dd = execute('zdata = (*the_pos_data[num_probe[p]]).'+ztag)
	juls = (*the_pos_data[num_probe[p]]).juls
	jinds = where(juls ge sjul and juls le fjul, cc)
	if cc lt 1L then begin
		prinfo, 'No data found for time interval.'
		continue
	endif
	xdata = xdata[jinds]
	ydata = ydata[jinds]
	zdata = zdata[jinds]
	juls = juls[jinds]
	dt = mean(deriv((juls-juls[0])*1440.d))

	; overplot data
	; but do it in the right order so that the track is hidden behind Earth
	rad_load_colortable, /themis
	cond = zdata ge 0.
	fbinds = uniq(cond)
	if max(fbinds) ne cc-1L then $
		fbinds = [fbinds, cc-1L]
	binds = where(cond[fbinds] eq !false, nb, complement=finds, ncomplement=nf)
	fbinds = [0L, fbinds]
	if nb gt 0 then begin
		for i=0, nb-1 do begin
			npinds = fbinds[binds[i]+1] - fbinds[binds[i]] + 1L
			pinds = lindgen(npinds) + fbinds[binds[i]]
			oplot, xdata[pinds], ydata[pinds], $
				thick=linethick, color=get_colors(linecolor[p]), linestyle=linestyle, psym=psym
		endfor
	endif
	earth_plot, xy=xy, xz=xz, yz=yz
	if nf gt 0 then begin
		for i=0, nf-1 do begin
			npinds = fbinds[finds[i]+1] - fbinds[finds[i]] + 1L
			pinds = lindgen(npinds) + fbinds[finds[i]]
			oplot, xdata[pinds], ydata[pinds], $
				thick=linethick, color=get_colors(linecolor[p]), linestyle=linestyle, psym=psym
		endfor
	endif
	if mark_interval ne -1 then begin
		; mark the orbit with time stamps
		load_usersym, /circle
		mark_every = round(mark_interval*60./dt)
		n_dots = cc/mark_every+1L
		ind_dots = (lindgen(n_dots)*mark_every) < (cc-1L)
		mark_every = floor(230./n_dots)
		angs = atan(ydata[ind_dots], xdata[ind_dots])*!radeg + 180.
		for k=0, n_dots-1 do begin
			if zdata[ind_dots[k]] ge 0. or abs(xdata[ind_dots[k]]) gt 1. then $
				plots, xdata[ind_dots[k]], ydata[ind_dots[k]], $
					color=get_foreground(), $
					psym=8, noclip=0, symsize=symsize
			xyouts, xdata[ind_dots[k]], ydata[ind_dots[k]], format_juldate(juls[ind_dots[k]], /short_time), /data, $
				orient=angs[k], charthick=mark_charthick, charsize=mark_charsize, color=get_colors(linecolor[p]), noclip=0
		endfor
	endif else begin
		; just mark the beginning of the orbit
		load_usersym, /circle
		plots, xdata[0], ydata[0], $
			color=get_colors(linecolor[p]), $
			psym=8, noclip=0, symsize=.4
	endelse
	rad_load_colortable
endfor

if ~keyword_set(no_legend) then begin
	rad_load_colortable, /themis
	line_legend, [position[2]+0.04, position[1]], 'THM '+string(num_probe+(byte('A'))[0]), $
		charsize=.5, thick=2, color=get_colors(linecolor)
	rad_load_colortable
endif


end
