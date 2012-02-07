function	get_re, lat

Rpol = 6356.7523142
Requ = 6378.137

glat = lat*!PI/180.

Re = SQRT( ( (Requ^2*cos(glat))^2 + (Rpol^2*sin(glat))^2 ) / $
	   ( (Requ*cos(glat))^2 + (Rpol*sin(glat))^2 ) )

return, Re

end