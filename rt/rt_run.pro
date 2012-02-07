;+
; NAME:
; RT_RUN
;
; PURPOSE:
; This procedure runs raytracing code or read existing raytracing results into
; the common block RT_DATA_BLK. The time range for which data is read is controled by
; the DATE and TIME keywords. Adapted for MPI code.
;
; CATEGORY:
; Input/Output
;
; CALLING SEQUENCE:
; RT_RUN
;
; INPUTS:
; DATE: the date for which you want to run the raytracing (for IRI model)
; Format is YYYYMMDD
;
; RADAR: the radar code for which you want to run the raytracing
;
; KEYWORD PARAMETERS:
; BEAM: the beam for which you want to run the raytracing (default is all)
;
; TIME: time interval for which you want to run the raytracing, default is [0000,2400]
; If TIME[1] is greater or equal to TIME[0] then TIME[1] is taken to be on the next day.
;
; FREQ: operating frequency in MHz. default is 11MHz
;
; ELEVSTP: elevation angle step size in degrees
;
; DHOUR: specify time reoslution in hour (default is 0.5 hour)
;
; NHOP: specify the number of hop considered in the ray-tracing. Default is 1.
;
; GEOPOS: [latitude, longitude]. Overrides the radar command.
;
; AZIM: To be specified when using the geopos keyword
;
; BIN: set this keyword to the desired parameter for range gate binning (phase, group of ground range).
; Default is group, same as for radars.
;
; LTIME: set this keyword to run in LT instead of UT
;
; OUTDIR: directory where ray-tracing files will be outputed: *.dat contain radar binned results, *.rays contain raw ray paths
;
; BACK
;
; SILENT
;
; NPROCS: Number of processors to be used in computation (default is 4)
;
; COMMON BLOCKS:
; RT_DATA_BLK: The common block holding the currently loaded raytracing data and
; information about that data.
;
; EXAMPLE:
;	; Run the raytracing for august 2 2010 for Blackstone
;	; from 17 to 24 LT
;	rt_run, 20100802, 'bks', time=[1700,2400]
;	; Plot results on range-time plot for the first 60 gates
;	rt_plot_rti, param=['power','elevation']
;
; COPYRIGHT:
; Non-Commercial Purpose License
; Copyright © November 14, 2006 by Virginia Polytechnic Institute and State University
; All rights reserved.
; Virginia Polytechnic Institute and State University (Virginia Tech) owns the DaViT
; software and its associated documentation (“Software”). You should carefully read the
; following terms and conditions before using this software. Your use of this Software
; indicates your acceptance of this license agreement and all terms and conditions.
; You are hereby licensed to use the Software for Non-Commercial Purpose only. Non-
; Commercial Purpose means the use of the Software solely for research. Non-
; Commercial Purpose excludes, without limitation, any use of the Software, as part of, or
; in any way in connection with a product or service which is sold, offered for sale,
; licensed, leased, loaned, or rented. Permission to use, copy, modify, and distribute this
; compilation for Non-Commercial Purpose is hereby granted without fee, subject to the
; following terms of this license.
; Copies and Modifications
; You must include the above copyright notice and this sti=sti, license on any copy or modification
; of this compilation. Each time you redistribute this Software, the recipient automatically
; receives a license to copy, distribute or modify the Software subject to these terms and
; conditions. You may not impose any further restrictions on this Software or any
; derivative works beyond those restrictions herein.
; You agree to use your best efforts to provide Virginia Polytechnic Institute and State
; University (Virginia Tech) with any modifications containing improvements or
; extensions and hereby grant Virginia Tech a perpetual, royalty-free license to use and
; distribute such modifications under the terms of this license. You agree to notify
; Virginia Tech of any inquiries you have for commercial use of the Software and/or its
; modifications and further agree to negotiate in good faith with Virginia Tech to license
; your modifications for commercial purposes. Notices, modifications, and questions may
; be directed by e-mail to Stephen Cammer at cammer@vbi.vt.edu.
; Commercial Use
; If you desire to use the software for profit-making or commercial purposes, you agree to
; negotiate in good faith a license with Virginia Tech prior to such profit-making or
; commercial use. Virginia Tech shall have no obligation to grant such license to you, and
; may grant exclusive or non-exclusive licenses to others. You may contact Stephen
; Cammer at email address cammer@vbi.vt.edu to discuss commercial use.
; Governing Law
; This agreement shall be governed by the laws of the Commonwealth of Virginia.
; Disclaimer of Warranty
; Because this software is licensed free of charge, there is no warranty for the program.
; Virginia Tech makes no warranty or representation that the operation of the software in
; this compilation will be error-free, and Virginia Tech is under no obligation to provide
; any services, by way of maintenance, update, or otherwise.
; THIS SOFTWARE AND THE ACCOMPANYING FILES ARE LICENSED “AS IS”
; AND WITHOUT WARRANTIES AS TO PERFORMANCE OR
; MERCHANTABILITY OR ANY OTHER WARRANTIES WHETHER EXPRESSED
; OR IMPLIED. NO WARRANTY OF FITNESS FOR A PARTICULAR PURPOSE IS
; OFFERED. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF
; THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE,
; YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR
; CORRECTION.
; Limitation of Liability
; IN NO EVENT WILL VIRGINIA TECH, OR ANY OTHER PARTY WHO MAY
; MODIFY AND/OR REDISTRIBUTE THE PRORAM AS PERMITTED ABOVE, BE
; LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL,
; INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR
; INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS
; OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED
; BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE
; WITH ANY OTHER PROGRAMS), EVEN IF VIRGINIA TECH OR OTHER PARTY
; HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
; Use of Name
; Users will not use the name of the Virginia Polytechnic Institute and State University nor
; any adaptation thereof in any publicity or advertising, without the prior written consent
; from Virginia Tech in each case.
; Export License
; Export of this software from the United States may require a specific license from the
; United States Government. It is the responsibility of any person or organization
; contemplating export to obtain such a license before exporting.
;
; MODIFICATION HISTORY:
; Based on Lasse Clausen, RAD_FIT_READ
; Based on Nitya Ravindran, RT
; Written by Sebastien de Larquier, Sept. 2010
;	Last modified 09-2011
;-
pro 	RT_RUN, date, radar, dhour=dhour, ltime=ltime, $
	time=time, beam=beam, nhop=nhop, azim=azim, $
	freq=freq, elevstp=elevstp, geopos=geopos, $
	back=back, bin=bin, nprocs=nprocs, outdir=outdir, $
	silent=silent,  force=force, no_ionos=no_ionos, no_rays=no_rays

