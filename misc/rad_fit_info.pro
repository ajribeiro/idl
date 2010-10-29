;+ 
; NAME: 
; RAD_FIT_INFO 
; 
; PURPOSE: 
; This procedure prints information about the radar data loaded in the
; RAD_DATA_BLK common block, if any.
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE: 
; RAD_FIT_INFO
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
pro rad_fit_info

common rad_data_blk

for i=0, rad_max_radars-1 do begin
	print, '------'
	print, '      Data Index '+string(i,format='(I1)')
	print, '------'

	if (*rad_fit_info[i]).nrecs eq 0L then begin
		print,'  No data loaded.'
		continue
	endif

	print, '  Radar:        ' + (*rad_fit_info[i]).name + $
		' (id: ' + string((*rad_fit_info[i]).id,format='(I2)') + ', ' + $
		' code: ' + (*rad_fit_info[i]).code +')'
	print, '  Max No. of Beams: '+string((*rad_fit_info[i]).nbeams,format='(I6)')
	print, '  Max No. of Gates: '+string((*rad_fit_info[i]).ngates,format='(I6)')
	print, '  First Datum:  '+format_juldate((*rad_fit_info[i]).sjul)
	print, '  Last Datum:   '+format_juldate((*rad_fit_info[i]).fjul)
	print, '  No. of Beams: '+string((*rad_fit_info[i]).nrecs,format='(I6)')
	print, '  Scan IDs:     ' + strjoin(string((*rad_fit_info[i]).scan_ids,format='(I6)'),', ')
	print, '  Channels:     ' + strjoin(string((*rad_fit_info[i]).channels,format='(I1)'),', ')
	print, '  No. of Scans: '+string((*rad_fit_info[i]).nscans,format='(I6)')
	print, '------'
endfor

end
