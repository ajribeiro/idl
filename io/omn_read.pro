;+ 
; NAME: 
; OMN_READ
;
; PURPOSE: 
; This procedure reads OMNI data into the variables of the structure OMN_DATA in
; the common block OMN_DATA_BLK. The time range for which data is read is controled by
; the DATE and TIME keywords.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; OMN_READ, Date
;
; INPUTS:
; Date: The date of which to read data. Can be a scalar in YYYYMMDD format or
; a 2-element vector in YYYYMMDD format.
;
; KEYWORD PARAMETERS:
; TIME: The time range for which to read data. Must be a 2-element vector in 
; HHII format, or HHIISS format if the LONG keyword is set. If TIME is not set
; the default value [0000,2400] is assumed.
;
; LONG: Set this keyword to indicate that the Time value is in HHIISS
; format rather than HHII format.
;
; SILENT: Set this keyword to surpress warnings but not error messages.
;
; PROCEDURE:
; If Date is a scalar
; and Time[0] < Time[1], the interval stretches from Time[0] on Date to Time[1] 
; on Date. If Time[0] > Time[1], the interval stretches from Time[0] on Date to
; Time[1] on the day after Date. If Date is a two element vector, the interval
; stretches from Time[0] on Date[0] to Time[1] on Date[1].
;
; COMMON BLOCKS:
; OMN_DATA_BLK: The common block holding the currently loaded OMNI data and 
; information about that data.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Based on Steve Milan's READ_FILES.
; Written by Lasse Clausen, Nov, 24 2009
; Changed to 1 minute format, 13 Jan, 2010
;-
pro omn_read, date, time=time, long=long, $
	silent=silent, force=force

common omn_data_blk

; set nrecs to zero such that 
; you have a way of checking
; whether data was loaded.
omn_info.nrecs = 0L

;- The common format for the 1-min and 5-min OMNI data sets is
;- 
;- 01	Year			        I4	      1995 ... 2006
;- 02	Day			        I4	1 ... 365 or 366
;- 03	Hour			        I3	0 ... 23
;- 04	Minute			        I3	0 ... 59 at start of average
;- 05	ID for IMF spacecraft	        I3	See  footnote D below
;- 06	ID for SW Plasma spacecraft	I3	See  footnote D below
;- 07	# of points in IMF averages	I4
;- 08	# of points in Plasma averages	I4
;- 09	Percent interp		        I4	See  footnote A above
;- 10	Timeshift, sec		        I7
;- 11	RMS, Timeshift		        I7
;- 12	RMS, Phase front normal	        F6.2	See Footnotes E, F below
;- 13	Time btwn observations, sec	I7	DBOT1, See  footnote C above
;- 14	Field magnitude average, nT	F8.2
;- 15	Bx, nT (GSE, GSM)		F8.2
;- 16	By, nT (GSE)		        F8.2
;- 17	Bz, nT (GSE)		        F8.2
;- 18	By, nT (GSM)	                F8.2	Determined from post-shift GSE components
;- 19	Bz, nT (GSM)	                F8.2	Determined from post-shift GSE components
;- 20	RMS SD B scalar, nT	        F8.2	
;- 21	RMS SD field vector, nT	        F8.2	See  footnote E below
;- 22	Flow speed, km/s		F8.1
;- 23	Vx Velocity, km/s, GSE	        F8.1
;- 24	Vy Velocity, km/s, GSE	        F8.1
;- 25	Vz Velocity, km/s, GSE	        F8.1
;- 26	Proton Density, n/cc		F7.2
;- 27	Temperature, K		        F9.0
;- 28	Flow pressure, nPa		F6.2	See  footnote G below		
;- 29	Electric field, mV/m		F7.2	See  footnote G below
;- 30	Plasma beta		        F7.2	See  footnote G below
;- 31	Alfven mach number		F6.1	See  footnote G below
;- 32	X(s/c), GSE, Re		        F8.2
;- 33	Y(s/c), GSE, Re		        F8.2
;- 34	Z(s/c), GSE, Re		        F8.2
;- 35	BSN location, Xgse, Re	        F8.2	BSN = bow shock nose
;- 36	BSN location, Ygse, Re	        F8.2
;- 37	BSN location, Zgse, Re 	        F8.2
;- 38	AE-index, nT                    I6      See World Data Center for Geomagnetism, Kyoto
;- 39	AL-index, nT                    I6      See World Data Center for Geomagnetism, Kyoto
;- 40	AU-index, nT                    I6      See World Data Center for Geomagnetism, Kyoto
;- 41	SYM/D index, nT                 I6      See World Data Center for Geomagnetism, Kyoto
;- 42	SYM/H index, nT                 I6      See World Data Center for Geomagnetism, Kyoto
;- 43	ASY/D index, nT                 I6      See World Data Center for Geomagnetism, Kyoto
;- 44	ASY/H index, nT                 I6      See World Data Center for Geomagnetism, Kyoto
;- 45	PC(N) index,                    F7.2    See World Data Center for Geomagnetism, Copenhagen

