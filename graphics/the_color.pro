;+ 
; NAME: 
; THE_COLOR 
; 
; PURPOSE: 
; This function returns the color index for a given Themis spacecraft.
; ThA (P5) is red, ThB (P1) is green, ThC (P2) is greenblue, ThD (P3) is darkblue and ThE (P4) is orange.
;
; For this procedure to work properly, the DaViT standard color table
; must be loaded (use RAD_LOAD_COLORTABLE for that).
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; Result = THE_COLOR(Probe)
;
; INPUTS:
; Probe: The number fo the spacecraft. The numbering is different from the
; standard Themis numbering, here 
; ThA is 0, 
; ThB is 1, 
; ThC is 2, 
; ThD is 3, and
; ThE is 4.
; you can also give the probe letter, i.e. 'a' or 'b'
;
; OUTPUTS:
; The color index of the given spacecraft is returned.
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
function the_color, probe

_probe = byte(probe)
if max(_probe) gt 5 then $
	_probe -= (byte('a'))[0]

npr = n_elements(_probe)
inds = intarr(npr)
tmp = where(_probe eq 0, cc)
if cc gt 0L then $
	inds[tmp] = 250
tmp = where(_probe eq 1, cc)
if cc gt 0L then $
	inds[tmp] = 100
tmp = where(_probe eq 2, cc)
if cc gt 0L then $
	inds[tmp] = 60
tmp = where(_probe eq 3, cc)
if cc gt 0L then $
	inds[tmp] = 20
tmp = where(_probe eq 4, cc)
if cc gt 0L then $
	inds[tmp] = 180

return, inds

end
