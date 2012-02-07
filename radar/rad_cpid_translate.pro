function rad_cpid_translate, cpid

common rad_data_blk

nn = n_elements(cpid)
names = strarr(nn)

for i=0L, nn-1L do begin
	ind = where(cpid_structure.cpids eq abs(cpid[i]), cc)
	if cc eq 1 then $
		names[i] = cpid_structure.names[ind] $
	else $
		names[i] = ''
endfor

if nn eq 1 then $
	return, names[0] $
else $
	return, names

end