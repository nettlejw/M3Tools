function m3_params_bd3000, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr
  ;
  nums = [2978, 2538, 1578]
  if keyword_set(return_nums) then return, nums
  ;
  i2978 = m3_wl_lookup(wl, nums[0])
  i2538 = m3_wl_lookup(wl, nums[1])
  i1578 = m3_wl_lookup(wl, nums[2])

  R2978 = float(tile[*,i2978])
  R2538 = float(tile[*,i2538])
  R1578 = float(tile[*,i1578])

  cs = ((R2538 - R1578) / (wl[i2538] - wl[i1578]))
  bd3000= 1 - (R2978/(cs * (wl[i2978] - wl[i1578]) + R1578))
  
  if zmask[0] ne -1 then bd3000[zmask] = m3_params_get_badval()

  return, bd3000
  
end
