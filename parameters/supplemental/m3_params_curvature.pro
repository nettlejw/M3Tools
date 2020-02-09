function m3_params_curvature, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr

  nums = [749, 909, 1009]
  if keyword_set(return_nums) then return, nums

  i749 = m3_wl_lookup(wl, nums[0])
  i909 = m3_wl_lookup(wl, nums[1])
  i1009 = m3_wl_lookup(wl, nums[2])
  
  R909 = float(tile[*,i909])
  if zmask[0] ne -1 then R909[zmask] = 1.0

  out = (float(tile[*,i749]) + tile[*, i1009]) /(2* R909)
  if zmask[0] ne -1 then out[zmask] = m3_params_get_badval()
  return, out
end
