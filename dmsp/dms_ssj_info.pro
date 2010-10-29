;+ 
; NAME: 
; DMS_SSJ_INFO 
; 
; PURPOSE: 
; This procedure prints information about the DMSP SSJ/4 data loaded in the
; DMS_DATA_BLK common block, if any.
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE: 
; DMS_SSJ_INFO
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
pro dms_ssj_info

common dms_data_blk

print, '------'
print, '  F'+string(dms_ssj_info.sat,format='(I02)')+':'
if dms_ssj_info.nrecs eq 0L then begin
	print, '    No data loaded.'
	return
endif
print, '    First Datum:  ' + format_juldate(dms_ssj_info.sjul)
print, '    Last Datum:   ' + format_juldate(dms_ssj_info.fjul)
print, '    No. of Data:  ' + string(dms_ssj_info.nrecs,format='(I6)')
print, '------'
end
