; get DaViT base directory
; we need to put all commands in one line, otherwise IDL will complain
davit_lib = getenv("DAVIT_LIB")
if strlen(davit_lib) eq 0 then begin & print, '%DAVIT_INIT: Environment variable DAVIT_LIB not defined. Cannot run DaViT' & exit & endif

if strpos(getenv("RAD_TMP_PATH"), "www") ne -1  or fix(getenv("DAVIT_NODISP")) eq 1 then $
	set_plot, 'PS'

; get DLM path of the RST
rst_dlm_path = getenv("DLMPATH")
if strlen(rst_dlm_path) eq 0 then begin & print, '%DAVIT_INIT: Environment variable DLMPATH not defined. Cannot run DaViT' & exit & endif

; set dlm path such that davit find the tsyganenko
; magnetic fiedl routines
; and cxform coordinate transformation routines
PREF_SET, 'IDL_DLM_PATH', rst_dlm_path+':'+davit_lib+'/geopack/idl/dlm:'+davit_lib+'/cxform/cxform:<IDL_DEFAULT>', /COMMIT

; force IDL to use proper array indeces
compile_opt STRICTARRSUBS

; compile coordinate transformation routines of the themis toolkit
.r cotrans_lib

; set some useful system variables
defsysv, '!FALSE', 0b
defsysv, '!TRUE', ~!false
defsysv, '!RE', 6371.
; Defined coord system for gravity wave mapping //NAF - 15 DEC 2011
defsysv, '!VALID_COORDS', ['gate','rang','geog','magn','mlt','gw_rang','gw_geog','gw_magn','gw_mlt']
defsysv, '!CARISMA', 1
defsysv, '!IMAGE', 2
defsysv, '!GREENLAND', 3
defsysv, '!SAMNET', 4
defsysv, '!ANTARCTICA', 5
defsysv, '!GIMA', 6
defsysv, '!JAPMAG', 7
defsysv, '!SAMBA', 8
defsysv, '!INTERMAGNET', 9
defsysv, '!MACCS', 10
defsysv, '!NIPR', 11
defsysv, '!GBM_THEMIS', 12
defsysv, '!ASI_THEMIS', 21

; common block holding the user preferences
common user_prefs, up_format, up_mincharsize, up_windowsize, $
	up_scatterflag, up_coordinates, up_scale, up_parameter, $
	up_beam, up_gate, up_channel, $
	up_editor, up_sc_values

; common block for color preferences
common color_prefs, cp_ncolors, cp_bottom, cp_black, cp_gray, cp_white, $
	cp_red, cp_green, cp_blue, cp_cyan, cp_yellow, cp_magenta, cp_purple, cp_orange, $
	cp_foreground, cp_background, cp_colorsteps, cp_colortable
cp_ncolors = 0
cp_bottom = 0
cp_black = 0
cp_gray = 0
cp_white = 0
cp_red = 0
cp_green = 0
cp_blue = 0
cp_cyan = 0
cp_yellow = 0
cp_magenta = 0
cp_purple = 0
cp_orange = 0
cp_foreground = 0
cp_background = 0
cp_colorsteps = 0
cp_colortable = ''


; common block for PostScript preferences
common postscript, ps_filename, ps_isopen

; common block for radar data
; both fitacf and map potential data
common rad_data_blk, rad_max_radars, rad_data_index, $
	rad_raw_data, rad_raw_info, $
	rad_fit_data, rad_fit_info, $
	rad_map_data, rad_map_info, $
	rad_grd_data, rad_grd_info, $
	cpid_structure

; get maximum number of radars
;rad_max_radars = getenv("RAD_MAX_RADARS")
;if strlen(rad_max_radars) eq 0 then $
rad_max_radars = 20
;rad_max_radars = fix(rad_max_radars)

; this is the index determining which
; of the radar data blocks to write
; the data into
rad_data_index = -1

