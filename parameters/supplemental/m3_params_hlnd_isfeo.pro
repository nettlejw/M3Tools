function m3_params_hlnd_isfeo, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr

  nums = [749, 889]
  if keyword_set(return_nums) then return, nums

  i749 = m3_wl_lookup(wl, nums[0])
  i889 = m3_wl_lookup(wl, nums[1])

  R749 = float(tile[*, i749])
  R889 = float(tile[*, i889])

  if zmask[0] ne -1 then R889[zmask] = 1.0

  eterm = (1.82 - (R749/R889))/0.057
  out= exp(eterm)
  if zmask[0] ne -1 then out[zmask] = m3_params_get_badval()
  return, out
end
