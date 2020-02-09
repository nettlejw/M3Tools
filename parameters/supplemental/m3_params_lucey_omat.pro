function m3_params_lucey_omat, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr

  nums = [749, 949]
  if keyword_set(return_nums) then return, nums

  ;x0 = 0.08 for Clementine; 0.01 for Adams
  ;y0 = 1.19 for Clementine; 1.26 for Adams

  x0 = 0.08
  y0 = 1.19

  i749 = m3_wl_lookup(wl, nums[0])
  i949 = m3_wl_lookup(wl, nums[1])
  r749 = float(tile[*,i749])

  a = (r749 - x0)^2
  if zmask[0] ne -1 then r749[zmask] = 1.0
  b = (float(tile[*,i949])/r749 - y0)^2
  out=sqrt(a+b)
  if zmask[0] ne -1 then out[zmask] = m3_params_get_badval()
  return, out
end
