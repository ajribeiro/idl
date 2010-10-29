function is_valid_parameter, param

common rad_data_blk
common dst_data_blk
common omn_data_blk
common ace_data_blk

;print, rad_fit_info.parameters[8] eq strlowcase(param)
;print, where(rad_fit_info.parameters eq strlowcase(param))

ind = where((*rad_fit_info[(rad_fit_get_data_index() > 0)]).parameters eq strlowcase(param),cc)
if cc gt 0 then $
	return, !true

ind = where(dst_info.parameters eq strlowcase(param),cc)
if cc gt 0 then $
	return, !true

ind = where(omn_info.parameters eq strlowcase(param),cc)
if cc gt 0 then $
	return, !true

ind = where(ace_mag_info.parameters eq strlowcase(param),cc)
if cc gt 0 then $
	return, !true

ind = where(ace_swe_info.parameters eq strlowcase(param),cc)
if cc gt 0 then $
	return, !true

return, !false

end