;+ 
; NAME: 
; RAD_GRD_INFO 
; 
; PURPOSE: 
; This procedure prints information about the grid data loaded in the
; RAD_DATA_BLK common block, if any.
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE: 
; RAD_GRD_INFO
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
pro rad_grd_info

common rad_data_blk


for i=0, 1 do begin

	print, '------'
	print, (i eq 0 ? 'North' : 'South')+'ern Hemishere'
	print, '------'

	if rad_grd_info[i].nrecs eq 0L then begin
		prinfo,' No data loaded.'
		continue
	endif

	print, '  Format:        '+( rad_grd_info[i].grdex ? 'grdEX' : 'APL grd' )
	print, '  First Datum:   '+format_juldate(rad_grd_info[i].sjul)
	print, '  Last Datum:    '+format_juldate(rad_grd_info[i].fjul)
	print, '  No. of Maps:   '+string(rad_grd_info[i].nrecs,format='(I6)')
	print, '  No. of Vecs:   '+strtrim(string(long(total((*rad_grd_data[i]).vcnum))),2)
	print, '  Avg. Vecs/Map: '+strtrim(string(total((*rad_grd_data[i]).vcnum)/rad_grd_info[i].nrecs,format='(F6.1)'),2)

endfor

print, '------'

end
