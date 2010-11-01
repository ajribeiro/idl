pro rad_data_inventory, date=date, ofile=ofile

common radarinfo

if ~keyword_set(ofile) then $
	ofile = '/home/davit/scripts/inv.ps'

; load colors
rad_load_colortable
colsss = [ $
	; black
	[20, 20, 20], $
	; yellow
	[255, 255, 0], $
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
	;
	[102, 0, 0], $
	;
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

formats = ['dat','fit','rawacf','fitacf','fitex','grd','vtgrd','grdex','map','mapex']
nformats = n_elements(formats)

; the last not_rad formats are only valid for
; hemispheres, not radars
not_rad = 5.

fileint = [2, 2, 2, 2, 2, 24, 24, 24, 24, 24]
regex = [ $
	'[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]', $  ; dat
	'[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]', $  ; fit
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
	[0,8,0,0], $
	[0,8,0,0], $
	[0,8,0,0], $
	[0,8,0,0], $
	[0,8,0,0] $
	]

radars = network[*].code[0]
nradars = n_elements(radars)
radars = [radars[1:nradars-1], 'north', 'south']
oradars = network[*].code[1]
oradars = [oradars[1:n_elements(oradars)-1], 'buggaboo', 'buggaboo']
nradars = n_elements(radars)

; tmp = where(network[*].code[0] ne 'sch' and network[*].code[0] ne 'tst' and network[*].code[0] ne 'zho')
tmp = where(network[*].status eq 1)
radars = network[tmp].code[0]
radars = [radars, 'north', 'south']
oradars = network[tmp].code[1]
oradars = [oradars, 'buggaboo', 'buggaboo']
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
	sfjul, date, [0,2400], sjul, fjul, no_days=nd, /jul_to
	parse_date, date[0], yy, mm, dd
	years = [yy]
endelse
nyears = n_elements(years)

pos = [.075,.05,.95,.85]

set_format, /portrait, /sardines
ps_open, ofile

for y=0, nyears-1 do begin
;for y=14, 14 do begin

	if leap_year(fix(years[y])) then $
		days = [0,31,29,31,30,31,30,31,31,30,31,30,31] $
	else $
		days = [0,31,28,31,30,31,30,31,31,30,31,30,31]

	xyouts, 0.5, .97, years[y], align=.5, charthick=4, $
		charsize=2, /norm

	; plot legend
	plot, [0,0], /nodata, xstyle=5, yrange=[0,1], $
		ystyle=5, xrange=[0,nformats], $
		pos=[pos[0]+0.05, pos[3]+.06, pos[2]-0.05, pos[3]+.07]
	for f=0, nformats-1 do begin
		polyfill, [f,f,f+1,f+1,f], [0,1,1,0,0], color=f+1
	endfor
	plot, [0,0], /nodata, xstyle=9, yrange=[0,1], $
		/ystyle, xrange=[0,nformats], $
		pos=[pos[0]+0.05, pos[3]+.06, pos[2]-0.05, pos[3]+.07], $
		ytickname=replicate(' ', 20), yticks=1, xtickname=replicate(' ', 20), xthick=3, ythick=3
	axis, /xaxis, /xstyle, xrange=[0,nformats], xticks=nformats-1, $
		xtickname=formats, charsize=.9, charthick=2, xtickv=(findgen(nformats)+.5), $
		xticklen=-1, xthick=3

	; empty plotting area
	plot, [0,0], /nodata, xstyle=5, xrange=[0,total(days)], $
		pos=pos, ystyle=5, yrange=[0,(nradars)*(nformats-not_rad)]

	; make gray backgrounds for every second month
	gind = get_gray()
	tvlct, 230, 230, 200, gind
	for m=0, 5 do begin
		x0 = total(days[0:2*m+1])
		x1 = total(days[0:2*(m+1)])
		polyfill, [x0,x1,x1,x0,x0], [0,0,(nradars)*(nformats-not_rad),(nradars)*(nformats-not_rad),0], color=get_gray(), /data
	endfor

	for f=0, nformats-1 do begin

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
				if file_test(files[i], /symlink) then $
					continue
				tbfile = file_basename(files[i])
				date = strmid(tbfile, idx[0,f], idx[1,f])
				if idx[3,f] eq 0 then $
					shr = 0. $
				else $
					shr  = strmid(tbfile, idx[2,f], idx[3,f])
				sdoy = day_no(date)-1. + shr/24.
				fdoy = day_no(date)-1. + (shr+fileint[f])/24.
				polyfill, [sdoy, fdoy, fdoy, sdoy, sdoy], $
					(r*(nformats-not_rad)) + $
						(r gt (nradars-2-1) ? $
;							((nformats-not_rad)/not_rad*([f,f,f+1,f+1,f] mod (nformats-not_rad))) : $
							((nformats-not_rad)/not_rad*([f,f,f+1,f+1,f]-not_rad)) : $
							[f,f,f+1,f+1,f]), $
					color=f+1, noclip=0
			endfor
;			print, adir, ' -> ', regex[f]

		endfor

	endfor

	for r=0, nradars-1 do begin
		oplot, !x.crange, [r*(nformats-not_rad),r*(nformats-not_rad)], thick=3+6.*( r eq nradars-2 )
	endfor

	; plot axis of main plotting area
	plot, [0,0], /nodata, xstyle=9, xrange=[0,total(days)], $
		pos=pos, ystyle=9, yrange=[0,(nradars)*(nformats-not_rad)], $
		xtickv=total(days, /cumul), xticks=12, $
		xtickname=strupcase('      '+['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec',' ']), $
		ytickv=(findgen(nradars)+.5)*(nformats-not_rad), $
		yticks=nradars-1, ytickname=radars, yticklen=0.0000001, $
		xticklen=-.01, charthick=3, xthick=3, ythick=3
	axis, /yaxis, /ystyle, yrange=[0,(nradars)*(nformats-not_rad)], $
		ytickv=(findgen(nradars)+.5)*(nformats-not_rad), $
		yticks=nradars-1, ytickname=radars, yticklen=0.0000001, $
		ythick=3, charthick=3
	axis, /xaxis, xrange=[0,total(days)], $
		xtickv=total(days, /cumul), xticks=12, $
		xtickname=strupcase('      '+['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec',' ']), $
		xticklen=-.01, charthick=3, xthick=3

	clear_page

endfor

ps_close, /no

; load old colortable
; rad_load_colortable

end
