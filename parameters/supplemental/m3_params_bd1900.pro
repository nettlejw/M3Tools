function m3_params_bd1900, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr

  nums = [1898, 2498, 1408]
  if keyword_set(return_nums) then return, nums

   i1898 = m3_wl_lookup(wl, nums[0])
   i2498 = m3_wl_lookup(wl, nums[1])
   i1408 = m3_wl_lookup(wl, nums[2])




   R1898 = float(tile[*, i1898])
   R2498 = float(tile[*, i2498])
   R1408 = float(tile[*, i1408])
   
   if zmask[0] ne -1 then R1408[zmask] = 1.0

   wl1898 = wl[i1898]
   wl2498 = wl[i2498]
   wl1408 = wl[i1408]

   a = (R2498 - R1408)/(wl2498 -wl1408)
   b = (wl2498 - wl1408)
   out = 1 - (R1898/(a*b + R1408))
   if zmask[0] ne -1 then out[zmask] = m3_params_get_badval()
   
   return, out 

end
