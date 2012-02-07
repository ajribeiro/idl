;+
; NAME: 
; RAD_DATA_INVENTORY
;
; PURPOSE: 
; This procedure produces plots of the data available on sd-data.
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE:
; RAD_DATA_INVENTORY
;
; KEYWORD PARAMETERS:
; DATE: A scalar or 2-element vector giving the time range to plot, 
; in YYYYMMDD or MMMYYYY format.
;
; OFILE: The name of th eoutput file. Default is 'inv.ps'.
;
; RADARS: An array of string giving the 3-letter codes
; for the radars to consider.
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
; Written by Lasse Clausen, Dec, 11 2009
;-
pro rad_data_inventory, date=date, ofile=ofile, radars=radars, savefile=savefile

common radarinfo

if ~keyword_set(ofile) then $
	ofile = '/home/davit/scripts/inv.ps'

if n_elements(date) eq 1 then $
	date = replicate(date, 2)

; load colors
rad_load_colortable
colsss = [ $
	; black
	[20, 20, 20], $
	; yellow
	[255, 255, 0], $
	; dark green
	[0,80,0], $
	; blue
	[0, 0, 255], $
	; red
	[255, 0, 0], $
	; green
	[0, 255, 0], $
	; light gray
	[120, 120, 120], $
	; magenta
	[255, 0, 255], $
	; cyan
	[0, 255, 255], $
	; maroon
	[102, 0, 0], $
	; orange
	[255, 102, 0] $
]
tvlct, rr, gg, bb, /get
for i=0, n_elements(colsss)/3-1 do begin
	rr[i+1] = colsss[0,i]
	gg[i+1] = colsss[1,i]
	bb[i+1] = colsss[2,i]
endfor
tvlct, rr, gg, bb

root_dir = '/sd-data/'

formats = ['dat','fit','iqdat','rawacf','fitacf','fitex','grd','vtgrd','grdex','map','mapex']
nformats = n_elements(formats)

; the last not_rad formats are only valid for
; hemispheres, not radars
not_rad = 5.

fileint = [2, 2, 2, 2, 2, 2, 24, 24, 24, 24, 24]
regex = [ $
	'[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]', $  ; dat
	'[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]', $  ; fit
	'[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].[0-9][0-9]', $ ; iqdat
	'[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].[0-9][0-9]', $ ; rawacf
	'[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].[0-9][0-9]', $ ; fitacf
	'[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].[0-9][0-9]', $ ; fitex
	'[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]', $            ; aplgrd
	'[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]', $            ; vtgrd
	'[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]', $            ; grdex
	'[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]', $            ; aplmap
	'[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' $             ; mapex
	]
idx = [ $
	[0,8,8,2], $
	[0,8,8,2], $
	[0,8,9,2], $
	[0,8,9,2], $
	[0,8,9,2], $
	[0,8,9,2], $
	[0,8,0,0], $
	[0,8,0,0], $
	[0,8,0,0], $
	[0,8,0,0], $
	[0,8,0,0] $
	]

if n_elements(radars) lt 1 then begin
	tmp = where(network[*].status eq 1)
	radars = network[tmp].code[0]
	radars = [radars, 'north', 'south']
	oradars = network[tmp].code[1]
	oradars = [oradars, 'buggaboo', 'buggaboo']
endif else begin
	radars = [radars, 'north', 'south']
	oradars = [radars, 'buggaboo', 'buggaboo']
endelse
nradars = n_elements(radars)

if ~keyword_set(date) then begin
	ydirs = file_search(root_dir+'*')
	yn = strmatch(ydirs, root_dir+'[0-9][0-9][0-9][0-9]')
	if total(yn) eq 0 then begin
		prinfo, 'No data found for any year.'
		return
	endif
	years = strmid(ydirs[where(yn)],strlen(root_dir),4)
endif else begin
	sfjul, date, [0,2400], sjul, fjul, no_days=nd, no_months=nm, no_years=ny, /date_to
	parse_date, date[0], yy, mm, dd
	if ny gt 0 then $
		years = string([yy, yy+1],format='(I4)') $
	else $
		years = string([yy],format='(I4)')
endelse
nyears = n_elements(years)

filesize = dblarr(nformats, nyears)
filesize[*] = 0.d

pos = [.075,.05,.95,.85]

set_format, /portrait, /sardines
ps_open, ofile

