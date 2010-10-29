;+ 
; NAME: 
; DST_INFO 
; 
; PURPOSE: 
; This procedure prints information about the Dst index data loaded in the
; DST_DATA_BLK common block, if any.
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE: 
; DST_INFO
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
pro dst_info

common dst_data_blk

if dst_info.nrecs eq 0L then begin
	prinfo,' No data loaded.'
	return
endif

print, '------'
print, '  Dst Index'
print, '  First Datum:  '+format_juldate(dst_info.sjul)
print, '  Last Datum:   '+format_juldate(dst_info.fjul)
print, '  No. Data: '+string(dst_info.nrecs,format='(I6)')
print, '------'

end
