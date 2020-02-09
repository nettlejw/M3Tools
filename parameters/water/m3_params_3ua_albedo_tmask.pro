function m3_params_3ua_albedo_tmask, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr
;
if keyword_set(return_nums) then return, m3_params_3ua_albedo(tile, wl, /return_nums)
;
;  get the albedo tile
;
avg_tile = m3_params_3ua_albedo(tile, wl)
;
;  handle masks
;
if n_elements(zmask) gt 0 then avg_tile[zmask] = 0.0
tmask = fix(m3_params_3ua_mask(tile, wl))
tbad = where(tmask eq 1, tcount)
if tcount gt 0 then avg_tile[tbad] =0.0
;
return, avg_tile
;
end
