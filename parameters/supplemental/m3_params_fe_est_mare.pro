function m3_params_fe_est_mare, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr

  nums = [749, 949]
  if keyword_set(return_nums) then return, nums

  i749 = m3_wl_lookup(wl, nums[0])
  i949 = m3_wl_lookup(wl, nums[1])
  
  r749 = float(tile[*,i749])

  a = float(r749) * 0.9834
  
  if zmask[0] ne -1 then r749[zmask] = 1.0
  b = float(tile[*,i949])/r749 * 0.1813

  out = -137.97 * (a + b) + 57.46
  if zmask[0] ne -1 then out[zmask] = m3_params_get_badval()
  return, out
end
