;+ 
; NAME: 
; CLU_COLOR 
; 
; PURPOSE: 
; This function returns the color index for a given Cluster spacecraft.
; S/c 1 is black, 2 red, 3 green and 4 blue.
;
; Fior this procedure to work properly, the DaViT standard color table
; must be loaded (use RAD_LOAD_COLORTABLE for that).
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; Result = CLU_COLOR(Sc)
;
; INPUTS:
; Sc: The number fo the spacecraft.
;
; OUTPUTS:
; The color index of the given spacecraft is returned.
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
function clu_color, sc


if sc eq 1 then return, get_foreground()
if sc eq 2 then return, 250
if sc eq 3 then return, 100
if sc eq 4 then return, 4

return, 'Deine mudda!'

end
