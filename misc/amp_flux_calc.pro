function amp_flux_calc, boundary, dflux=dflux, $
	altitude=altitude, dlat=dlat, $
	north=north, south=south, $
	area=area, darea=darea

if ~keyword_set(north) and ~keyword_set(south) then $
	north = 1

if ~keyword_set(altitude) then $
	altitude = 100.
_altitude = altitude*1e3

if ~keyword_set(dlat) then $
	dlat = .1

Beq     = 3.1e-5 ; nT
dlon    = 360/24.0

flux    = 0.0
dflux   = [0.0, 0.0]

area    = 0.0
darea   = [0.0, 0.0]

if keyword_set(north) then $
	_bnd = boundary
if keyword_set(south) then $
	_bnd = 180. - boundary

FOR m=0,23 DO BEGIN

	if ~finite(_bnd[m]) or _bnd[m] ge 89. or _bnd[m] le 1.+dlat then begin
		area = !values.f_nan
		darea = [!values.f_nan, !values.f_nan]
		dflux = [!values.f_nan, !values.f_nan]
		return, !values.f_nan
	endif
	
	nn = floor((_bnd[m]-1.)/dlat)
	colats = findgen(nn)*dlat
	Brs = 2.*Beq*cos(colats*!dtor)*(!re*1e3/(!re*1e3+_altitude))^3
	area_elements = !re*1e3*!re*1e3*sin(colats*!dtor)*(dlat*!dtor)*(dlon*!dtor)
	darea[0] += total(area_elements)
  flux_elements = area_elements*Brs
  dflux[0] += total(flux_elements)

	nn = floor((_bnd[m]+1.)/dlat)
	colats = findgen(nn)*dlat
	Brs = 2.*Beq*cos(colats*!dtor)*(!re*1e3/(!re*1e3+_altitude))^3
	area_elements = !re*1e3*!re*1e3*sin(colats*!dtor)*(dlat*!dtor)*(dlon*!dtor)
	darea[1] += total(area_elements)
  flux_elements = area_elements*Brs
  dflux[1] += total(flux_elements)

	nn = floor(_bnd[m]/dlat)
	colats = findgen(nn)*dlat
	Brs = 2.*Beq*cos(colats*!dtor)*(!re*1e3/(!re*1e3+_altitude))^3
	area_elements = !re*1e3*!re*1e3*sin(colats*!dtor)*(dlat*!dtor)*(dlon*!dtor)
	area += total(area_elements)
  flux_elements = area_elements*Brs
  flux += total(flux_elements)
  
ENDFOR

return, flux

end
