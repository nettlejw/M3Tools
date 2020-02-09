function m3_params_crism_olindex, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr

   nums = [1695, 1050, 1210, 1330, 1470]
   if keyword_set(return_nums) then return, nums

   i1695 = m3_wl_lookup(wl, nums[0])
   i1050 = m3_wl_lookup(wl, nums[1])
   i1210 = m3_wl_lookup(wl, nums[2])
   i1330 = m3_wl_lookup(wl, nums[3])
   i1470 = m3_wl_lookup(wl, nums[4])

   a = 0.1 * tile[*,i1050]
   b = 0.1 * tile[*,i1210]
   c = 0.4 * tile[*,i1330]
   d = 0.4 * tile[*,i1470]

   out=(float(tile[*,i1695])/(a + b + c + d)) - 1
   if zmask[0] ne -1 then out[zmask]=m3_params_get_badval()
   return, out

end
