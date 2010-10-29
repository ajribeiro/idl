;+ 
; NAME: 
; THE_FGM_INFO 
; 
; PURPOSE: 
; This procedure prints information about the Themis FGM data loaded in the
; THE_DATA_BLK common block, if any.
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE: 
; THE_FGM_INFO
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
pro the_fgm_info

common the_data_blk
probes = strupcase(['a','b','c','d','e'])

for p=0, 4 do begin
	print, '------'
	print, 'Themis '+probes[p]
	if the_fgm_info[p].nrecs eq 0L then begin
		print,'  No data loaded.'
		continue
	endif
	print, '  First Datum: '+format_juldate(the_fgm_info[p].sjul)
	print, '  Last Datum:  '+format_juldate(the_fgm_info[p].fjul)
	print, '  No. of pts:  '+string(the_fgm_info[p].nrecs,format='(I6)')
	print, '  Smpl interv: '+string((the_fgm_info[p].fjul-the_fgm_info[p].sjul)*86400.d/double(the_fgm_info[p].nrecs),format='(F5.2)')
endfor
print, '------'

end
