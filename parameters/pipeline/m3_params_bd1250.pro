function m3_params_bd1250, tile, wl, return_nums = return_nums, zmask=zmask
compile_opt strictarr
  ;
  nums = [749, 1249, 1579]
  if keyword_set(return_nums) then return, nums
  ;
  i749 = m3_wl_lookup(wl, nums[0])
  i1249 = m3_wl_lookup(wl, nums[1])
  i1579 = m3_wl_lookup(wl, nums[2])
  ;
  R749 = float(tile[*,i749])
  R1249 = float(tile[*,i1249])
  R1579 = float(tile[*,i1579])
  wl749 = wl[i749]
  wl1249 = wl[i1249]
  wl1579 = wl[i1579]
  ;
   
  slope = (R1579 - R749)/(wl1579 - wl749)
  ;
  denom = slope * (wl1249 - wl749) + R749
  ;
  bd1250 =  1 - (R1249/denom)
  
  if zmask[0] ne -1 then bd1250[zmask] = m3_params_get_badval()
  
  return, bd1250
  ;
end
