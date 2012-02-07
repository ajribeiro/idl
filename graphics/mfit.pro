function mfit, xx, pp
	ret = pp[0]

	for o=0., floor((n_elements(pp)-1.)/2.-1.) do $
		ret += pp[2*o+1]*cos((o+1.)*(2.*!pi*xx/24. + pp[2*o+2]))

	return, ret
end