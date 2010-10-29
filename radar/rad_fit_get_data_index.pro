;+ 
; NAME: 
; RAD_FIT_GET_DATA_INDEX
; 
; PURPOSE: 
; This function returns the current index number of radar fitACF data.
; Davit is able to have data from 5 different radars in memory at the same
; time. The data index determines at which location in memory the data resides.
; 
; CATEGORY:  
; Radar
; 
; CALLING SEQUENCE: 
; Result = RAD_FIT_GET_DATA_INDEX()
;
; KEYWORD PARAMETERS:
; NEXT: Set this keyword to get the next available data index, instead of the
; latest used one. If all 5 spaces are occupied, it prints a warning that you
; are about to overwrite data and the returns the first index (0).
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding radar data.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 24 2009
;-
function rad_fit_get_data_index, next=next

common rad_data_blk

if keyword_set(next) then begin
	if rad_data_index+1 gt rad_max_radars-1 then begin
		prinfo, 'Reached maximum radar number. Overwriting.'
		rad_data_index = 0
	endif else $
		rad_data_index += 1
endif

return, rad_data_index

end