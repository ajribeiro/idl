;+ 
; NAME: 
; ASI_INFO 
; 
; PURPOSE: 
; This procedure prints information about the All-Sky Images data loaded in the
; ASI_DATA_BLK common block, if any.
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE: 
; ASI_INFO
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
pro asi_info

common asi_data_blk

if asi_info.nrecs eq 0L then begin
	prinfo,' No data loaded.'
	return
endif

print, '------'
print, '  Station:      ' + strupcase(asi_info.site)
print, '  Geog. Pos.:   (' + string(asi_info.glat,format='(F5.1)')+', '+string(asi_info.glon,format='(F5.1)')+')'
print, '  Magn. Pos.:   (' + string(asi_info.mlat,format='(F5.1)')+', '+string(asi_info.mlon,format='(F5.1)')+')'
print, '  L-value:      ' + string(asi_info.l_value,format='(F3.1)')
print, '  First Datum:  ' + format_juldate(asi_info.sjul)
print, '  Last Datum:   ' + format_juldate(asi_info.fjul)
print, '  No. of Data:  ' + string(asi_info.nrecs,format='(I6)')
print, '------'

end
