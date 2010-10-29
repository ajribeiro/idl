;+
; NAME: 
; OVERLAY_MP
;
; PURPOSE: 
; This procedure plots a model magnetopause position on an orbit panel, 
; like those produces by ORB_PLOT_PANEL. The model used is described
; in Shue et al., 1997.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:  
; OVERLAY_MP
;
; KEYWORD PARAMETERS:
; BZ: Set this keyword to the solar wind magnetic field bz component used to parametrize
; the bow shock position.
;
; PDYN: Set this keyword to the solar wind dynamic pressure used to parametrize
; the bow shock position.
;
; XY: Set this keyword to plot the bow shock in the XY plane.
;
; XZ: Set this keyword to plot the bow shock in the XZ plane.
;
; YZ: Set this keyword to plot the bow shock in the YZ plane.
;
; LINECOLOR: Set this keyword to set the line color used to plot the bow shock.
;
; LINESTYLE: Set this keyword to set the line style used to plot the bow shock.
;
; LINETHICK: Set this keyword to set the line thickness used to plot the bow shock.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Written by Lasse Clausen, Dec, 4 2009
;-
pro overlay_mp, bz=bz, pdyn=pdyn, $
	xy=xy, xz=xz, yz=yz, $
	linecolor=linecolor, linestyle=linestyle, linethick=linethick

if ~keyword_set(xy) and ~keyword_set(yz) and ~keyword_set(xz) then begin
	if ~keyword_set(silent) then $
		prinfo, 'XY, XZ and YZ not set, using XZ.'
	xz = 1
endif

if n_elements(linecolor) eq 0 then $
	linecolor = get_foreground()

if n_elements(linestyle) eq 0 then $
	linestyle = 0

if n_elements(linethick) eq 0 then $
	linethick = 1

if n_elements(bz) eq 0 then $
	bz = 0.

if n_elements(pdyn) eq 0 then $
	pdyn = 2.

;F REFERENCES:	"A new functional form to study the solar wind control of the 
;F		magnetopause size and shape", Shue et al., JGR, 102, 1997, p9497.		
;F
;F INPUTS:	theta:	angle between Sun-Earth direction and r 
;F			(r = radial distance to magnetopause at theta)
;F		bz: 	the z-component of the IMF (nT)
;F		p:	solar wind dynamic pressure (nPa)

;function tail_flaring,bz,p
alpha = (0.58-0.010*bz)*(1.+0.010*pdyn)
;end

;function mp_nose,bz,p
if bz ge 0. then begin
	r0 = (11.4+0.013*bz)*(pdyn)^(-1.0/6.6)
endif else begin
	r0 = (11.4+0.14*bz)*(pdyn)^(-1.0/6.6)
endelse
;end

; Now do the  magnetopause. Frist the xy and xz frames. In the Shue et al 
; model the magnetosphere is cylindrically symmetric about the x axis	
if keyword_set(xy) or keyword_set(xz) then begin
	theta = (findgen(351) - 175.)*!dtor
	rad = r0*(2./(1.+cos(theta)))^(alpha)
	xmppos = rad*cos(theta)
	ymppos = rad*sin(theta)
endif
; Now for the yz frame	
if keyword_set(yz) then begin
	theta = !pi/2.
	phi = 2.*!pi*findgen(361)/360.
	rad = r0*(2./(1.+cos(theta)))^(alpha)
	xmppos = rad*cos(phi)
	ymppos = rad*sin(phi)
endif

; Plot the output		
oplot, xmppos, ymppos, $
	color=linecolor, linestyle=linestyle, thick=linethick, $
	noclip=0

; put a little legend on the plot to indicate input parameters
xpos = !x.crange[1] + .06*(!x.crange[1]-!x.crange[0])
ypos = !y.crange[0]
xyouts, xpos, ypos, orientation=90., $
	textoidl('B_z='+string(bz, format='(F03.1)')+'nT, pdyn='+string(pdyn, format='(F03.1)')+'nPa') + $
	' Shue et al., 1997', $
	/data, charsize=.5

end