;1996   5  0 16 51 99   2 999 100   1441     12  0.00     23    5.36    4.76   -2.45   -0.02   -2.34   -0.74    0.04    0.06 99999.9 99999.9 99999.9 99999.9 999.99 9999999. 99.99 999.99 999.99 999.9 9999.99 9999.99 9999.99   13.57   -1.12   -0.41 99999 99999 99999     1    -7     7    20   0.60

fmt = '(2I4,4I3,3I4,2I7,F6.2,I7,8F8.2,4F8.1,F7.2,F9.0,F6.2,F7.2,F7.2,F6.1,6F8.2,7I6,F7.2)'

; resolution is 1 minute, hence one day
; has 1440 data records
NFILERECS = 1440L
NROWS = 45

; check if parameters are given
if n_params() lt 1 then begin
	prinfo, 'Must give date.'
	return
endif

if ~keyword_set(force) && omn_check_loaded(date, time=time, long=long) then $
	return

; set deault time if neccessary
if ~keyword_set(time) then $
	time = [0000,2400]

if size(date, /type) eq 7 then begin
	parse_str_date, date, ndate
	if n_elements(ndate) eq 0 then $
		return
	date = ndate
endif

sfjul, date, time, sjul, fjul, no_days=nd
caldat, sjul, mm, dd, yy, hh, ii, ss

array_size = NFILERECS*nd
data = make_array(array_size, NROWS, /float, value=9999.99)
tdata = fltarr(NROWS)

for d=0L, nd-1L do begin

	caldat, sjul+double(d), nmm, dd, nyy
	astr_date = format_date(nyy*10000L+nmm*100L+dd)
	
	if ~keyword_set(datdi) then $
		adatdi = omn_get_path(nyy) $
	else $
		adatdi = datdi

	if ~file_test(adatdi, /dir) then begin
		prinfo, 'Data directory does not exist: ', adatdi, /force
		continue
	endif

;- 	ofile = '/home/lbnc/data/ace/omni/'+str_year+'/'+astr_date+'_ace_5min.asc'
	filename = file_select(adatdi+'/'+astr_date+'_omni.asc', $
		success=success)
	if ~success then begin
		prinfo, 'Data file not found.'
		continue
	endif
	
	if ~keyword_set(silent) then $
		prinfo, 'Reading ', filename

	openr, ilun, filename, /get_lun
	for l=0L, NFILERECS-1L do begin
		readf, ilun, tdata, format=fmt
		data[d*NFILERECS+l, *] = tdata
	endfor
	free_lun, ilun

endfor

juls = julday(1, data[*,1], data[*,0], data[*,2], data[*,3], 0)
jinds = where(juls ge sjul and juls le fjul, ccc)
if ccc eq 0L then begin
	prinfo, 'Cannot find data for '+format_juldate(sjul)+'-'+format_juldate(fjul)
	return
endif

data = data[jinds,*]
tomn_data = { $
	juls: dblarr(ccc), $
	bx_gse: fltarr(ccc), $
	by_gse: fltarr(ccc), $
	bz_gse: fltarr(ccc), $
	by_gsm: fltarr(ccc), $
	bz_gsm: fltarr(ccc), $
	bt: fltarr(ccc), $
	vx_gse: fltarr(ccc), $
	vy_gse: fltarr(ccc), $
	vz_gse: fltarr(ccc), $
	vt: fltarr(ccc), $
	ex_gse: fltarr(ccc), $
	ey_gse: fltarr(ccc), $
	ez_gse: fltarr(ccc), $
	ey_gsm: fltarr(ccc), $
	ez_gsm: fltarr(ccc), $
	et: fltarr(ccc), $
	np: fltarr(ccc), $
	pd: fltarr(ccc), $
	mag_sc: strarr(ccc), $
	swe_sc: strarr(ccc), $
	beta: fltarr(ccc), $
	ma: fltarr(ccc), $
	timeshift: fltarr(ccc) $
}
tomn_data.juls = juls[jinds]

tomn_data.bx_gse = data[*,14]
inds = where(tomn_data.bx_gse eq 9999.99, cc)
if cc gt 0L then $
	tomn_data.bx_gse[inds] = !values.f_nan

tomn_data.by_gse = data[*,15]
inds = where(tomn_data.by_gse eq 9999.99, cc)
if cc gt 0L then $
	tomn_data.by_gse[inds] = !values.f_nan

tomn_data.bz_gse = data[*,16]
inds = where(tomn_data.bz_gse eq 9999.99, cc)
if cc gt 0L then $
	tomn_data.bz_gse[inds] = !values.f_nan

tomn_data.by_gsm = data[*,17]
inds = where(tomn_data.by_gsm eq 9999.99, cc)
if cc gt 0L then $
	tomn_data.by_gsm[inds] = !values.f_nan

tomn_data.bz_gsm = data[*,18]
inds = where(tomn_data.bz_gsm eq 9999.99, cc)
if cc gt 0L then $
	tomn_data.bz_gsm[inds] = !values.f_nan

