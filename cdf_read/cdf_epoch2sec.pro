function cdf_epoch2sec, cdf_epochs

nn = n_elements(cdf_epochs)
ret = make_array(nn, /double)

months=[0,31,59,90,120,151,181,212,243,273,304,334]

for i=0L, nn-1L do begin
    cdf_epoch, cdf_epochs[i], yr, mt, dy, hr, mn, sc, ml, /break
;    print, yr, mt, dy, hr, mn, sc, ml
    ret[i] = (months(mt-1)*86400.0d)+((dy-1)*86400.0d)+(hr*3600.0d)+(mn*60.0d)+double(sc)+double(ml)/1000.d
    IF yr mod 4.0 EQ 0.0 AND mt GE 3.0 THEN ret[i]=ret[i]+86400.0d
endfor

return, ret
end
