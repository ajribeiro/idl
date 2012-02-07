function amp_extract_along_track, juls, lats, lons, coords=coords, $
	hemisphere=hemisphere, north=north, south=south, index=index, $
	dbeast=dbeast, dbnorth=dbnorth, current=current, poynting=poynting, p1=p1, p2=p2, $
	silent=silent

common amp_data_blk

; check hemisphere and north and south
if ~keyword_set(hemisphere) then begin
	if keyword_set(north) then $
		hemisphere = 1. $
	else if keyword_set(south) then $
		hemisphere = -1. $
	else $
		hemisphere = 1.
endif

; this makes int_hemi 0 for north and 1 for south
int_hemi = (hemisphere lt 0)

if amp_info[int_hemi].nrecs eq 0L then begin
	if ~keyword_set(silent) then $
		prinfo, 'No AMPERE data loaded.'
	return, -1.
endif

if ~keyword_set(coords) then $
	coords = get_coordinates()

if ~strcmp(coords, 'mlt') then begin
	prinfo, 'Coordinate system must be MLT, setting to MLT'
	coords = 'mlt'
endif

nn = n_elements(juls)

if nn ne n_elements(lats) then begin
	prinfo, 'Julian days, latitudes and longitudes must have the same size.'
	return, -1.
endif

if nn ne n_elements(lons) then begin
	prinfo, 'Julian days, latitudes and longitudes must have the same size.'
	return, -1.
endif

if ~keyword_set(dbeast) and ~keyword_set(dbnorth) and ~keyword_set(current) and ~keyword_set(poynting) then begin
	prinfo, 'Must choose whether to plot raw or fitted data, current, or poynting. Choosing current.'
	dbeast = 0
	dbnorth = 0
	current = 1
	poynting = 0
endif

output = fltarr(nn)

caldat, juls, mm, dd, years
utsec = ( juls - julday(1,1,years,0) )*86400.d

if strcmp(coords, 'geog', /fold) then begin
	tmp = cnvcoord(lats, lons, replicate(300., nn))
	_lats = reform(tmp[0,*])
	_lons = mlt( years, utsec, reform(tmp[1,*]) )
endif else if strcmp(coords, 'magn', /fold) then begin
	_lats = lats
	_lons = mlt( years, utsec, lons )
endif else begin
	_lats = lats
	_lons = lons
endelse

for i=0L, nn-1L do begin

	if ~keyword_set(index) then begin
		dd = min( abs( (*amp_data[int_hemi]).mjuls - juls[i] ), index )
		if dd*1440.d gt 15. then $
			prinfo, 'Ampere data found, but '+string(dd*1440.d)+' minutes away.'
	endif
	
	nlats = (*amp_data[int_hemi]).nlat[index]
	nlons = (*amp_data[int_hemi]).nlon[index]
	alats = 90.-reform((*amp_data[int_hemi]).colat[index, *])
	amlts = reform((*amp_data[int_hemi]).mlt[index, *])

	if keyword_set(dbnorth) then $
		ovals = (*amp_data[int_hemi]).dbnorth2[index,*] $
	else if keyword_set(dbeast) then $
		ovals = (*amp_data[int_hemi]).dbeast2[index,*] $
	else if keyword_set(current) then $
		ovals = (*amp_data[int_hemi]).jr[index,*] $
	else if keyword_set(poynting) then begin
		ovals = (*amp_data[int_hemi]).poynting[index,*]
		if keyword_set(p1) then $
			ovals = (*amp_data[int_hemi]).p1[index,*]
		if keyword_set(p2) then $
			ovals = (*amp_data[int_hemi]).p2[index,*]
	endif
	mind = round(_lons[i])
	dd = min( abs( alats[0:nlats-1L] - round(_lats[i]) ), lind )
	;mind = floor(_lons[i])
	;dd = min( abs( alats[0:nlats-1L] - floor(_lats[i]) ), lind )
	;if alats[lind] lt floor(_lats[i]) then $
	;	lind -= 1L

	;print, _lats[i], _lons[i]
	;print, alats[lind], mind

	;vals = [ $
	;	[ ovals[mind*nlats + lind + 1L], ovals[(mind+1)*nlats + lind + 1L] ], $
	;	[ ovals[mind*nlats + lind],      ovals[(mind+1)*nlats + lind]      ] $
	;]
	;print, vals
	;print, [ $
	;	[ alats[mind*nlats + lind - 1L], alats[(mind+1)*nlats + lind - 1L ] ], $
	;	[ alats[mind*nlats + lind],      alats[(mind+1)*nlats + lind]       ] $
	;]
	;print, [ $
	;	[ amlts[mind*nlats + lind - 1L], amlts[(mind+1)*nlats + lind - 1L ] ], $
	;	[ amlts[mind*nlats + lind],      amlts[(mind+1)*nlats + lind]       ] $
	;]
	;ix = _lons[i] - floor(_lons[i])
	;jy = _lats[i] - floor(_lats[i])
	;print, ix, jy
	;output[i] = bilinear(vals, ix, jy)
	;print, index
	;print, _lats[i], _lons[i]
	;print,  alats[mind*nlats + lind], amlts[mind*nlats + lind]
	output[i] = ovals[mind*nlats + lind]
	;print, output[i]

	;if i gt 50 then stop

endfor

return, output

end