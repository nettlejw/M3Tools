function m3_params_2um_ratio, tile, wl, return_num = return_num, zmask=zmask
compile_opt strictarr

  nums = [1578, 2538]
  if keyword_set(return_nums) then return, nums

  i1578 = m3_wl_lookup(wl, nums[0])
  i2538 = m3_wl_lookup(wl, nums[1])

  R1578 = float(tile[*, i1578])
  R2538 = float(tile[*, i2538])

  if zmask[0] ne -1 then R2538[zmask] = 1.0
  
  ratio = R1578/R2538
  
  if zmask[0] ne -1 then ratio[zmask] = m3_params_get_badval()

  return, ratio

end


