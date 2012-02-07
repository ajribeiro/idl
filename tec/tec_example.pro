

date=20111025
time=0201
coords='magn'

set_colorsteps,240
scale=[0,40]

tec_read,date
tec_median_filter,1,2,slat=10,threshold=0.2,date=date,time=time

; map_plot_panel,2,1,0,0,/no_fill,coords=coords,xrange=[-50,50],yrange=[-45,45]
map_plot_panel,/no_fill,coords=coords,xrange=[-50,30],yrange=[-50,10],/no_label

rad_load_colortable,/bw
overlay_tec_median,date=date,time=time,scale=scale
rad_load_colortable,/aj
overlay_coast,coords=coords,/no_fill
map_overlay_grid

overlay_fov,name='wal',date=date,time=time,coords=coords,/no_fill,/annotate
overlay_fov,name='bks',date=date,time=time,coords=coords,/no_fill,/annotate
overlay_fov,name='fhe',date=date,time=time,coords=coords,/no_fill,/annotate
overlay_fov,name='fhw',date=date,time=time,coords=coords,/no_fill,/annotate
overlay_fov,name='cve',date=date,time=time,coords=coords,/no_fill,/annotate
overlay_fov,name='cvw',date=date,time=time,coords=coords,/no_fill,/annotate

overlay_fov,name='hok',date=date,time=time,coords=coords,/no_fill,/annotate

end