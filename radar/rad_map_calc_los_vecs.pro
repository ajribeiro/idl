;+ 
; NAME: 
; RAD_MAP_CALC_LOS_VECS
;
; PURPOSE: 
; This procedure returns the magnitude and azimuth of the actual line-of-sight velocities that were
; measured by the radars and went into the fitting.
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE:
; Result = RAD_MAP_CALC_LOS_VECS(Int_hemi, Index)
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
function rad_map_calc_los_vecs, int_hemi, index

common rad_data_blk

; get "real" velocity data
real_vec = (*(*rad_map_data[int_hemi]).gvecs[index])
real_pos = transpose([[real_vec[*].mlat], [real_vec[*].mlon]])

; get model velocity data
model_vec = (*(*rad_map_data[int_hemi]).mvecs[index])
model_pos = transpose([[model_vec[*].mlat], [model_vec[*].mlon]])

real  = {pos:real_pos,  vectors:transpose([[real_vec[*].vel.median], [real_vec[*].azm]])}
model = {pos:model_pos, vectors:transpose([[model_vec[*].vel.median], [model_vec[*].azm]])}

return, {real:real, model:model}

end