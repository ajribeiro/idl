function define_imfpanel, inpos, gap=gap, size=size, low=low

if n_params() lt 1 then begin
	prinfo, 'Must give Inpos.'
	return, [-1., -1., -1., -1.]
endif

if ~keyword_set(gap) then $
	gap = (.1 + (!d.name eq 'PS' ? .05 : .0 ) )*(inpos[2]-inpos[0])

if ~keyword_set(size) then $
	size = .3*(inpos[2]-inpos[0])

aspect_ratio = float(!D.Y_SIZE)/float(!D.X_SIZE)
dd = get_format(landscape=landscape)
if landscape then begin
	width = size
	height = size/aspect_ratio
endif else begin
	width = size/aspect_ratio
	height = size
endelse

if keyword_set(low) then begin
	ind = 1
	pos = [inpos[2]+gap, inpos[ind], $
		inpos[2]+gap+width, inpos[ind]+height]
endif else begin
	ind = 3
	pos = [inpos[2]+gap, inpos[ind]-height, $
		inpos[2]+gap+width, inpos[ind]]
endelse

return, pos

end