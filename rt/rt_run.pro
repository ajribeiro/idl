;+ 
; NAME: 
; RT_RUN
;
; PURPOSE: 
; This procedure runs raytracing code or read existing raytracing results into
; the common block RT_DATA_BLK. The time range for which data is read is controled by
; the DATE and TIME keywords.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; RT_RUN, Date, Radar[, time=time, sti=sti, beam=beam, mmin=mmin, freq=freq, el_stp=el_stp, /hhour, /noplot]
;
; INPUTS:
; DATE: the date for which you want to run the raytracing (for IRI model)
; Format is DDMMYYYY
;
; RADAR: the radar code for which you want to run the raytracing
;
; KEYWORD PARAMETERS:
; BEAM: the beam for which you want to run the raytracing (default is boresight)
;
; TIME: time interval for which you want to run the raytracing, default is [0000,2400]
;
; STI: set to 'UT' or 'LT', default is 'UT'
;
; FREQ: operating frequency
;
; EL_STP: elevation angle step size in degrees
;
; HHOUR: set this keyword to run with 1/2 hour precision (default 1 hr)
;
; MMIN: set this keyword to the requiered precision in minutes
;
; NOPLOT
;
; COMMON BLOCKS:
; RT_DATA_BLK: The common block holding the currently loaded raytracing data and 
; information about that data.
;
; EXAMPLE:
;	; Run the raytracing for august 2 2010 for Blackstone
;	; from 17 to 24 LT 
;	rt_run, 20100802, 'bks', time=[1700,2400], sti='LT'
;	; Plot results on range-time plot for the first 60 gates
;	rt_plot_rti, yrange=[0,60]
;
; MODIFICATION HISTORY:
; Based on Lasse Clausen, RAD_FIT_READ
; Based on Nitya Ravindran, RT
; Written by Sebastien de Larquier, Sept. 2010
;	Last modified 17-09-2010
;-
pro 	RT_RUN,	date, radar, hhour=hhour, mmin=mmin, $
	time=time, sti=sti, beam=beam, $
	noplot=noplot, freq=freq, el_stp=el_stp
	
common	rt_data_blk
common	radarinfo

print, 	'---------------running RT_RUN---------------'
; procedure to execute multiple hours of raytracing

if ~keyword_set(beam) then $
	beam = 7

if ~keyword_set(freq) then $
	freq = 11.

; Generate input file
rt_write_input, radar, date=date, beam=beam, outdir=outdir, $
	filename=filename, freq=freq, el_stp=el_stp

script_time = STRMID(STRJOIN(STRSPLIT(systime(),' :' ,/extract), '-'),0,16)


; Choose day for IRI model
IF n_elements(date) gt 1 THEN BEGIN
	prinfo, 'date does not accept more than one element (for now)'
	return
ENDIF

; Choose hours for IRI model (use findgen to generate many succesive hours)
IF ~keyword_set(time) THEN $
	time = [0000,2400]
IF n_elements(time) eq 1 THEN $
	arr_hr = time/100L + (time/100.-time/100L)*100./60. $
ELSE $
	IF time(0) eq time(1) THEN $
		arr_hr=INDGEN(24)+time(0)/100L $
	ELSE $
		arr_hr=FINDGEN(time(1)/100L+1.-time(0)/100L)+time(0)/100L
IF keyword_set(hhour) AND n_elements(time) gt 1 THEN BEGIN
	tarr_hr = 0.*FINDGEN(n_elements(arr_hr)*2)
	inds = INDGEN(n_elements(arr_hr))
	tarr_hr[2*inds] = arr_hr
	tarr_hr[2*inds+1] = arr_hr+.5
	arr_hr = 0.
	arr_hr = tarr_hr
ENDIF
IF keyword_set(mmin) AND n_elements(time) gt 1 THEN BEGIN
	tarr_hr = 0.*FINDGEN((ROUND((time[1]-time[0])/100.)*60. + (time[1]-time[0]-(time[1]/100L-time[0]/100L)*100.))/mmin + 1)
	tarr_hr[0] = time[0]/100L + (time[0]/100.-floor(time[0]/100L))*100./60.
	FOR nh=1, n_elements(tarr_hr)-1 DO BEGIN
		tarr_hr[nh] = tarr_hr[nh-1] + mmin*1./60.
	ENDFOR
	arr_hr = 0.
	arr_hr = tarr_hr
ENDIF
; Choose time zone (UT, LT)
IF ~keyword_set(sti) THEN $
	sti = 'UT'
tz=sti

davit_lib = getenv("DAVIT_LIB")

CD, CURRENT = pwdir

