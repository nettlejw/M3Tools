function m3_params_bd2um_ratio, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr;
  nums = [1898, 2578, 1578, 2298]
  if keyword_set(return_nums) then return, nums
  ;
  i1898  = m3_wl_lookup(wl, nums[0])
  i2578  = m3_wl_lookup(wl, nums[1])
  i1578  = m3_wl_lookup(wl, nums[2])
  i2298  = m3_wl_lookup(wl, nums[3])
  ;
  R1898 = float(tile[*,i1898])
  R2578 = float(tile[*,i2578])
  R1578 = float(tile[*,i1578])
  R2298 = float(tile[*,i2298])
  ;
  cs = (R2578 - R1578)/(wl[i2578] - wl[i1578])
  if zmask[0] ne -1 then cs[zmask] = 1.0
  ;
  a = 1 - (R1898/(cs * (wl[i1898] - wl[i1578]) + R1578))
  b = 1 - (R2298/(cs * (wl[i2298] - wl[i1578]) + R1578))
  ;
  if zmask[0] ne -1 then b[zmask] = 1.0
  ratio = a/b
  if zmask[0] ne -1 then ratio[zmask] = m3_params_get_badval()
  return, ratio
  ;
end
