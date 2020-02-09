function m3_params_r540, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr

  nums = [539]
  if keyword_set(return_nums) then return, nums

  i539 = m3_wl_lookup(wl, nums[0])
  r539 = float(tile[*,i539])
  if zmask[0] ne -1 then r539[zmask] = m3_params_get_badval()
  return, r539
end
