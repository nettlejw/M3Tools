function m3_params_hbd2700, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr
  ;
  nums = [2578, 2618, 2658, 2698, 2738]
  if keyword_set(return_nums) then return, nums
  ;
  i2578  = m3_wl_lookup(wl, nums[0])
  i2618  = m3_wl_lookup(wl, nums[1])
  i2658  = m3_wl_lookup(wl, nums[2])
  i2698  = m3_wl_lookup(wl, nums[3])
  i2738  = m3_wl_lookup(wl, nums[4])
  ;
  R2578 = float(tile[*,i2578])
  R2618 = float(tile[*,i2618])
  R2658 = float(tile[*,i2658])
  R2698 = float(tile[*,i2698])
  R2738 = float(tile[*,i2738])
  ;
  RC = (R2578 + R2618 + R2658)/3
  if zmask[0] ne -1 then RC[zmask] = 1.0
  BB = (R2698 + R2738)/2
  ;
  out=1 - (BB/RC)
  if zmask[0] ne -1 then out[zmask] = m3_params_get_badval()
  return, out
end
