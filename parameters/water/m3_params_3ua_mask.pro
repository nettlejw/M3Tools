function m3_params_3ua_mask, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr
;
;  if asked to return nums, just return last two channels
;
r2c1=67
r2c2=71
;
r3c1=82
r3c2=83
if keyword_set(return_nums) then return, wl[[r3c1,r3c2]]
;
;  get the projected reflectance
;
proj_ratio = m3_params_3ua_projtherm(tile, wl)
;
;  get average actual reflectance 
;
real_therm = total(tile[*,r3c1:r3c2],2)/float(r3c2-r3c1+1)
r2 = total(tile[*,r2c1:r2c2],2)/float(r2c2-r2c1+1)
real_ratio = real_therm/r2
mask = real_therm * 0.0
;
;  if real refl is greater than projected, thermal removal would be performed.
;  1=thermal should be applied
;  0=thermal should not be applied
;
dotherm = where(real_ratio gt proj_ratio, count)
if count gt 0 then mask[dotherm] = 1.0
;
;  don't need to handle zmask b/c those spectra should already be 0.0
;
return, mask
;
end
