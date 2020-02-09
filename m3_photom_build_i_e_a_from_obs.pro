function m3_photom_build_i_e_a_from_obs,obs
;
; given a ten-band set of m3 obs values,
; figure i, e and phase using the topography-referenced obs values
;
np=n_elements(obs)/10
;incidence=dblarr(np)
;exitance=dblarr(np)
;phase=dblarr(np)
if(np eq 1)then obs=reform(obs,1,10)
out_tile=dblarr(np,3)
;
; 0 To-Sun Azimuth (deg)
; 1 To-Sun Zenith (deg)
; 2 To-M3 Azimuth (deg)
; 3 To-M3 Zenith (deg)
; 4 Phase (deg)
; 5 To-Sun Path Length (au-mean),
; 6 To-M3 Path Length (m)
; 7 Facet Slope (deg)
; 8 Facet Aspect (deg)
; 9 Facet Cos(i) (unitless)
;
;
r2d=180/!dpi
d2r=!dpi/180
;
; build incidence
;
; cos(i)=cos(sun zen)*cos(slope)+sin(sun zen)*sin(slope)*cos(sun azi-aspect)
;
incidence=r2d*acos(cos(obs[*,1]*d2r)*cos(obs[*,7]*d2r)+sin(obs[*,1]*d2r)*sin(obs[*,7]*d2r)*cos((obs[*,0]-obs[*,8])*d2r))
;
; build exitance
;
; cos(e)=cos(m3 zen)*cos(slope)+sin(m3 zen)*sin(slope)*cos(m3 azi-aspect)
;
exitance=r2d*acos(cos(obs[*,3]*d2r)*cos(obs[*,7]*d2r)+sin(obs[*,3]*d2r)*sin(obs[*,7]*d2r)*cos((obs[*,2]-obs[*,8])*d2r))
;
; pull phase
;
phase=double(obs[*,4])
;
; handle single pixel case
;
;if(np eq 10)then begin
;  ;
;  obs=reform(obs)
;  incidence=incidence[0]
;  exitance=exitance[0]
;  phase=phase[0]
;  ;
;endif
out_tile[*,0]=incidence
out_tile[*,1]=exitance
out_tile[*,2]=phase
return, out_tile
;
end


