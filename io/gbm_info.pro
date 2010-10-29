;+ 
; NAME: 
; GBM_INFO 
; 
; PURPOSE: 
; This procedure prints information about the GBM data loaded in the
; GBM_DATA_BLK common block, if any.
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE: 
; GBM_INFO
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
pro gbm_info

common gbm_data_blk

if gbm_info.nrecs eq 0L then begin
	prinfo,' No data loaded.'
	return
endif

print, '------'
print, '  Station:      ' + strupcase(gbm_info.station)
print, '  Geog. Pos.:   (' + string(gbm_info.glat,format='(F5.1)')+', '+string(gbm_info.glon,format='(F5.1)')+')'
print, '  Magn. Pos.:   (' + string(gbm_info.mlat,format='(F5.1)')+', '+string(gbm_info.mlon,format='(F5.1)')+')'
print, '  L-value:      ' + string(gbm_info.l_value,format='(F3.1)')
print, '  First Datum:  ' + format_juldate(gbm_info.sjul)
print, '  Last Datum:   ' + format_juldate(gbm_info.fjul)
print, '  No. of Data:  ' + string(gbm_info.nrecs,format='(I6)')
print, '------'

end
