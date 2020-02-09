function m3_params_tilt, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr
  nums = [909, 1009]
  if keyword_set(return_nums) then return, nums

  i909 = m3_wl_lookup(wl, nums[0])
  i1009 = m3_wl_lookup(wl, nums[1])
  out=float(tile[*,i909]) - tile[*,i1009]
  if zmask[0] ne -1 then out[zmask]=m3_params_get_badval()
  return, out
end