; info structure for raw data
rad_raw_info = { $
	sjul: 0.0d, $
	fjul: 0.0d, $
	name: '', $   ; like Blackstone
	code: '', $     ; like bks
	id: 0, $    ; like 33
	scan_ids: -1, $
	channels: -1, $
	xcf: 0b, $
	glat: 0.0, $
	glon: 0.0, $
	mlat: 0.0, $
	mlon: 0.0, $
	nbeams: 16, $
	ngates: 75, $
	bmsep: 3.24, $
;	fov_loc_center: ptr_new(), $ ;fltarr(2, 17, 76), $ changed to pointer because different radars have different number of beams, gates
;	fov_loc_full: ptr_new(), $ ;fltarr(2, 4, 17, 76), $ changed to pointer because different radars have different number of beams, gates
;	fov_coords: '', $
	parameters: ['juls','ysec','beam','scan_id','scan_mark',$
		'channel','xcf','acf_i','acf_r',$
		'lagfr','smsep','tfreq','noise','atten','ifmode'], $
	nscans: 0L, $
	dat: 0b, $
	rawacf: 0b, $
	nrecs: 0L $
}

; info structure for fit data
rad_fit_info_str = { $
	sjul: 0.0d, $
	fjul: 0.0d, $
	name: '', $   ; like Blackstone
	code: '', $     ; like bks
	id: 0, $    ; like 33
	scan_ids: -1, $
	channels: -1, $
	xcf: 0b, $
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
		'channel','xcf','lag0power','power','velocity','velocity_error','width','phi0','elevation',$
		'gscatter','lagfr','smsep','tfreq','noise','atten','nave','ifmode'], $
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

; info structure for map data
rad_map_info_hemi = { $
	sjul: 0.0d, $
	fjul: 0.0d, $
	parameters: ['sjuls','mjuls','fjuls','sysec','mysec','fysec', $
		'stnum','vcnum','modnum','imf_delay','b_imf', 'lat_shft', 'lon_shft', $
		'latmin', 'fit_order', 'hm_boundary', $
		'pot_drop','pot_drop_err','pot_min','pot_min_err','pot_max','pot_max_err'], $
	map: 0b, $
	mapex: 0b, $
	nrecs: 0L $  ; number of convection maps
}
rad_map_info = replicate(rad_map_info_hemi, 2)
rad_map_data = ptrarr(2)

; info structure for grid data
rad_grd_info_hemi = { $
	sjul: 0.0d, $
	fjul: 0.0d, $
	parameters: ['sjuls','mjuls','fjuls','sysec','mysec','fysec', $
		'stnum','vcnum','lat_shft', 'lon_shft', $
		'latmin'], $
	grd: 0b, $
	grdex: 0b, $
	nrecs: 0L $  ; number of grids
}
rad_grd_info = replicate(rad_grd_info_hemi, 2)
rad_grd_data = ptrarr(2)

; common block for AMPERE data
common amp_data_blk, amp_data, amp_info

; info structure for AMPERE data
amp_info_hemi = { $
	sjul: 0.0d, $
	fjul: 0.0d, $
	parameters: ['sjuls','mjuls','fjuls', $
		'dbnorth1','dbeast1','dbnorth2', 'dbeast2', $
		'jr','p1','p2','poynting','jr_fit_pos','jr_fit_order','jr_fit_coeffs'], $
	poynting: !false, $ ; true if poynting flux is calculated
	nrecs: 0L $  ; number of blocks
}
amp_info = replicate(amp_info_hemi, 2)
amp_data = ptrarr(2)

; common block for dst index data
common dst_data_blk, dst_data, dst_info
dst_info = { $
	sjul: 0.0d, $
	fjul: 0.0d, $
	parameters: ['juls', 'dst_index'], $
	nrecs: 0L $
}

; common block for ACE satellite data
common ace_data_blk, ace_mag_data, ace_mag_info, ace_swe_data, ace_swe_info
ace_mag_info = { $
	sjul: 0.0d, $
	fjul: 0.0d, $
	parameters: ['juls','bx_gse','by_gse','bz_gse','by_gsm','bz_gsm','bt', $
		'cone_angle', 'clock_angle', $
		'rx_gse','ry_gse','rz_gse','ry_gsm','rz_gsm','rt'], $
	nrecs: 0L $
}
ace_swe_info = { $
	sjul: 0.0d, $
	fjul: 0.0d, $
	parameters: ['juls','vx_gse','vy_gse','vz_gse','vy_gsm','vz_gsm','vt',$
		'ex_gse', 'ey_gse', 'ez_gse', 'ey_gsm', 'ez_gsm', 'et', $
		'tpr', 'beta', $
		'rx_gse','ry_gse','rz_gse','ry_gsm','rz_gsm','rt','np','pd'], $
	nrecs: 0L $
}

