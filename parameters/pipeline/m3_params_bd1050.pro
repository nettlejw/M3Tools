function m3_params_bd1050, tile, wl, return_nums = return_nums, zmask=zmask
compile_opt strictarr
  ;
  nums = [749, 1049, 1579]
  if keyword_set(return_nums) then return, nums
  ;
  i749 = m3_wl_lookup(wl, nums[0])
  i1049 = m3_wl_lookup(wl, nums[1])
  i1579 = m3_wl_lookup(wl, nums[2])
  ;
  R749 = float(tile[*,i749])
  R1049 = float(tile[*,i1049])
  R1579 = float(tile[*,i1579])
  wl749 = wl[i749]
  wl1049 = wl[i1049]
  wl1579 = wl[i1579]
  ;
  slope = (R1579 - R749)/(wl1579 - wl749)
  ;
  denom = slope * (wl1049 - wl749) + R749
  ;
  bd1050= 1 - (R1049/denom)
  
  if zmask[0] ne -1 then bd1050[zmask] = m3_params_get_badval()
  
  return, bd1050
  ;
end
