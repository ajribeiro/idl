; Reads output from fortran code and parses it into smaller
; files that can actually be processed by IDL.
;
; Created by Sebastien - Nov. 2011
;------------------------------------------------------------
pro rt_read_rays2files, radar, dir=dir, outdir=outdir

if ~keyword_set(dir) then $
	filename = 'rays.dat' $
else $
	filename = dir+'/rays.dat'

; Header info
txlat = 0.
txlon = 0.
azim_beg = 0.
azim_end = 0.
azim_stp = 0.
elev_beg = 0.
elev_end = 0.
elev_stp = 0.
freq = 0.
nhop = 0L
year = 0L
mmdd = 0L
hour_beg = 0.
hour_end = 0.
hour_stp = 0.
nhour = 0L
nazim = 0L
nelev = 0L

; Ray info
tnrstep = 0.
nrstep = 0.
trayhour = 0.
trayazim = 0.
trayelev = 0.

openr, unit, filename, /get_lun

READU, unit, $
	txlat, txlon, azim_beg, azim_end, azim_stp, $
	elev_beg, elev_end, elev_stp, freq, nhop, $
	year, mmdd, hour_beg, hour_end, hour_stp
READU, unit, nhour, nazim, nelev

; Save unit position
point_lun, -unit, headerpos

; Count lines first
nr = 0L
; script_time = systime(/julian, /utc)
while ~eof(unit) do begin
	readu, unit, tnrstep
	readu, unit, trayhour, trayazim, trayelev
	if tnrstep gt 0. then begin
		tmp = fltarr(tnrstep)
		readu, unit, tmp
		readu, unit, tmp
		readu, unit, tmp
		readu, unit, tmp
		readu, unit, tmp
	endif

	if tnrstep gt nrstep then nrstep = tnrstep
	nr = nr + 1
endwhile
; print, 'Time in loop (s): ',(systime(/julian, /utc) - script_time)*86400.d
; Rewind file
point_lun, unit, headerpos

; Find time format (ut or lt)
if hour_beg ge 25. then $
	hrbase = 25. $
else $
	hrbase = 0.

IF nrstep gt 1 then begin
	rsave = fltarr(nhour, nazim, nelev, nrstep)
	thsave = fltarr(nhour, nazim, nelev, nrstep)
	grpsave = fltarr(nhour, nazim, nelev, nrstep)
	ransave = fltarr(nhour, nazim, nelev, nrstep)
	nrsave = fltarr(nhour, nazim, nelev, nrstep)
	nrstepsave = lonarr(nhour, nazim, nelev)
	rayhour = fltarr(nhour)
	rayazim = fltarr(nazim)
	rayelev = fltarr(nelev)

	; read main file and write to individual files
; 	script_time = systime(/julian, /utc)
	while ~eof(unit) do begin
		readu, unit, tnrstep
		readu, unit, trayhour, trayazim, trayelev

		; find hour, beam and elevation index
		nh = round((trayhour - hour_beg)/hour_stp)
		if (trayhour lt hour_beg) then $
			nh = ((24. - hour_beg)/hour_stp + trayhour/hour_stp)
		na = round((trayazim - azim_beg)/azim_stp)
		nel = round((trayelev - elev_beg)/elev_stp)


		rayhour[nh] = trayhour
		rayazim[na] = trayazim
		rayelev[nel] = trayelev
		nrstepsave[nh,na,nel] = tnrstep

		tmp = fltarr(tnrstep)
		READU, unit, tmp
		rsave[nh,na,nel,0:tnrstep-1] = tmp
		READU, unit, tmp
		thsave[nh,na,nel,0:tnrstep-1] = tmp
		READU, unit, tmp
		grpsave[nh,na,nel,0:tnrstep-1] = tmp
		READU, unit, tmp
		ransave[nh,na,nel,0:tnrstep-1] = tmp
		READU, unit, tmp
		nrsave[nh,na,nel,0:tnrstep-1] = tmp

	endwhile
; 	print, 'Time in loop (s): ',(systime(/julian, /utc) - script_time)*86400.d
	free_lun, unit
endif

; script_time = systime(/julian, /utc)
for nh=0,nhour-1 do begin
	; open individual file for this time step
	hour = hour_beg - hrbase + nh * hour_stp
	time = floor(hour)*100L + round(hour*60. mod 60.)
	filename = rtFileName(year*10000L+mmdd, time, radar, /rays, outdir=outdir)
	openw, tmpout, filename, /get_lun
	writeu, tmpout, nazim, nelev
	writeu, tmpout, reform(nrstepsave[nh,*,*])

; 	timeup = systime(/julian, /utc)
	for na=0,nazim-1 do begin
		for nel=0,nelev-1 do begin
			writeu, tmpout, rayhour[nh], rayazim[na], rayelev[nel], freq
			writeu, tmpout, na, nel

			if nrstepsave[nh,na,nel] gt 0 then begin
				writeu, tmpout, reform(rsave[nh,na,nel,0:nrstepsave[nh,na,nel]-1]), $
								reform(thsave[nh,na,nel,0:nrstepsave[nh,na,nel]-1]), $
								reform(grpsave[nh,na,nel,0:nrstepsave[nh,na,nel]-1]), $
								reform(ransave[nh,na,nel,0:nrstepsave[nh,na,nel]-1]), $
								reform(nrsave[nh,na,nel,0:nrstepsave[nh,na,nel]-1])
			endif
		endfor
	endfor
; 	print, 'Time ',nh,' (s): ',(systime(/julian, /utc) - timeup)*86400.d, TOTAL(nrstepsave[nh,*,*])

	free_lun, tmpout
endfor
; print, 'Time in loop (s): ',(systime(/julian, /utc) - script_time)*86400.d


end