; common block for Wind satellite data
common wnd_data_blk, wnd_mag_data, wnd_mag_info, wnd_swe_data, wnd_swe_info
wnd_mag_info = { $
	sjul: 0.0d, $
	fjul: 0.0d, $
	parameters: ['juls','bx_gse','by_gse','bz_gse','by_gsm','bz_gsm','bt','rx_gse','ry_gse','rz_gse','ry_gsm','rz_gsm','rt'], $
	nrecs: 0L $
}
wnd_swe_info = { $
	sjul: 0.0d, $
	fjul: 0.0d, $
	parameters: ['juls','vx_gse','vy_gse','vz_gse','vy_gsm','vz_gsm','vt','np','pd'], $
	nrecs: 0L $
}

; common block for Kp index data
common kpi_data_blk, kpi_data, kpi_info
kpi_info = { $
	sjul: 0.0d, $
	fjul: 0.0d, $
	parameters: ['juls', 'kp_index'], $
	nrecs: 0L $
}

; common block for auroal index data (AU, AL, AE, AO)
common aur_data_blk, aur_data, aur_info
aur_info = { $
	sjul: 0.0d, $
	fjul: 0.0d, $
	parameters: ['juls', 'au_index', 'al_index', 'ae_index', 'ao_index', 'asy_d', 'asy_h', 'sym_d', 'sym_h'], $
	nrecs: 0L $
}

; common block for ground-based magnetometer data
common gbm_data_blk, gbm_data, gbm_info
gbm_info = { $
	sjul: 0.0d, $
	fjul: 0.0d, $
	station: '', $
	chain: 0, $
	glat: 0.0, $
	glon: 0.0, $
	mlat: 0.0, $
	mlon: 0.0, $
	l_value: 0.0, $
	parameters: ['juls', 'bx_mag', 'by_mag', 'bz_mag', 'bt_mag'], $
	nrecs: 0L $
}

; common block for OMNI solar wind data
common omn_data_blk, omn_data, omn_info
omn_info = { $
	sjul: 0.0d, $
	fjul: 0.0d, $
	parameters: ['juls','bx_gse','by_gse','bz_gse','by_gsm','bz_gsm','bt',$
		'cone_angle', 'clock_angle', $
		'vx_gse','vy_gse','vz_gse','vy_gsm','vz_gsm','vt','ex_gse','ey_gse','ez_gse','ey_gsm','ez_gsm','et','beta','ma',$
		'np','pd','mag_sc','swe_sc','timeshift'], $
	nrecs: 0L $
}

; common block for all-sky imager data (via themis) data
common asi_data_blk, asi_data, asi_info
asi_info = { $
	sjul: 0.0d, $
	fjul: 0.0d, $
	site: '', $
	glat: 0.0, $
	glon: 0.0, $
	mlat: 0.0, $
	mlon: 0.0, $
	l_value: 0.0, $
	width: 0, $
	height: 0, $
	parameters: ['juls'], $
	cal_struc: ptrarr(1), $
	datatype: '', $
	nrecs: 0L $
}

; common block for Cluster satellite data
common clu_data_blk, clu_fgm_data, clu_fgm_info
clu_fgm_info_sc = { $
	sjul: 0.0d, $
	fjul: 0.0d, $
	parameters: [ $
		'juls','bx_gse','by_gse','bz_gse','by_gsm','bz_gsm','bt', $
		       'rx_gse','ry_gse','rz_gse','ry_gsm','rz_gsm','rt' $
	], $
	nrecs: 0L $
}
clu_fgm_info = replicate(clu_fgm_info_sc, 4)
clu_fgm_data = ptrarr(4)

common the_data_blk, the_mfp_data, the_mfp_info, the_pos_data, the_pos_info, $
	the_fgm_data, the_fgm_info, the_esa_data, the_esa_info

the_mfp_info_sc = { $
	sjul: 0.0d, $
	fjul: 0.0d, $
	parameters: [ $
		'juls', $
		'n_glat','n_glon','n_mlat','n_mlon','n_alt', $
		's_glat','s_glon','s_mlat','s_mlon','s_alt' $
	],  $
	model: '', $
	nrecs: 0L $
}
the_mfp_info = replicate(the_mfp_info_sc, 5)
the_mfp_data = ptrarr(5)

the_pos_info_sc = { $
	sjul: 0.0d, $
	fjul: 0.0d, $
	parameters: [ $
		'juls','rx','ry','rz' $
	],  $
	coords: '', $
	nrecs: 0L $
}
the_pos_info = replicate(the_pos_info_sc, 5)
the_pos_data = ptrarr(5)

