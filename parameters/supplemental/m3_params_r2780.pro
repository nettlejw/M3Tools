function m3_params_r2780, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr

  nums = [2778]
  if keyword_set(return_nums) then return, nums
  
  r2778=float(tile[*, m3_wl_lookup(wl, nums[0])])
  if zmask[0] ne -1 then r2778[zmask]=m3_params_get_badval()
  return, r2778

end
