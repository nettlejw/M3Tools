function m3_params_bd620, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr

  nums = [419, 619, 749]
  if keyword_set(return_nums) then return, nums

  i419 = m3_wl_lookup(wl, nums[0])
  i619 = m3_wl_lookup(wl, nums[1])
  i749 = m3_wl_lookup(wl, nums[2])

  R419 = float(tile[*, i419])
  R619 = float(tile[*, i619])
  R749 = float(tile[*, i749])

  den = ((R749 - R419)/(wl[i749] - wl[i419])) * (wl[i619] - wl[i419]) + R419


  bd620 =  1.0 - (R619/den)

  if zmask[0] ne -1 then bd620[zmask] = m3_params_get_badval()
  
  return, bd620
  
end
