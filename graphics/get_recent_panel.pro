pro get_recent_panel, xmaps, ymaps, xmap, ymap

common recent_panel

if n_elements(rxmaps) eq 0 then $
	rxmaps = 1
if n_elements(rymaps) eq 0 then $
	rymaps = 1
if n_elements(rxmap) eq 0 then $
	rxmap = 0
if n_elements(rymap) eq 0 then $
	rymap = 0

xmaps = rxmaps
ymaps = rymaps
xmap = rxmap
ymap = rymap

end