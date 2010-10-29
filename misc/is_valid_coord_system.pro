function is_valid_coord_system, coords

ind = where(!valid_coords eq strlowcase(coords),cc)
if cc gt 0 then $
	return, !true

return, !false

end