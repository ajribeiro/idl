function calc_vector_bearing, lats, lons, dist=dist

nlats = n_elements(lats)
nlons = n_elements(lons)

if nlats ne nlons then begin
	prinfo, 'Number of latitudes must be equal to number of longitudes.'
	return, 400.
endif

if nlats lt 2 then begin
	prinfo, 'Number of latitudes must be larger than 2.'
	return, 400.
endif

bearing = dblarr(nlats-1)
dist = dblarr(nlats-1)
_lats = double(lats)
_lons = double(lons)
for i=0L, nlats-2L do begin

	dlon = (_lons[i+1]-_lons[i])*!dtor
	y = sin(dlon)*cos(_lats[i+1]*!dtor)
	x = cos(_lats[i]*!dtor)*sin(_lats[i+1]*!dtor) - sin(_lats[i]*!dtor)*cos(_lats[i+1]*!dtor)*cos(dlon)
	bearing[i] = atan( y, x )*!radeg

endfor

return, bearing

end