common	rt_data_blk
common	radarinfo


; Save time at begining of run
script_time = systime(/julian, /utc)

; Choose day for IRI model
IF n_elements(date) gt 1 THEN BEGIN
	prinfo, 'date does not accept more than one element (for now)'
	return
ENDIF

if ~keyword_set(freq) then $
	freq = 11.

if ~keyword_set(bin) then $
	bin = 'group'

if ~keyword_set(nprocs) then $
	nprocs = 4

if ~keyword_set(elevstp) then $
	elevstp = .1

if keyword_set(elev) then $
	elev = [5., 55., elevstp]

; Format time parameters
if ~keyword_set(dhour) then $
	dhour = .5
if ~keyword_set(time) then $
	time = [0000,2400]
parse_date, date[0], year, month, day
parse_time, time, shour ,sminutes, fhour, fminutes
hour = [shour + sminutes/60., fhour + fminutes/60., dhour]
if n_elements(time) eq 1 then $
	hour = [shour + sminutes/60., shour + 1., dhour]
sjul = julday(month, day, year, shour, sminutes)
fjul = julday(month, day, year, fhour, fminutes)
if hour[0] ge hour[1] then begin
	fjul = fjul + 1.d
	caldat, fjul, month, day, year
	date = [date, calc_date(date, 1)]
endif
if n_elements(time) eq 1 then $
	hour[1] = hour[0] + .5
if ~keyword_set(ltime) then begin
	hour[0] = hour[0] + 25.
	hour[1] = hour[1] + 25.
	tz = 'UT'
