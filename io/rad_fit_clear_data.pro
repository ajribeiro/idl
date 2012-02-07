pro rad_fit_clear_data

common rad_data_blk

for i=0, rad_max_radars-1 do begin

	; clear info
	if ptr_valid(rad_fit_info[i]) then $
		ptr_free, rad_fit_info[i]
	
	; clear data
	if ptr_valid(rad_fit_data[i]) then $
		ptr_free, rad_fit_data[i]

endfor

; info structure for fit data
rad_fit_info_str = { $
	sjul: 0.0d, $
	fjul: 0.0d, $
	name: '', $   ; like Blackstone
	code: '', $     ; like bks
	id: 0, $    ; like 33
	scan_ids: -1, $
	channels: -1, $
	glat: 0.0, $
	glon: 0.0, $
	mlat: 0.0, $
	mlon: 0.0, $
	nbeams: 16, $
	ngates: 75, $
	bmsep: 3.24, $
;	fov_loc_center: ptr_new(), $ ; fltarr(2, 17, 76), $ changed to pointer because different radars have different number of beams, gates
;	fov_loc_full: ptr_new(), $ ; fltarr(2, 4, 17, 76), $ changed to pointer because different radars have different number of beams, gates
;	fov_coords: '', $
	parameters: ['juls','ysec','beam','scan_id','scan_mark','beam_scan',$
		'channel','power','velocity','width','phi0','elevation',$
		'gscatter','lagfr','smsep','tfreq','noise','atten','ifmode'], $
	nscans: 0L, $
	fitex: 0b, $
	fitacf: 0b, $
	fit: 0b, $
	filtered: 0b, $
	nrecs: 0L $
}
rad_fit_info = ptrarr(rad_max_radars)
for i=0, rad_max_radars-1 do $
	rad_fit_info[i] = ptr_new(rad_fit_info_str)

; pointer array for fit data
rad_fit_data = ptrarr(rad_max_radars)

; reset data index
rad_data_index = -1

end