tomn_data.bt = data[*,13]
inds = where(tomn_data.bt eq 9999.99, cc)
if cc gt 0L then $
	tomn_data.bt[inds] = !values.f_nan

tomn_data.vx_gse = data[*,22]
inds = where(tomn_data.vx_gse eq 99999.9, cc)
if cc gt 0L then $
	tomn_data.vx_gse[inds] = !values.f_nan

tomn_data.vy_gse = data[*,23]
inds = where(tomn_data.vy_gse eq 99999.9, cc)
if cc gt 0L then $
	tomn_data.vy_gse[inds] = !values.f_nan

tomn_data.vz_gse = data[*,24]
inds = where(tomn_data.vz_gse eq 99999.9, cc)
if cc gt 0L then $
	tomn_data.vz_gse[inds] = !values.f_nan

tomn_data.vt = data[*,21]
inds = where(tomn_data.vt eq 99999.9, cc)
if cc gt 0L then $
	tomn_data.vt[inds] = !values.f_nan

; calculate the sw electric field
tomn_data.ex_gse = -(tomn_data.vy_gse*tomn_data.bz_gse - tomn_data.vz_gse*tomn_data.by_gse)*1e-3
tomn_data.ey_gse = -(tomn_data.vz_gse*tomn_data.bx_gse - tomn_data.vx_gse*tomn_data.bz_gse)*1e-3
tomn_data.ez_gse = -(tomn_data.vx_gse*tomn_data.by_gse - tomn_data.vy_gse*tomn_data.bx_gse)*1e-3
tomn_data.et = sqrt(tomn_data.ex_gse^2 + tomn_data.ey_gse^2 + tomn_data.ez_gse^2)

; transform to GSM
inds = where(finite(tomn_data.ex_gse), cc, complement=ninds, ncomplement=nc)
if cc gt 0L then begin
	caldat, tomn_data.juls[inds], imn, idy, iyear, ih, im, is
	estime = date2es(imn,idy,iyear,ih,im,is)
	; call CXFORM routine
	; for the magnetic field
	ib = transpose([[tomn_data.ex_gse[inds]],[tomn_data.ey_gse[inds]],[tomn_data.ez_gse[inds]]])
	ob = cxform(ib, 'GSE', 'GSM', estime)
	tomn_data.ey_gsm[inds] = ob[1,*]
	tomn_data.ez_gsm[inds] = ob[2,*]
endif
if nc gt 0L then begin
	tomn_data.ey_gsm[ninds] = !values.f_nan
	tomn_data.ez_gsm[ninds] = !values.f_nan
endif

tomn_data.np = data[*,25]
inds = where(tomn_data.np eq 999.99, cc)
if cc gt 0L then $
	tomn_data.np[inds] = !values.f_nan

tomn_data.pd = data[*,27]
inds = where(tomn_data.pd eq 99.99, cc)
if cc gt 0L then $
	tomn_data.pd[inds] = !values.f_nan

tomn_data.beta = data[*,29]
inds = where(tomn_data.beta eq 999.99, cc)
if cc gt 0L then $
	tomn_data.beta[inds] = !values.f_nan

tomn_data.ma = data[*,30]
inds = where(tomn_data.ma eq 999.9, cc)
if cc gt 0L then $
	tomn_data.ma[inds] = !values.f_nan

;	ACE	71
;	Geotail	60
;	IMP 8	50
;	Wind	51
inds = where(data[*,4] eq 71, cc)
if cc gt 0L then $
	tomn_data.mag_sc[inds] = replicate('ACE', cc)
inds = where(data[*,4] eq 60, cc)
if cc gt 0L then $
	tomn_data.mag_sc[inds] = replicate('Geotail', cc)
inds = where(data[*,4] eq 50, cc)
if cc gt 0L then $
	tomn_data.mag_sc[inds] = replicate('IMP 8', cc)
inds = where(data[*,4] eq 51, cc)
if cc gt 0L then $
	tomn_data.mag_sc[inds] = replicate('Wind', cc)

inds = where(data[*,5] eq 71, cc)
if cc gt 0L then $
	tomn_data.swe_sc[inds] = replicate('ACE', cc)
inds = where(data[*,5] eq 60, cc)
if cc gt 0L then $
	tomn_data.swe_sc[inds] = replicate('Geotail', cc)
inds = where(data[*,5] eq 50, cc)
if cc gt 0L then $
	tomn_data.swe_sc[inds] = replicate('IMP 8', cc)
inds = where(data[*,5] eq 51, cc)
if cc gt 0L then $
	tomn_data.swe_sc[inds] = replicate('Wind', cc)

tomn_data.timeshift = float(data[*,9])
inds = where(tomn_data.timeshift gt 2e5, cc); or tomn_data.timeshift gt 99990L, cc)
if cc gt 0L then $
	tomn_data.timeshift[inds] = !values.f_nan

omn_data = tomn_data

omn_info.sjul = juls[jinds[0]]
omn_info.fjul = juls[jinds[ccc-1L]]
omn_info.nrecs = ccc

end
