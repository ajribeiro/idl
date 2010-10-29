pro rad_fit_plot_rti_overview, date=date, time=time, long=long, $
	beam=beam, channel=channel, scan_id=scan_id, yrange=yrange

common rad_data_blk

; get index for current data
data_index = rad_fit_get_data_index()
if data_index eq -1 then $
	return

if (*rad_fit_info[data_index]).nrecs eq 0L then begin
	if ~keyword_set(silent) then begin
		prinfo, 'No data in index '+string(data_index)
		rad_fit_info
	endif
	return
endif

rad_fit_plot_rti, date=date, time=time, long=long, $
	beam=beam, channel=channel, scan_id=scan_id, yrange=yrange, $
	param=['power', 'velocity', 'width'], scale=[[0,30],[-100,100],[0,50]]

end