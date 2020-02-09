function m3_params_show_zmask, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr
;
if keyword_set(return_nums) then return, 1000
;
s=size(tile,/dimensions)
out_tile=fltarr(s[0])+1.0
if zmask[0] ne -1 then out_tile[zmask] = 0.0
return, out_tile
;
end
