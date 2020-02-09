function m3_params_bd2300, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr

  nums = [2298, 2578, 1758]
  if keyword_set(return_nums) then return, nums

   i2298 = m3_wl_lookup(wl, nums[0])
   i2578 = m3_wl_lookup(wl, nums[1])
   i1758 = m3_wl_lookup(wl, nums[2])




   R2298 = float(tile[*, i2298])
   R2578 = float(tile[*, i2578])
   R1758 = float(tile[*, i1758])
   
   if zmask[0] ne -1 then R1758[zmask] = 1.0

   wl2298 = wl[i2298]
   wl2578 = wl[i2578]
   wl1758 = wl[i1758]

   a = (R2578 - R1758)/(wl2578 -wl1758)
   b = (wl2298 - wl1758)

   out = 1 - (R2298/(a*b + R1758))
   if zmask[0] ne -1 then out[zmask] = m3_params_get_badval()
   return, out
end
