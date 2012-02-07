function get_aspect, xrange=xrange, yrange=yrange

if n_elements(xrange) ne 2 then $
	_xr = !x.crange $
else $
	_xr = xrange

if n_elements(yrange) ne 2 then $
	_yr = !y.crange $
else $
	_yr = yrange

return, float(_xr[1]-_xr[0])/float(_yr[1]-_yr[0])

end