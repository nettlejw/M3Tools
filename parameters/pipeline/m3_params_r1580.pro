function m3_params_r1580, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr

  nums = [1579]
  if keyword_set(return_nums) then return, nums

  i1579 = m3_wl_lookup(wl, nums[0])
  out = float(tile[*,i1579])
  if zmask[0] ne -1 then out[zmask] = m3_params_get_badval()
  
  return, out 

end