for y=0, nyears-1 do begin

	prinfo, 'Doing '+years[y]

	if leap_year(fix(years[y])) then $
		days = [0,31,29,31,30,31,30,31,31,30,31,30,31] $
	else $
		days = [0,31,28,31,30,31,30,31,31,30,31,30,31]

	if keyword_set(date) then begin
		ndays = nd
		d_offset = day_no(date[0])
	endif else begin
		ndays = total(days)
		d_offset = 1.
	endelse

	if keyword_set(date) and y eq 0 then $
		xyouts, 0.5, .99, format_date(date, /human), align=.5, charthick=4, $
			charsize=2, /norm $
	else if ~keyword_set(date) then $
		xyouts, 0.5, .99, years[y], align=.5, charthick=4, $
			charsize=2, /norm

	pxrange = [0,ndays]
	pyrange = [0,(nradars-2)*(nformats-not_rad)+2*not_rad]

	; empty plotting area
	plot, [0,0], /nodata, xstyle=5, xrange=pxrange, $
		pos=pos, ystyle=5, yrange=pyrange

	; make gray backgrounds for every second month
	gind = get_gray()
	tvlct, 240, 240, 200, gind
	if keyword_set(date) and y eq 0 then begin
		for m=0, ndays/2-1 do begin
			x0 = 2*m+1
			x1 = 2*(m+1)
			polyfill, [x0,x1,x1,x0,x0], [pyrange[0],pyrange[0],pyrange[1],pyrange[1],pyrange[0]], color=get_gray(), /data, noclip=1
		endfor
	endif else begin
		for m=0, 5 do begin
			x0 = total(days[0:2*m+1])
			x1 = total(days[0:2*(m+1)])
			polyfill, [x0,x1,x1,x0,x0], [pyrange[0],pyrange[0],pyrange[1],pyrange[1],pyrange[0]], color=get_gray(), /data, noclip=1
		endfor
	endelse

	for f=0, nformats-1 do begin

		;continue

		; check for symbolic links
		if file_test(root_dir+years[y]+'/'+formats[f], /symlink) then $
			continue

		for r=0, nradars-1 do begin

			adir = root_dir+years[y]+'/'+formats[f]+'/'+radars[r]
			if ~file_test(adir) or (file_test(adir, /dir) and file_test(adir, /symlink)) then $
				adir = root_dir+years[y]+'/'+formats[f]+'/'+oradars[r]

			if ~file_test(adir) then $
				continue

			if file_test(adir, /dir) and file_test(adir, /symlink) then $
				continue

			files = file_search(adir + $
				'/'+regex[f]+'*', count=fc)
			for i=0L, fc-1L do begin
				fst = file_info(files[i])
				if fst.symlink then $
					continue
				
				filesize[f, y] += fst.size
				tbfile = file_basename(files[i])
				adate = strmid(tbfile, idx[0,f], idx[1,f])
				if keyword_set(date) then begin
					if adate lt date[0] or adate gt date[1] then $
						continue
				endif
				if idx[3,f] eq 0 then $
					shr = 0. $
				else $
					shr  = strmid(tbfile, idx[2,f], idx[3,f])
				sdoy = day_no(adate) + shr/24. - d_offset + keyword_set(date)*(fix(years[y])-fix(years[0]))*(365. + leap_year(fix(years[y])))
				fdoy = day_no(adate) + (shr+fileint[f])/24. - d_offset + keyword_set(date)*(fix(years[y])-fix(years[0]))*(365. + leap_year(fix(years[y])))
				;if f eq 3 and radars[r] eq 'kap' then begin
				;	print, files[i]
				;	print, day_no(adate), shr, d_offset, keyword_set(date), (fix(years[y])-fix(years[0]))
				;	print, leap_year(fix(years[y])), keyword_set(date)*(fix(years[y])-fix(years[0]))*(365. + leap_year(fix(years[y])))
				;	print, sdoy, fdoy
				;	print, nd, ndays, pxrange, !x.crange
				;endif
				yoff = ( r le (nradars-2-1) ? r*(nformats-not_rad) : (nradars-2)*(nformats-not_rad) + ( r-(nradars-2) )*not_rad )
				ypos = yoff + ( r le (nradars-2-1) ? [f,f,f+1,f+1,f] : ([f,f,f+1,f+1,f]-not_rad-1) )
				;print, files[i], r, f, formats[f], sdoy, fdoy, yoff, ypos[0], ypos[2]
				polyfill, [sdoy, fdoy, fdoy, sdoy, sdoy], ypos, $
					color=f+1, noclip=0
			endfor
