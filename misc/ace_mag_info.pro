;+ 
; NAME: 
; ACE_MAG_INFO 
; 
; PURPOSE: 
; This procedure prints information about the ACE MAG data loaded in the
; ACE_DATA_BLK common block, if any.
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE: 
; ACE_MAG_INFO
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
pro ace_mag_info

common ace_data_blk

print, '------'
print, ' ACE MAG:'
if ace_mag_info.nrecs eq 0L then begin
	print, '    No data loaded.'
	return
endif

print, '    First Datum:  ' + format_juldate(ace_mag_info.sjul)
print, '    Last Datum:   ' + format_juldate(ace_mag_info.fjul)
print, '    No. of Data:  ' + string(ace_mag_info.nrecs,format='(I6)')

print, '------'
end
