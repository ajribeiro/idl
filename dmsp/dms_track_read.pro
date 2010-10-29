pro dms_track_read, date, sat, time=time, long=long, $
	silent=silent, force=force, $
	filename=filename, filedate=filedate, filesat=filesat

; check if parameters are given
if n_params() lt 2 then begin
	prinfo, 'Must give date and satellite number.'
	return
endif

dms_ssj_read, date, sat, time=time, long=long, $
	silent=silent, force=force, $
	filename=filename, filedate=filedate, filesat=filesat

end