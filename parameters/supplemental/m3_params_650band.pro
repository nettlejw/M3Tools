function m3_params_650band, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr

  nums = [650, 450, 850]
  if keyword_set(return_nums) then return, nums

  i650 = m3_wl_lookup(wl, nums[0])
  i450 = m3_wl_lookup(wl, nums[1])
  i850 = m3_wl_lookup(wl, nums[2])

  R650 = float(tile[*, i650])
  R450 = float(tile[*, i450])
  R850 = float(tile[*, i850])

  den = (R450 + R850)/2
  out = 1 - (R650/den)
  if zmask[0] ne -1 then out[zmask] = m3_params_get_badval()
  return, out

end
