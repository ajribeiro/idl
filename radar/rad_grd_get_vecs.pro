;+ 
; NAME: 
; RAD_GRD_GET_VECS
;
; PURPOSE: 
; This procedure returns the magnitude and azimuth of the actual line-of-sight velocities that were
; measured by the radars.
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE:
; Result = RAD_GRD_GET_VECS(Int_hemi, Index)
;
; INPUTS:
; Int_hemi: An integer indicating the hemisphere, 0 for north, 1 for south.
;
; Index: The index number of the coefficients to calculate.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding the currently loaded radar data and 
; information about that data.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Based on Adrian Grocott's CALC_LOSVECS and others.
; Written by Lasse Clausen, Dec, 22 2009
;-
function rad_grd_get_vecs, int_hemi, index

common rad_data_blk

; get "real" velocity data
real_vec = (*(*rad_grd_data[int_hemi]).gvecs[index])
real_pos = transpose([[real_vec[*].mlat], [real_vec[*].mlon]])
real  = {pos:real_pos,  vectors:transpose([[real_vec[*].vel.median], [real_vec[*].azm]])}

return, {real:real}

end