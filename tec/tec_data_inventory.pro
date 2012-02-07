;+
; NAME: 
; TEC_DATA_INVENTORY
;
; PURPOSE: 
; This procedure produces plots of the TEC data available on sd-data.
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE:
; TEC_DATA_INVENTORY
;
; KEYWORD PARAMETERS:
; OFILE: The name of the output file. Default is 'tec_inv.ps'.
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
; Modified by Evan Thomas, Jul, 21, 2011
;-
pro tec_data_inventory, ofile=ofile

if ~keyword_set(ofile) then $
	ofile = '/home/davit/scripts/tec_inv.ps'

root_dir = '/sd-data/tec/'

fileint = 24

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

pos = [.075,.05,.95,.85]

set_format, /portrait, /sardines
ps_open, ofile


days = [0,31,28,31,30,31,30,31,31,30,31,30,31]

if keyword_set(date) then begin
	ndays = nd
	d_offset = day_no(date[0])
endif else begin
	ndays = total(days)
	d_offset = 1.
endelse

xyouts, 0.5, .94, 'TEC Data Inventory', align=.5, charthick=4, $
	charsize=2, /norm

pxrange = [0,ndays]
pyrange = [0,39]
; pyrange = [0,(nradars-2)*(nformats-not_rad)+2*not_rad]

; empty plotting area
plot, [0,0], /nodata, xstyle=5, xrange=pxrange, $
	pos=pos, ystyle=5, yrange=pyrange

; make gray backgrounds for every second month
gind = get_gray()
tvlct, 240, 240, 200, gind
if keyword_set(date) then begin
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

for y=0, nyears-1 do begin

	prinfo, 'Doing '+years[y]

	; check for symbolic links
	if file_test(root_dir+years[y], /symlink) then $
		continue

	adir = root_dir+years[y]

	if ~file_test(adir) then $
		continue

	if file_test(adir, /dir) and file_test(adir, /symlink) then $
		continue

	files = file_search(adir + $
		'/'+years[y]+'*', count=fc)

	for i=0L, fc-1L do begin
		fst = file_info(files[i])
		if fst.symlink then $
			continue

		tbfile = file_basename(files[i])
		adate = strmid(tbfile, 0, 8)
		if keyword_set(date) then begin
			if adate lt date[0] or adate gt date[1] then $
				continue
		endif

		shr = 0.

		sdoy = day_no(adate) + shr/24. - d_offset; + keyword_set(date)*(fix(years[y])-fix(years[0]))*(365. + leap_year(fix(years[y])))
		fdoy = day_no(adate) + (shr+fileint)/24. - d_offset; + keyword_set(date)*(fix(years[y])-fix(years[0]))*(365. + leap_year(fix(years[y])))

; 		yoff = ( y le (nyears-2-1) ? y*(nformats-not_rad) : (nyears-2)*(nformats-not_rad) + ( y-(nyears-2) )*not_rad )

		yoff = 0.5*(1+y*(nyears-1.4))
		yoff = 2.3+5.6*y
		ypos = yoff + [0,0,1,1,0];[y,y,y+1,y+1,y]

; 		ypos = yoff + ( y le (nyears-2-1) ? [y,y,y+1,y+1,y] : ([y,y,y+1,y+1,y]-not_rad-1) )

		polyfill, [sdoy, fdoy, fdoy, sdoy, sdoy], ypos, $
			color=get_black(), noclip=0
	endfor

	oplot, !x.crange, [y*(nyears-1.4),y*(nyears-1.4)], thick=3

	if y eq 0 then begin
		xtickname = strupcase('      '+['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec',' '])
		xticks = 12
		xtickv = total(days, /cumul)
	endif

	; plot axis of main plotting area
	plot, [0,0], /nodata, xstyle=9, xrange=pxrange, $
		pos=pos, ystyle=9, yrange=pyrange, $
		xtickv=xtickv, xticks=xticks, $
		xtickname=xtickname, $
		ytickv=findgen(nyears)*5.6+2.8, $
		yticks=nyears-1, ytickname=years, yticklen=0.0000001, $
		xticklen=-.01, charthick=3, xthick=3, ythick=3
	axis, /yaxis, /ystyle, yrange=pyrange, $
		ytickv=findgen(nyears)*5.6+2.8, $
		yticks=nyears-1, ytickname=replicate(' ', nyears), yticklen=0.0000001, $
		ythick=3, charthick=3
; 	axis, /yaxis, /ystyle, yrange=pyrange, $
; 		ytickv=findgen(nyears)*5.6+2.8, $
; 		yticks=nyears-1, ytickname=years, yticklen=0.0000001, $
; 		ythick=3, charthick=3
	axis, /xaxis, xrange=pxrange, $
		xtickv=xtickv, xticks=xticks, $
		xtickname=xtickname, $
		xticklen=-.01, charthick=3, xthick=3

endfor

ps_close, /no_file

end
