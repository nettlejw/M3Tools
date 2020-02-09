function m3_params_uvvis, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr
     ;
     nums = [749, 419]
     if keyword_set(return_nums) then return, nums
     ;
     i749 = m3_wl_lookup(wl, nums[0])
     i419 = m3_wl_lookup(wl, nums[1])
     ;
     R419 = float(tile[*,i419])
     R749 = float(tile[*,i749])
     ;
     if zmask[0] ne -1 then R749[zmask] = 1.0
     ;
     ratio = R419/R749 
     if zmask[0] ne -1 then ratio[zmask] = m3_params_get_badval()
     ;
     return, ratio
end
