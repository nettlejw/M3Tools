function m3_params_nbd2300, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr
  ;
  nums = [2218, 2258, 2378, 2418, 2298, 2338]
  if keyword_set(return_nums) then return, nums
  ;
  i2218  = m3_wl_lookup(wl, nums[0])
  i2258  = m3_wl_lookup(wl, nums[1])
  i2378  = m3_wl_lookup(wl, nums[2])
  i2418  = m3_wl_lookup(wl, nums[3])
  i2298  = m3_wl_lookup(wl, nums[4])
  i2338  = m3_wl_lookup(wl, nums[5])
  ;
  R2218 = float(tile[*,i2218])
  R2258 = float(tile[*,i2258])
  R2378 = float(tile[*,i2378])
  R2418 = float(tile[*,i2418])
  R2298 = float(tile[*,i2298])
  R2338 = float(tile[*,i2338])
  ;
  RC = (R2218 + R2258)/2
  LC = (R2378 + R2418)/2
  BB = (R2298 + R2338)/2
  DEN=RC+LC
  if zmask[0] ne -1 then DEN[zmask]=1.0
  out=1 - 2*(BB/DEN)
  if zmask[0] ne -1 then out[zmask] = m3_params_get_badval()
  ;
  return, out

end
