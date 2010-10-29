function get_charsize, xmaps, ymaps

; check input
if n_params() lt 2 then begin
	prinfo, 'Must give Xmaps, Ymaps.'
	return, -1.
endif

if !d.name eq 'X' then $
	fac = 2. $
else $
	fac = 1.

return, fac*( sqrt(1./(xmaps>ymaps)) > get_mincharsize() )

end
