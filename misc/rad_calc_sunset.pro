PRO	rad_calc_sunset, date, radar, beam, ngates, $
	    risetime=risetime, settime=settime, solnoon=solnoon

common radarinfo

; Define beams range-cell geographic locations
; Define beams range-cell geographic locations
ajul = calc_jul(date,1200)
caldat, ajul, mm, dd, year
tval = TimeYMDHMSToEpoch(year, mm, dd, 12, 0, 0)
radID = where(network.code[0,*] eq radar, cc)
if tval lt network[radID].st_time then begin
	tval = network[radID].st_time
	jul0 = julday(1,1,1970)
	ajul = (jul0 + tval/86400.d)
	caldat, ajul, mm, dd, year
endif
for s=0,31 do begin
	if (network[radID].site[s].tval eq -1) then break
	if (network[radID].site[s].tval ge tval) then break
endfor
radarsite = network[radID].site[s]
yrsec = (ajul-julday(1,1,year,0,0,0))*86400.d
ngates = 75
nbeams = radarsite.maxbeam
rad_define_beams, network[radID].id, nbeams, ngates, year, yrsec, coords=coords, $
		/normal, fov_loc_center=fov_loc

; initialize arrays to receive julian values
rise = dblarr(ngates)
sset = dblarr(ngates)
noon = dblarr(ngates)

; Calculate sunset/sunrise/solarnoon in each range gate
for r=0,ngates-1 do begin
    calculate_sunset, date[0], fov_loc[0,beam,r], fov_loc[1,beam,r], $
	risetime=trisetime, settime=tsettime, solnoon=tsolnoon

    parse_date, date[0], year, month, day
    parse_time, trisetime, hour, minutes
    rise[r] = julday(month,day,year,hour,minutes)
    
    parse_time, tsettime, hour, minutes
    shift_d = 0
    if tsettime lt 1200 then $
	shift_d = 1
    sset[r] = julday(month,day+shift_d,year,hour,minutes)
    
    parse_time, tsolnoon, hour, minutes
    noon[r] = julday(month,day,year,hour,minutes)
;     print, trisetime, tsolnoon, tsettime, fov_loc[0,beam,r], fov_loc[1,beam,r]
endfor

; Return arrays
risetime = rise
settime = sset
solnoon = noon

END