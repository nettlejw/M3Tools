function m3_params_3ua_projtherm, tile, wl, return_nums=return_nums, slope=slope, line=line, zmask=zmask
compile_opt strictarr
;
;  
r1c1=48
r1c2=52
;
r2c1=67
r2c2=71
;
r3c1=82
r3c2=83
;
if keyword_set(return_nums) then return, fix(wl[r1c1,r1c2,r2c1,r2c2])
;
; get average refl
;
r1 = total(tile[*,r1c1:r1c2],2)/float(r1c2-r1c1+1)
r2 = total(tile[*,r2c1:r2c2],2)/float(r2c2-r2c1+1)
;
; get average wavelengths for r1 and r2
;
w1 = (wl[r1c1] + wl[r1c2])/2.0
w2 = (wl[r2c1] + wl[r2c2])/2.0
w3 = (wl[r3c1] + wl[r3c2])/2.0
;
;  compute slope
;
m=(r2-r1)/(w2-w1)
if keyword_set(slope) then return, m
;
; project reflectance to last channel 
;
r3p = r2 + (w3-w2)*m
;
;  handle errors/masks
;
if n_elements(zmask) gt 0 then r2[zmask] = 1.0
r2bad = where(r2 lt 0.0005, r2count)
if r2count gt 0 then r2[r2bad] = 1.0
;
ratio = r3p/r2
;
if n_elements(zmask) gt 0 then ratio[zmask] = m3_params_get_badval()
if r2count gt 0 then r2[r2bad] = m3_params_get_badval()

if ~keyword_set(line) then return, ratio
;
s = size(tile, /dimensions)
ns  = s[0]
cont = fltarr(s)
;
;  interpolate continuum curve for each reflectance curve
;
for i = 0,ns - 1 do begin
  refl = reform(tile[i,*])
  knowny = [r2[i], r1[i]]
  knownx = [w2, w1]
  cont[i,*] = interpol(knowny, knownx, wl)
endfor
return, cont
;
end