the_fgm_info_sc = { $
	sjul: 0.0d, $
	fjul: 0.0d, $
	parameters: [ $
		'juls','bx_gse','by_gse','bz_gse','by_gsm','bz_gsm','bt' $
	],  $
	nrecs: 0L $
}
the_fgm_info = replicate(the_fgm_info_sc, 5)
the_fgm_data = ptrarr(5)

the_esa_info_sc = { $
	sjul: 0.0d, $
	fjul: 0.0d, $
	parameters: [ $
		'juls','ion_dens','ion_temp','ion_pres','ion_vx','ion_vy','ion_vz','e_dens','e_temp','e_pres','e_vx','e_vy','e_vz' $
	],  $
	nrecs: 0L $
}
the_esa_info = replicate(the_esa_info_sc, 5)
the_esa_data = ptrarr(5)

common goe_data_blk, goe_mag_data, goe_mag_info
goe_mag_info = { $
	sjul: 0.0d, $
	fjul: 0.0d, $
	sc: 0, $
	parameters: [ $
		'juls','bfie','bazm','brad','bt','juls_mlt','mlt' $
	],  $
	nrecs: 0L $
}

;, jne:z, jee:z, eav:z, ergs:z $      ; electron fluxes
;, jni:z, jei:z, iav:z, irgs:z $      ; ion fluxes
;, jee3:z, jee5:z, eav5:z $           ; electron flux discarding some channels
;, deflux:z19, diflux:z19 $           ; electron, ion differntial energy flux
;, amlat:z, hemi:0 $                  ; absolute mlat, hemisphere
;, sc_ch_fl:0 $                       ; spacecraft charging flag
;, rad_f_e:z, rad_f_i:z $             ; radiation subtraction fraction 
;, rad_f_el:z, rad_f_il:z $           ; rad subtraction fraction low chans

common dms_data_blk, dms_ssj_data, dms_ssj_info, $
	dms_ssies_data, dms_ssies_info
dms_ssj_info = { $
	sjul: 0.0d, $
	fjul: 0.0d, $
	sat: 0, $
	parameters: [ $
		'juls','glat','glon','mlat','mlon','mlt','jne','jee','deflux','jni','jei','diflux','hemi' $
	],  $
	calibration: ptr_new(), $
	nrecs: 0L $
}
dms_ssies_info = { $
	sjul: 0.0d, $
	fjul: 0.0d, $
	sat: 0, $
	parameters: [ $
		'juls','glat','glon','mlat','mlon','mlt','vh','azm','hemi' $
	],  $
	nrecs: 0L $
}

common tec_data_blk, $
	tec_data, tec_info, $
	tec_median, median_info, $
	tec_avg
tec_info = { sjul: 0.0d, $
	fjul: 0.0d, $
	parameters: ['juls','glat','glon','tec','dtec'], nrecs: 0L $
}
median_info = { dlat: 0, $
	dlon: 0, $
	slat: 0, $
	thresh: 0.0 $
}

common rt_data_blk, rt_data, rt_info, rt_rays
.run rtStruct

common recent_panel, rxmaps, rymaps, rxmap, rymap

; compile all RST routines
@startup
;.run datamap.pro
;.run time.pro
;.run radar.pro
;.run rprm.pro

common radarinfo, network

; set some variables for the X device
if strupcase(!d.name) eq 'X' then begin & device, retain=2 & device, true_color=24 & device, decomposed=0 & end

; we set this so that Themis doesn't
!prompt = 'DaViT> '

; init TDAS without the colors
thm_init, /no_color_setup

; init colors and radars
init_colors
rad_load_colortable
rad_init_radars
rad_cpid_read_table
init_colors

; set initial values
set_format, /landscape
set_windowsize, 800
set_mincharsize, .4
set_coordinates, 'gate'
set_scale, [-500,500]
set_parameter, 'velocity'
rad_set_scatterflag, 0
rad_set_beam, 7
rad_set_gate, 25
rad_set_channel, 0
set_editor, 'gedit'

; init postscript
ps_set_filename, ''
ps_set_isopen, !false

; set font and another variable such that
; the plot area is not cleared before calls
; to PLOT etc.
!p.font = -1
!p.noerase = 1
!p.charthick = 2

; get default date labels
dd = label_date(date_format='%h:%i')

; read user preferences
user_prefs_read
