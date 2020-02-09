function m3_params_fe_est, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr

  nums = [749, 949]
  if keyword_set(return_nums) then return, nums

  X0Fe = 0.08
  y0Fe = 1.19

  i749 = m3_wl_lookup(wl, nums[0])
  i949 = m3_wl_lookup(wl, nums[1])
  
  r749 = float(tile[*,i749])
  if zmask[0] ne -1 then r749[zmask] = 1.0

  a = float(tile[*,i949])/r749 - Y0Fe
  b = float(tile[*,i749]) - x0Fe
  theta = -atan(a,b)
  out=(17.427 * theta) - 7.565
  
  if zmask[0] ne -1 then out[zmask] = m3_params_get_badval()
  return, out
end
