function m3_params_olindex, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr

   nums = [650, 860, 1047, 1230, 1750]
   if keyword_set(return_nums) then return, nums

   i650  = m3_wl_lookup(wl, nums[0])
   i860  = m3_wl_lookup(wl, nums[1])
   i1047 = m3_wl_lookup(wl, nums[2])
   i1230 = m3_wl_lookup(wl, nums[3])
   i1750 = m3_wl_lookup(wl, nums[4])

   R650  = float(tile[*, i650])
   R860  = float(tile[*, i860])
   R1047 = float(tile[*, i1047])
   R1230 = float(tile[*, i1230])
   R1750 = float(tile[*, i1750])
   wl650 = wl[i650]
   wl860 = wl[i860]
   wl1047 = wl[i1047]
   wl1230 = wl[i1230]
   wl1750 = wl[i1750]

   slope = (R1750 - R650)/(wl1750 - wl650)
   if zmask[0] ne -1 then R650[zmask]=1.0
   if zmask[0] ne -1 then R1047[zmask]=1.0
   if zmask[0] ne -1 then R1230[zmask]=1.0

   a = (slope * (wl860 - wl650) + R650)/R860
   b = (slope * (wl1047 - wl650) + R650)/R1047
   c = (slope * (wl1230 - wl650) + R650)/R1230

   out = 0.1*a + 0.5*b + 0.25*c
   if zmask[0] ne -1 then out[zmask] = m3_params_get_badval()
   return, out
 end
