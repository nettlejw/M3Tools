function m3_params_ibd1000, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr

 nums = (indgen(27) * 20) + 789
 if keyword_set(return_nums) then return, nums

 ;grab the continuum for this tile
 cont = m3_params_1um_slope(tile, wl, /line, zmask=zmask)

 ;figure the subscripts to subset with
 pos = intarr(n_elements(nums))
 for i = 0, n_elements(nums) - 1 do pos[i] = m3_wl_lookup(wl, nums[i])

 ;subset both sets of data
 refl = float(tile[*,pos])
 cont = float(cont[*,pos])
 
 ;handle zmask
 if zmask[0] ne -1 then cont[zmask,*] = 1.0
 
 ;calculate ibd
 bd = 1.0 - (refl/cont)
 ibd = total(bd,2)
 
 ;handle zmask
 if zmask[0] ne -1 then ibd[zmask] = m3_params_get_badval()

 return, ibd

end