endif else $
	tz = 'LT'

; Read radar location and boresight
if keyword_set(geopos) then begin
	radar = 'custom'
	if ~keyword_set(azim) then begin
		prinfo, 'No azimuth specified.'
		return
	endif
	nbeams = abs(azim[1] - azim[0])/abs(azim[2]) + 1
	beam = indgen(nbeams+2)
	radarsite = { $
				geolat: geopos[0], $
				geolon: geopos[1]}
endif else begin
	radID = where(network.code[0,*] eq radar)
	tval = TimeYMDHMSToEpoch(year, month, day, shour, sminutes, 0)
	for s=0,31 do begin
		if (network[radID].site[s].tval eq -1) then break
		if (network[radID].site[s].tval ge tval) then break
	endfor
	radarsite = network[radID].site[s]

	if n_elements(beam) lt 1 then $
		beam = indgen(radarsite.maxbeam)
	if max(beam) ge radarsite.maxbeam then $
		return

	; Calculate azimuth limits and step
	if ~keyword_set(azim) then begin
		azim = [rt_get_azim(radar, beam[0], date[0]), $
				rt_get_azim(radar, beam[n_elements(beam)-1], date[0]), $
				radarsite.bmsep]
	endif
endelse

; Re-format azimuth input for input file
if n_elements(azim) ne 3 then begin
	azim = [azim, azim, 1.]
endif

; Get path to davit
davit_lib = getenv("DAVIT_LIB")
; davit_lib = ''

; Start MPD
spawn, 'mpdtrace', mpdout
if n_elements(mpdout) gt 1 then begin
	spawn, 'mpd --daemon', mpdout
	print, mpdout
endif

; Some useful parameters
ngates 		= 70
range_gate 	= 180L + 45L*lindgen(ngates+1)
Re = 6370.
P = 180. + findgen(ngates)*45.
minpower = 4.

;******************************************************************************************************
; Get to the ray-tracing part of this all thing
;******************************************************************************************************
; Generate input file for fortran code
rt_write_input, radarsite.geolat, radarsite.geolon, azim, date[0], hour, $
		freq=freq, elev=elev, nhop=nhop, $
		outdir=inputdir, filename=filename, silent=silent


; Check if files exist
if keyword_set(outdir) then begin
	if strmid(outdir,strlen(outdir)-1,1) ne '/' then $
		outdir = outdir+'/'
endif
rtFileTest, date[0], time[0], radar, code=code, outdir=outdir

; Get directory where to store output files
if ~keyword_set(outdir) then begin
	dirname = '/tmp/rt/'
	if ~file_test(dirname, /dir) then $
		FILE_MKDIR, dirname
	if ~file_test(dirname+radar, /dir) then $
		FILE_MKDIR, dirname+radar
	if ~file_test(dirname+radar+'/'+strtrim(year,2), /dir) then $
		FILE_MKDIR, dirname+radar+'/'+strtrim(year,2)
endif else $
		dirname = outdir

;**************************************************************************************
;**************************************************************************************
; Run raytracing if no data already exist
IF ~code OR keyword_set(force) THEN BEGIN

	spawn, 'echo "'+inputdir+filename+'" > /tmp/rt_inp_file'
	spawn, 'mpiexec -n '+strtrim(nprocs, 2)+' '+davit_lib+'/vt/fort/rtmpi/raydarn < /tmp/rt_inp_file'

	; Copy raytracing output files into hourly folders
	FILE_MOVE, '/tmp/'+['edens.dat', 'ranges.dat', 'rays.dat', 'ionos.dat'], $
			dirname, /overwrite

	; Read data from files to be saved in common block
; 	time_mark = systime(/julian, /utc)
	rt_read_header, txlat, txlon, azim_beg, azim_end, azim_stp, $
			elev_beg, elev_end, elev_stp, freq, $
			year, mmdd, hour_beg, hour_end, hour_stp, $
			nhour, nazim, nelev, dir=dirname
; 	print, 'Time reading header files (s): ',(systime(/julian, /utc) - time_mark)*86400.d

	; Ground scatter
