function mfiti, xx, pp
	return, pp[0] + pp[1]*cos(2.*!pi*xx/24. + pp[2])
end