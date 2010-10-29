;+ 
; NAME: 
; OMN_INFO 
; 
; PURPOSE: 
; This procedure prints information about the OMNI data loaded in the
; OMN_DATA_BLK common block, if any.
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE: 
; OMN_INFO
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
pro omn_info

common omn_data_blk

if omn_info.nrecs eq 0L then begin
	prinfo,' No data loaded.'
	return
endif

print, '------'
print, '  OMNI Data Set'
print, '  First Datum:  '+format_juldate(omn_info.sjul)
print, '  Last Datum:   '+format_juldate(omn_info.fjul)
print, '  No. Data: '+string(omn_info.nrecs,format='(I6)')
print, '------'

end
