pro asi_read, date, site, time=time, long=long, $
	CDF_DATA=CDF_DATA, CURSOR=CURSOR, DATATYPE=DATATYPE, $
	FILES=FILES, GET_SUPPORT_DATA=GET_SUPPORT_DATA, $
	LEVEL=LEVEL, NO_DOWNLOAD=NO_DOWNLOAD, PROGOBJ=PROGOBJ, $
	TRANGE=TRANGE, VALID_NAMES=VALID_NAMES, VERBOSE=VERBOSE

common asi_data_blk

; set nrecs to zero such that 
; you have a way of checking
; whether data was loaded.
asi_info.nrecs = 0L

if n_params() ne 2 then begin
	prinfo, 'Must give date and site.'
	return
endif

if asi_check_loaded(date, site, time=time, long=long) then $
	return

if ~keyword_set(time) then $
	time = [0000,2400]

sfjul, date, time, sjul, fjul, long=long

if ~keyword_set(trange) then $
	trange = ([sjul, fjul] - julday(1,1,1970,0))*86400.d

if ~keyword_set(datatype) then $
	datatype = 'asf'

thm_load_asi, site=site, trange=trange, datatype=datatype, $
	CURSOR=CURSOR, $
	FILES=FILES, GET_SUPPORT_DATA=GET_SUPPORT_DATA, $
	LEVEL=LEVEL, NO_DOWNLOAD=NO_DOWNLOAD, PROGOBJ=PROGOBJ, $
	VALID_NAMES=VALID_NAMES, VERBOSE=VERBOSE

thm_load_asi_cal, site, calstr, trange=trange

get_data, 'thg_'+datatype+'_'+site, asf_time, asf
dim = size(asf, /dim)
if dim[0] eq 0 then begin
	prinfo, 'No data loaded.'
	return
endif

tpnames = tnames('thg_'+datatype+'*')
store_data, tpnames, /delete

asi_data = { $
	juls: asf_time/86400.d + julday(1,1,1970,0), $
	images: asf $
}

asi_info.sjul = asi_data.juls[0]
asi_info.fjul = asi_data.juls[dim[0]-1L]
asi_info.site = site
asi_info.glat = asi_get_stat_pos(site, coords='geog', lon=glon)
asi_info.glon = glon
asi_info.mlat = asi_get_stat_pos(site, coords='magn', lon=mlon)
asi_info.mlon = mlon
asi_info.l_value = get_l_value([asi_info.mlat,asi_info.mlon,1.],coords='magn')
asi_info.width = dim[1]
asi_info.height = dim[2]
if ptr_valid(asi_info.cal_struc) then $
	ptr_free, asi_info.cal_struc
asi_info.cal_struc = ptr_new(calstr)
asi_info.datatype = datatype
asi_info.nrecs = dim[0]

end