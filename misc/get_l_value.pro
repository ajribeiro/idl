function get_l_value, pos, gse=gse, gsm=gsm, geo=geo, mag=mag, $
	km=km, coords=coords, juls=juls

if n_params() lt 1 then begin
	prinfo, 'Must give position.'
	return, -1.
endif

ndims = size(pos, /dim)
nndim = size(pos, /n_dim)

if ndims[0] ne 3 then begin
	prinfo, 'Position must be 3-element or 3,N-element vector.'
	return, -1.
endif
nrecs = (nndim eq 1 ? 1L : ndims[nndim-1])

if keyword_set(coords) then begin
	if strlowcase(coords) eq 'geog' then $
		geo = 1 $
	else if strlowcase(coords) eq 'magn' then $
		mag = 1 $
	else begin
		prinfo, 'Coordinate system not supported: '+coords
		return, -1.
	endelse
endif

if keyword_set(gse) or keyword_set(gse) then begin
	if ~keyword_set(juls) then begin
		prinfo, 'Must give juldates when using GSM or GSE.'
		return, -1.
	endif
	if n_elements(juls) ne nrecs then begin
		prinfo, 'Juls and Pos must have the same size.'
		return, -1.
	endif
	return, -1.
endif

if keyword_set(geo) then begin
	_pos = cnvcoord(pos)	
endif else if keyword_set(mag) then $
	_pos = pos

return, 1./cos(reform(_pos[0,*])*!dtor)^2

end