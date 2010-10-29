;+ 
; NAME: 
; CLU_FGM_INFO 
; 
; PURPOSE: 
; This procedure prints information about the Cluster FGM data loaded in the
; CLU_DATA_BLK common block, if any.
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE: 
; CLU_FGM_INFO
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
pro clu_fgm_info

common clu_data_blk

print, '------'
for i=0, 3 do begin
	print, '  S/C '+string(i+1,format='(I1)')+':'
	if clu_fgm_info[i].nrecs eq 0L then begin
		print, '    No data loaded.'
		continue
	endif
	print, '    First Datum:  ' + format_juldate(clu_fgm_info[i].sjul)
	print, '    Last Datum:   ' + format_juldate(clu_fgm_info[i].fjul)
	print, '    No. of Data:  ' + string(clu_fgm_info[i].nrecs,format='(I6)')
endfor
print, '------'
end