;			print, adir, ' -> ', regex[f]
			;break
		endfor
		
	endfor

	for r=1, nradars-1 do begin
		if r gt (nradars-2) then begin
			; print, 'n/s', r, (nradars-2)*(nformats-not_rad) + ( r-(nradars-2) )*not_rad
			oplot, !x.crange, replicate((nradars-2)*(nformats-not_rad) + ( r-(nradars-2) )*not_rad, 2), thick=3+6.*( r eq nradars-2 )
		endif else begin
			; print, 'rad', r, r*(nformats-not_rad)
			oplot, !x.crange, [r*(nformats-not_rad),r*(nformats-not_rad)], thick=3+6.*( r eq nradars-2 )
		endelse
	endfor

	if keyword_set(date) and y eq 0 then begin
		if nd gt 10 then begin
			nti = nd/2
			fac = 2.d
		endif else begin
			nti = nd
			fac = 1.d
		endelse
		tjuls = sjul + fac*dindgen(nti+1)
		xtickname = replicate(' ', nd+1)
		oldm = ''
		for d=0, nti do begin
			if strmid(format_juldate(tjuls[d], /date), 3, 3) ne oldm then $
				xtickname[fac*d] = strmid(format_juldate(tjuls[d], /date), 0, 6) $
			else $
				xtickname[fac*d] = strmid(format_juldate(tjuls[d], /date), 0, 2)
			oldm = strmid(format_juldate(tjuls[d], /date), 3, 3)
		endfor
		xticks = nd
		xtickv = findgen(nd+1)
	endif else begin
		xtickname = strupcase('      '+['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec',' '])
		xticks = 12
		xtickv = total(days, /cumul)
	endelse

	; plot axis of main plotting area
	if ~keyword_set(date) or ( keyword_set(date) and y eq 0 ) then begin
		plot, [0,0], /nodata, xstyle=9, xrange=pxrange, $
			pos=pos, ystyle=9, yrange=pyrange, $
			xtickv=xtickv, xticks=xticks, $
			xtickname=xtickname, $
			ytickv=(findgen(nradars)+.5)*(nformats-not_rad), $
			yticks=nradars-1, ytickname=radars, yticklen=0.0000001, $
			xticklen=-.01, charthick=3, xthick=3, ythick=3
		axis, /yaxis, /ystyle, yrange=pyrange, $
			ytickv=(findgen(nradars)+.5)*(nformats-not_rad), $
			yticks=nradars-1, ytickname=radars, yticklen=0.0000001, $
			ythick=3, charthick=3
		axis, /xaxis, xrange=pxrange, $
			xtickv=xtickv, xticks=xticks, $
			xtickname=xtickname, $
			xticklen=-.01, charthick=3, xthick=3

		; plot legend
		plot, [0,0], /nodata, xstyle=5, yrange=[0,1], $
			ystyle=5, xrange=[0,nformats], $
			pos=[pos[0]+0.02, pos[3]+.09, pos[2]-0.02, pos[3]+.1]
		for f=0, nformats-1 do begin
			polyfill, [f,f,f+1,f+1,f], [0,1,1,0,0], color=f+1
		endfor
		plot, [0,0], /nodata, xstyle=5, yrange=[0,1], $
			/ystyle, xrange=[0,nformats], $
			pos=[pos[0]+0.02, pos[3]+.09, pos[2]-0.02, pos[3]+.1], $
			ytickname=replicate(' ', 20), yticks=1, xtickname=replicate(' ', 20), xthick=3, ythick=3
		axis, /xaxis, /xstyle, xrange=[0,nformats], xticks=nformats-1, $
			xtickname=formats, charsize=.9, charthick=3, xtickv=(findgen(nformats)+.5), $
			xticklen=-.5, xthick=3
		; total size up to and including current year
		tsize = total(filesize[*,0:y])/1024.d^3
		; total size this year
		tasize = total(filesize[*,y])/1024.d^3
		; size per format this year
		fasize = filesize[*,y]/1024.d^3
		; relative size per format this year
		frasize = fasize/tasize*100.
		; total disk size
		tdsize = 14.d*1e12/1024.d^3
		; relatice usage of current year
		; cumulative relative usage
		frsize = fasize/tasize*100.
		sizelabels = strtrim(string(fasize,format='(I4)'),2)+'GB!C('+strtrim(string(frasize,format='(F4.1)'),2)+'%)'
		axis, xaxis=0, /xstyle, xrange=[0,nformats], xticks=nformats-1, $
			xtickname=sizelabels, charsize=.6, charthick=3, xtickv=(findgen(nformats)+.5), $
			xticklen=-.01, xthick=3
		xyouts, pos[0]-.05, pos[3]+0.095, strtrim(string(tasize,format='(I4)'),2)+'GB!C('+$
			strtrim(string(tasize/tdsize*100.d,format='(F4.1)'),2)+'%)', $
			align=.5, charsize=.7, charthick=3, /norm
		xyouts, pos[2]+.045, pos[3]+0.095, strtrim(string(tsize,format='(I5)'),2)+'GB!C('+ $
			strtrim(string(tsize/tdsize*100.d,format='(F4.1)'),2)+'%)', $
			align=.5, charsize=.7, charthick=3, /norm
	endif

	if ~keyword_set(date) then $
		clear_page

endfor

if keyword_set(savefile) then begin
	cdate = systime(/utc)
	save, filesize, years, formats, colsss, cdate, file='/home/davit/fsize.dat'
endif

; load old colortable
rad_load_colortable

ps_close, /no_file

end
