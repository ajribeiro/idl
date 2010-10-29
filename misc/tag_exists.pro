;+ 
; NAME: 
; TAG_EXISTS 
; 
; PURPOSE: 
; This function returns true if a tag with name Tag_name is found in the
; given structure Structure, false otherwise.
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE: 
; Result = TAG_EXISTS(Structure, Tag_name)
; 
; INPUTS: 
; Structure: The structure in which to look for Tag_name.
;
; Tag_name: The name of the tag to look for as a string.
; 
; OUTPUTS: 
; This function returns true if the Tag_name is found in Structure, false
; otherwise.
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 24 2009
;-
function tag_exists, structure, tag_name

tnames = tag_names(structure)
for i=0, n_elements(tnames)-1 do begin
	if strcmp(tnames[i], tag_name, /fold) then $
		return, !true
endfor

return, !false

end
