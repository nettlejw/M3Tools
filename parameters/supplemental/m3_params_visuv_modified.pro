function m3_params_visuv_modified, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr
     ;
     nums = [580, 410]
     if keyword_set(return_nums) then return, nums
     ;
     i580 = m3_wl_lookup(wl, nums[0])
     i410 = m3_wl_lookup(wl, nums[1])
     ;
     R410 = float(tile[*,i410])
     R580 = float(tile[*,i580])
     ;
     ;  look for bad values
     ;
     if zmask[0] ne -1 then R410[zmask] = 1.0
     ;
     ; do the ratio, set bad values
     ;
     ratio = R580/R410
     if zmask[0] ne -1 then ratio[zmask] = m3_params_get_badval()
     ;
     return, ratio
end