; 	time_mark = systime(/julian, /utc)
	rt_read_ranges, rantheta, grpran, ranhour, ranazim, ranelv, ranalt, ran, grndran, $
		lat=ranlat, lon=ranlon, dir=dirname, silent=silent
; 	print, 'Time reading ranges files (s): ',(systime(/julian, /utc) - time_mark)*86400.d

	; Ionospheric scatter
; 	time_mark = systime(/julian, /utc)
	if ~keyword_set(no_ionos) then begin
		rt_read_ionos, normtheta, normgrpran, normhour, normazim, normelv, normalt, normran, normgnd, normweights, normnrefract, $
			lat=ionolat, lon=ionolon, aspect=aspect, dir=dirname, silent=silent
	endif
; 	print, 'Time reading ionos files (s): ',(systime(/julian, /utc) - time_mark)*86400.d

	; Electron densities
; 	time_mark = systime(/julian, /utc)
	rt_read_edens, edens, dip=dip, dir=dirname
; 	print, 'Time reading edens files (s): ',(systime(/julian, /utc) - time_mark)*86400.d

	if ~keyword_set(silent) then $
		print, 'Time reading output files (s): ',(systime(/julian, /utc) - script_time)*86400.d

	; Initialize structure
	rtStructInit, nhour, nazim, ngates+1, rt_data, rt_info

	; Populate data structure
	rt_data.edens = edens[*,*,0:*:10,0:*:2]
	rt_data.dip = dip[*,*,*,0:*:2]

	;***************************************************************************
	; Cycle through time
	parse_date, date[0], year, month, day
	FOR hr=0,nhour-1 do begin

		; times in julian dates
		thour = hour_beg + hr*hour_stp
		if ~keyword_set(ltime) then $
			thour = thour - 25.
		if thour gt 24. then begin
			tdate = calc_date(date[0], 1)
			parse_date, tdate, year, month, day
			thour = thour - 24.
		endif
		rt_data.juls[hr] = JULDAY(month,day,year,floor(thour),(thour-floor(thour))*60.)

		; operating frequency
		rt_data.tfreq[hr] = freq

		;***********************************************************
		; Cycle through beams
		FOR b=0,nazim-1 do begin
			; Define how to bin the data
			case bin of
				'phase':	range_sort = ran[hr,b,*]
				'group':	range_sort = grpran[hr,b,*]
				'ground':	range_sort = grndran[hr,b,*]
			endcase
			if ~keyword_set(no_ionos) then begin
				case bin of
					'phase':	ionosrange_sort = normran[hr,b,*]
					'group':	ionosrange_sort = normgrpran[hr,b,*]
					'ground':	ionosrange_sort = normgnd[hr,b,*]
				endcase
			endif


			;*******************************************
			; populate structures

			; beam and corresponding azimuth
			rt_data.beam[hr,b] = beam[b]
			rt_data.azim[hr,b] = azim_beg + b*azim_stp

			; linear power(param%
			rt_data.lagpower[hr,b,0:ngates-1] = histc(range_sort*1e-3,range_gate)

			; log power
			rt_data.power[hr,b,*] = 10D*ALOG10(rt_data.lagpower[hr,b,*])

			; Ground scatter flag
			gscatterinds = where(rt_data.power[hr,b,*] gt 0., cc)
			if cc gt 0 then $
				rt_data.gscatter[hr,b,gscatterinds] = 1b

			; ionospheric linear and log power and scatter flag
			if ~keyword_set(no_ionos) then begin
				ionoslagpower = histc(ionosrange_sort*1e-3,range_gate, weights=normweights[hr,b,*]/max(normweights[hr,*,*]))
				ionospower = 10D*ALOG10( ionoslagpower )
				ionosinds = where(ionospower gt 0.,cc)
				if cc gt 0 then begin
					rt_data.lagpower[hr,b,ionosinds] = ionoslagpower[ionosinds]
					rt_data.power[hr,b,ionosinds] = ionospower[ionosinds]
					rt_data.gscatter[hr,b,ionosinds] = 2b
				endif
			endif

			for ng=0, ngates-1 do begin
				gateinds = where(range_sort*1e-3 LT range_gate[ng+1] AND range_sort*1e-3 GE range_gate[ng])
				; elevation angle for GS
				rt_data.elevation[hr,b,ng] = ( gateinds[0] ge 0 and rt_data.gscatter[hr,b,ng] eq 1b ? MEAN(ranelv[hr,b,gateinds]) : -1000.)
				; reflection altitude for GS
				rt_data.altitude[hr,b,ng] = ( gateinds[0] ge 0 and rt_data.gscatter[hr,b,ng] eq 1b  ? MEAN(ranalt[hr,b,gateinds]) : -1000.)
				; virtual height for GS
				tempvalt = sqrt(P[ng]^2./4. + Re^2. + 2.*Re*P[ng]/2.*sin(rt_data.elevation[hr,b,ng]*!dtor)) - Re
				rt_data.valtitude[hr,b,ng] = (rt_data.gscatter[hr,b,ng] eq 1b ? tempvalt : -1000.)
				; ground range for GS
				rt_data.grange[hr,b,ng] = ( gateinds[0] ge 0 and rt_data.gscatter[hr,b,ng] eq 1b  ? MEAN(grndran[hr,b,gateinds]) : -1000.)
				; latitude and longitude
				rt_data.latitude[hr,b,ng] = ( gateinds[0] ge 0 and rt_data.gscatter[hr,b,ng] eq 1b  ? MEAN(ranlat[hr,b,gateinds]) : -1000.)
				rt_data.longitude[hr,b,ng] = ( gateinds[0] ge 0 and rt_data.gscatter[hr,b,ng] eq 1b  ? MEAN(ranlon[hr,b,gateinds]) : -1000.)


				if ~keyword_set(no_ionos) then begin
					gateindsionos = where(ionosrange_sort*1e-3 LT range_gate[ng+1] AND ionosrange_sort*1e-3 GE range_gate[ng])
					; elevation angle for IS
					rt_data.elevation[hr,b,ng] = ( gateindsionos[0] ge 0 and rt_data.gscatter[hr,b,ng] eq 2b ? TOTAL(normelv[hr,b,gateindsionos]*normweights[hr,b,gateindsionos])/TOTAL(normweights[hr,b,gateindsionos]) : rt_data.elevation[hr,b,ng])
					; reflection altitude for IS
					rt_data.altitude[hr,b,ng] = ( gateindsionos[0] ge 0 and rt_data.gscatter[hr,b,ng] eq 2b ? TOTAL(normalt[hr,b,gateindsionos]*normweights[hr,b,gateindsionos])/TOTAL(normweights[hr,b,gateindsionos]) : rt_data.altitude[hr,b,ng])
					; virtual height for IS
					tempvalt = sqrt(P[ng]^2. + Re^2. + 2.*Re*P[ng]*sin(rt_data.elevation[hr,b,ng]*!dtor)) - Re
					rt_data.valtitude[hr,b,ng] = (rt_data.gscatter[hr,b,ng] eq 2b ? tempvalt : rt_data.valtitude[hr,b,ng])
					; refraction index for ionos scatter (at reflection point)
					rt_data.nr[hr,b,ng] = ( gateindsionos[0] ge 0 and rt_data.gscatter[hr,b,ng] eq 2b ? TOTAL(normnrefract[hr,b,gateindsionos]*normweights[hr,b,gateindsionos])/TOTAL(normweights[hr,b,gateindsionos]) : -1000.)
					; aspect angle (at reflection point)
					rt_data.aspect[hr,b,ng] = ( gateindsionos[0] ge 0 and rt_data.gscatter[hr,b,ng] eq 2b ? abs(90.-(MEDIAN(aspect[hr,b,gateindsionos])+MEANABSDEV(aspect[hr,b,gateindsionos]))) : !VALUES.F_nan)
					; ground range for IS
					rt_data.grange[hr,b,ng] = ( gateindsionos[0] ge 0 and rt_data.gscatter[hr,b,ng] eq 2b  ? TOTAL(normgnd[hr,b,gateindsionos]*normweights[hr,b,gateindsionos])/TOTAL(normweights[hr,b,gateindsionos]) : rt_data.grange[hr,b,ng])
					; latitude and longitude for IS
					rt_data.latitude[hr,b,ng] = ( gateindsionos[0] ge 0 and rt_data.gscatter[hr,b,ng] eq 2b  ? TOTAL(ionolat[hr,b,gateindsionos]*normweights[hr,b,gateindsionos])/TOTAL(normweights[hr,b,gateindsionos]) : rt_data.latitude[hr,b,ng])
					rt_data.longitude[hr,b,ng] = ( gateindsionos[0] ge 0 and rt_data.gscatter[hr,b,ng] eq 2b  ? TOTAL(ionolon[hr,b,gateindsionos]*normweights[hr,b,gateindsionos])/TOTAL(normweights[hr,b,gateindsionos]) : rt_data.longitude[hr,b,ng])
				endif
			endfor

			if b eq 0 then begin
				; start and end times
				rt_info.sjul = sjul
				rt_info.fjul = fjul

				; Radar code name
				rt_info.name = radar

				; radar ID
				if ~keyword_set(geopos) then $
					rt_info.id = network[where(network.code[0] eq radar)].ID $
				else $
					rt_info.id = 0

				; Time format (UT or LT)
				rt_info.timez = tz

				; Number of range gates
				rt_info.ngates = ngates

				; Radar position
				rt_info.glat = radarsite.geolat
				rt_info.glon = radarsite.geolon

				; Elevation range
				rt_info.elev_beg = elev_beg
				rt_info.elev_end = elev_end
				rt_info.elev_stp = elev_stp

				; Binning parameter
				rt_info.bin = bin
			endif

			; End populate structures
			;*******************************************

		ENDFOR
		; End beam loop
		;***********************************************************

	ENDFOR
	; End time loop
	;***************************************************************************

	; Normalize power distributions
	if ~keyword_set(no_ionos) then begin
		ionosinds = where(rt_data.gscatter eq 2b)
		rt_data.power[ionosinds] = rt_data.power[ionosinds]/max(rt_data.power[ionosinds])
	endif
	ginds = where(rt_data.gscatter eq 1b, ccgnd)
	if ccgnd gt 0 then $
		rt_data.power[ginds] = rt_data.power[ginds]/max(rt_data.power[ginds])

	if ~keyword_set(silent) then $
		print, 'Time filling structures (s): ',(systime(/julian, /utc) - script_time)*86400.d

	; Clear memory a bit
	rantheta = 0
	grpran = 0
	ranhour = 0
	ranazim = 0
	ranelv = 0
	ranalt = 0
	ran = 0
	grndran = 0
	ranlat = 0
	ranlon = 0
	normtheta = 0
	normgrpran = 0
	normhour = 0
	normazim = 0
	normelv = 0
	normalt = 0
	normran = 0
	normgnd = 0
	normweights = 0
	normnrefract = 0
	ionolat = 0
	ionolon = 0
	aspect = 0
	edens = 0
	dip = 0

	; Save to file
	if ~keyword_set(no_rays) then $
		rt_read_rays2files, radar, dir=dirname, outdir=outdir
	if ~keyword_set(silent) then $
		print, 'Time creating ray files (s): ',(systime(/julian, /utc) - script_time)*86400.d
	rtWriteStruct, rt_data, rt_info, code=code, outdir=outdir
	if ~code and ~keyword_set(silent) then $
		prinfo, 'Error writting structure to file'

ENDIF ELSE begin
;**************************************************************************************
;**************************************************************************************
; Else read data from files
	if ~keyword_set(silent) then $
		print, 'Raytracing data already present. Reading from files.'

	; Read strcuture from file
	rtReadStruct, date[0], time, radar, rt_data, rt_info, code=code, outdir=outdir
	if ~code and ~keyword_set(silent) then $
		prinfo, 'Error reading structure from file'
endelse
;**************************************************************************************
;**************************************************************************************


; Computation time
if ~keyword_set(silent) then $
	print, 'Time elapsed (s): ',(systime(/julian, /utc) - script_time)*86400.d


END

