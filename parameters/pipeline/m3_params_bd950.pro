function m3_params_bd950, tile, wl, return_nums = return_nums, zmask=zmask
compile_opt strictarr
  ;
  nums = [749, 949, 1579]
  if keyword_set(return_nums) then return, nums
  ;
  i749 = m3_wl_lookup(wl, nums[0])
  i949 = m3_wl_lookup(wl, nums[1])
  i1579 = m3_wl_lookup(wl, nums[2])
  ;
  R749 = float(tile[*,i749])
  R949 = float(tile[*,i949])
  R1579 = float(tile[*,i1579])
  wl749 = wl[i749]
  wl949 = wl[i949]
  wl1579 = wl[i1579]
  ;
  slope = (R1579 - R749)/(wl1579 - wl749)
  ;
  denom = slope * (wl949 - wl749) + R749
  ;
  bd950 =  1 - (R949/denom)
  
  if zmask[0] ne -1 then bd950[zmask] = m3_params_get_badval()
  return, bd950
  ;
end
