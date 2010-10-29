pro the_calc_footprint, date=date, time=time, long=long, $
	param=param, model=model

common the_data_blk

if ~keyword_set(date) then begin
	prinfo, 'Must give date.'
	return
endif

if n_elements(time) eq 0 then $
	time = [0,2400]
sfjul, date, time, sjul, fjul, long=long

zero_epoch = julday(1,1,1970,0)

timerange, ([sjul,fjul]-zero_epoch)*86400.d
thm_load_state, datatype='pos', coord='gsm', probe='a'
thm_load_state, datatype='pos', coord='gsm', probe='b'
thm_load_state, datatype='pos', coord='gsm', probe='c'
thm_load_state, datatype='pos', coord='gsm', probe='d'
thm_load_state, datatype='pos', coord='gsm', probe='e'

thm_load



end