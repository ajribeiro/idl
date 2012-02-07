;+
; NAME:
; RT_MAKEFIT
;
; PURPOSE:
; This procedure creates a fit file based on the ray tracing output (ground scatter only).
; RT_RUN needs to be called prior to this function.
; The structure is the same as the one used for regular radar operations.
;
; CATEGORY:
; Input/Output
;
; CALLING SEQUENCE:
; RT_MAKEFIT
;
; INPUTS:
;
; KEYWORD PARAMETERS:
;
; COMMON BLOCKS:
; RT_DATA_BLK: The common block holding the currently loaded raytracing data and
; information about that data.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Written by Sebastien de Larquier, Sept. 2011
;	Last modified 09-2011
;-
PRO	rt_makefit

common rt_data_blk
common radarinfo


; directory where fit files are to be stored
dir = '/tmp/rtfit/'
if ~file_test(dir, /dir) then begin
	FILE_MKDIR, dir
endif


; Loops through times
nt = n_elements(rt_data.juls[*,0])
for it=0,nt-1 do begin

	; create blank fit and prm structures
	FitMAkeFitData, fit
	RadarMakeRadarPrm, prm


	; read date and time
	strdate = format_juldate(rt_data.juls[it,0], /short_date)
	strtime = format_juldate(rt_data.juls[it,0], /even_shorter_time)
	caldat, rt_data.juls[it,0], month, day, year, hour, minute


	; open fit file every 2 hours or if first run
	if (it eq 0) or (~(hour mod 2) and (minute eq 0)) then begin
		; close previous file if necessary
		if it gt 0 then $
			s = FitClose(out)
			
		; name fit file
		file = strdate + '.' + strtime + '.00.' + $
			rt_info.name + '.rt.fitex'
		prinfo, file
		output = dir + file

		; open fit file
		out = FitOpen(output,/write)
	endif

	; Loops through beams
	nb = n_elements(rt_data.beam[nt,*])
	for ib=0,nb-1 do begin
		;-----------------------------------------
		;- Fill structure: FIT
		;-----------------------------------------
		fit.revision.major = 2
		fit.revision.minor = 0
		fit.noise.sky = 1e-6
		fit.noise.lag0 = 1e-6
		fit.noise.vel = 1e-6
		fit.pwr0[0:rt_info.ngates-1] = rt_data.lagpower[it,ib,*]
		fit.nlag[0:4] = [6, 7, 17, 8, 5]
		scinds = where(rt_data.gscatter[it,ib,*] eq 1b or rt_data.ionoscatter[it,ib,*],scc)
		if scc gt 0 then $
			fit.qflg[scinds] = 1B
		fit.gflg[0:rt_info.ngates-1] = rt_data.gscatter[it,ib,*]
		fit.p_l[0:rt_info.ngates-1] = rt_data.power[it,ib,*]
		fit.x_qflg = fit.qflg
		fit.x_gflg = fit.gflg
		fit.elv[0:rt_info.ngates-1] = rt_data.elevation[it,ib,*]
		fit.elv_low = fit.elv
		fit.elv_high = fit.elv
		; End fill structure FIT
		;-----------------------------------------


		;-----------------------------------------
		;- Fill structure: PRM
		;-----------------------------------------
		prm.revision.major = 2
		prm.revision.minor = 0
		prm.origin.time = systime(/utc)
		prm.origin.command = 'rt_makefit'
		prm.stid = rt_info.id
		prm.time.yr = year
		prm.time.mo = month
		prm.time.dy = day
		prm.time.hr = hour
		prm.time.mt = minute
		prm.lagfr = 1200
		prm.smsep = 300
		prm.noise.search = 1e-6
		prm.bmnum = rt_data.beam[it,ib]
		prm.bmazm = rt_data.azim[it,ib]
		prm.rxrise = 100
		prm.intt.sc = 5
		prm.intt.us = 318181
		prm.txpl = 300
		prm.mpinc = 1500
		prm.mppul = 8
		prm.mplgs = 23
		prm.nrang = rt_info.ngates
		prm.frang = 180
		prm.rsep = 45
		prm.xcf = 1
		prm.tfreq = rt_data.tfreq[it,ib]*1e3
		prm.mxpwr = 1073741824
		prm.lvmax = 20000
		prm.pulse = [0,	14,	22,	24,	27,	31,	42,	43]
		prm.lag[0:23,0] = [0, 42, 22,	24,	27,	22,	24,	14,	22,	14,	31,	31,	14,	0, 27, 27, 14, 24, 24, 22, 22, 0, 0, 43]
		prm.lag[0:23,1] = [0, 43, 24, 27, 31, 27, 31, 22, 31, 24, 42, 43, 27, 14, 42, 43, 31, 42, 43, 42, 43, 22, 24, 43]
		; End fill structure PRM
		;-----------------------------------------


		; Write structure to file
		s = FitWrite(out, prm, fit)
		
	;	End beam loop
	endfor

	; Close file if last run
	if (it eq nt-1) then $
		s = FitClose(out)
	
; End time loop
endfor


END