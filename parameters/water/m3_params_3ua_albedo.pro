function m3_params_3ua_albedo, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr
;
r1=80
r2=83
if keyword_set(return_nums) then return, fix(wl[[r1,r2]])
;
;  subset_tile
;
sub_tile = tile[*,r1:r2]
;
;  calculate average
;
avg_tile = total(sub_tile,2)/float(r2-r1+1)
;
;  handle masks
;
if n_elements(zmask) gt 0 then avg_tile[zmask] = 0.0
;tmask = fix(m3_params_3ua_mask(tile, wl))
;tbad = where(tmask eq 1, tcount)
;if tcount gt 0 then avg_tile[tbad] =0.0
;
return, avg_tile
;
end
