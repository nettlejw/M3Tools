function m3_params_3ua_ibd3000, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr
;
r1 = 80
r2 = 83
if keyword_set(return_nums) then return, fix(wl[[r1,r2]])
;
;  get the continuum
;
cont = m3_params_3ua_projtherm(tile, wl, /line)
cr = tile/cont
;
;  subset the tile
;
sub_cr = cr[*,r1:r2]
;
; do the subtraction
;
ibd = total(1.0 - sub_cr,2)
;
;  handle masks
;
if n_elements(zmask) gt 0 then ibd[zmask]=0.0
tmask = fix(m3_params_3ua_mask(tile,wl))
tbad = where(tmask eq 1, tcount)
if tcount gt 0 then ibd[tbad]=0.0
;
return, ibd
;
end
