function jfit, xx, pp
	return, pp[0] + pp[1]*exp( -((xx-pp[2])/pp[3])^2 )*sin(2.*!pi*(xx-pp[2])/(3.*pp[3]) + pp[4])
end