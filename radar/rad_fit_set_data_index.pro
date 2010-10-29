pro rad_fit_set_data_index, data_index

common rad_data_blk

if n_params() lt 1 then begin
	prinfo, 'Must give data_index.'
	return
endif

if data_index gt rad_max_radars then begin
	prinfo, 'Data index larger than maximum radar number.'
	return
endif

rad_data_index = data_index

end