; cycle trhough the hours to generate raytrace
tsteps 		= n_elements(arr_hr)
ngates 		= 110
year 		= date/10000L
month 		= (date - year*10000L)/100L
day 		= date - (year*10000L + month*100L)
range_gate 	= [0, 180L + 45L*FINDGEN(ngates)]
nrecs 		= 0
FOR hr = 0, (tsteps-1) DO BEGIN
	; adjust for UT or LT
	IF (arr_hr[hr] gt 24.) then BREAK
	CASE tz OF
		'UT': hrU=arr_hr[hr]+25
		'LT': hrU=arr_hr[hr]
	ENDCASE
	PRINT, 'Process hour:', hrU

if ~file_test('/temp/rt', /dir) then begin
  FILE_MKDIR, '/tmp/rt'
endif
dirname='/tmp/rt/ray_'+radar+STRTRIM(beam,2)+'_'+STRTRIM(date,2)+'_'+ $
		STRTRIM(STRING(floor(arr_hr[hr])*100L + ROUND((arr_hr[hr]-floor(arr_hr[hr]))*60.),format='(I04)'),2)+tz
print, dirname
dirTest = FILE_TEST(dirname+'/raytrace.ps', /READ)

; Run raytracing if no data already exist
IF ~(dirTest EQ 1) THEN BEGIN
		FILE_MKDIR, dirname
	
		rdate = STRMID(date,4,4)+','+STRMID(date,8,2)+STRMID(date,10,2)+','+STRTRIM(hrU,2)

		spawn, 'echo "'+outdir+'/'+filename+'" > inp_file'
		spawn, 'echo '+rdate+' >> inp_file'
		spawn, davit_lib+'/vt/rt/IRI/jiri < inp_file'
	
		if ~keyword_set(noplot) then begin
			rt_plot_rays, radar=radar, beam=beam, $
				MAX_HEIGHT=MAX_HEIGHT, MAX_RANGE=MAX_RANGE, gate_len=gate_len, $
				plotrays=plotrays, date=date, time=arr_hr[hr]
		endif
		
		; Copy raytracing output files into hourly folders
		FILE_MOVE, ['edens.dat', 'groundkv.dat', 'groundpos.dat', $
			'inp_file', 'kvect.dat', 'magy.dat', 'ranges.dat', 'rayinp.dat', $
			'rays.dat', 'sigstr.dat', 'summary.dat', 'outfile.dat', $
			'uhybrid.dat','day_edens.dat'], dirname
		if ~keyword_set(noplot) then $
			FILE_MOVE, 'raytrace.ps', dirname

	ENDIF ELSE $
		 print, 'Raytracing data already present. Reading from files.'

	; Read data from files to be saved in common block
	openr, unit, dirname+'/rays.dat', /get_lun
	rt_read_header, unit, freq_beg, freq_stp, elev_beg, elev_stp
	free_lun, unit
	OPENR, unit, dirname+'/ranges.dat', /get_lun
	rt_read_ranges, unit, numran, gndran, grpran, ranelv
	FREE_LUN, unit
	
	; display number of ground scatter
	print, 'Gnd scatter = '+STRTRIM(numran,2)
	
	; initialize temp structure at first loop run
	IF hr EQ 0 THEN BEGIN
		; create temp structure to place raytracing data in
		temp_rt_data = { $
			juls: dblarr(tsteps), $
			numran: intarr(tsteps), $
			power: dblarr(tsteps,ngates), $
			gndran: dblarr(tsteps,1000), $
			grpran: dblarr(tsteps,1000), $
			ranelv: dblarr(tsteps,1000), $
			tfreq: dblarr(tsteps) $
		}
		sfjul, date, time, sjul, fjul
		temp_rt_info = { $
			name: radar, $
			nrecs: 0L, $
			sjul: sjul, $
			fjul: fjul, $
			timez: tz, $
			rad: 'tbd', $
			beam: beam, $
			ngates: ngates, $
			fov_loc_center: findgen(ngates+1) $
		}
	ENDIF
	; Data stored
	nrecs = nrecs + numran
	
	; populate structure
	if numran eq 0 then $
		 numran = 1
	temp_rt_data.juls(hr) = JULDAY(month,day,year,floor(arr_hr[hr]),(arr_hr[hr]-floor(arr_hr[hr]))*60.)
	temp_rt_data.numran(hr) = numran
	temp_rt_data.power(hr,*) = 10D*ALOG10( histc(grpran,range_gate) )
	temp_rt_data.gndran(hr,0:numran-1) = gndran
	temp_rt_data.grpran(hr,0:numran-1) = grpran
	temp_rt_data.ranelv(hr,0:numran-1) = ranelv
	temp_rt_data.tfreq(hr) = freq_beg

ENDFOR

temp_rt_info.nrecs = nrecs

; Copy temp structures into common block
rt_data = temp_rt_data
rt_info = temp_rt_info

END

