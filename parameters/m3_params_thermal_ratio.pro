function m3_params_thermal_ratio, tile, wl, return_num = return_num, zmask=zmask
compile_opt strictarr

  nums = [2538, 2978]
  if keyword_set(return_nums) then return, nums

  i2538 = m3_wl_lookup(wl, nums[0])
  i2978 = m3_wl_lookup(wl, nums[1])

  R2538 = float(tile[*, i2538])
  R2978 = float(tile[*, i2978])
  
  if zmask[0] ne -1 then R2978[zmask] = 1.0
  
  ratio = R2538/R2978
  if zmask[0] ne -1 then ratio[zmask] = m3_params_get_badval()
  
  return, ratio 

end


