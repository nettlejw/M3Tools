function m3_params_hbd2850, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr
  ;
  nums = [2538, 2578, 2618, 2817, 2857, 2897]
  if keyword_set(return_nums) then return, nums
  ;
  i2538  = m3_wl_lookup(wl, nums[0])
  i2578  = m3_wl_lookup(wl, nums[1])
  i2618  = m3_wl_lookup(wl, nums[2])
  i2817  = m3_wl_lookup(wl, nums[3])
  i2857  = m3_wl_lookup(wl, nums[4])
  i2897  = m3_wl_lookup(wl, nums[5])
  ;
  R2538 = float(tile[*,i2538])
  R2578 = float(tile[*,i2578])
  R2618 = float(tile[*,i2618])
  R2817 = float(tile[*,i2817])
  R2857 = float(tile[*,i2857])
  R2897 = float(tile[*,i2897])
  ;
  RC = (R2538 + R2578 + R2618)/3
  if zmask[0] ne -1 then RC[zmask] = 1.0
  BB = (R2817 + R2857 + R2897)/3
  ;
  out = 1 - (BB/RC)
  if zmask[0] ne -1 then out[zmask] = m3_params_get_badval()
  return, out
end
