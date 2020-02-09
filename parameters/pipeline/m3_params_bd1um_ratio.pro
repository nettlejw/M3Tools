function m3_params_bd1um_ratio, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr
  ;
  nums = [929, 1579, 699, 989]
  if keyword_set(return_nums) then return, nums
  ;
  i929  = m3_wl_lookup(wl, nums[0])
  i1579 = m3_wl_lookup(wl, nums[1])
  i699  = m3_wl_lookup(wl, nums[2])
  i989  = m3_wl_lookup(wl, nums[3])
  ;
  R929  = float(tile[*,i929])
  R1579 = float(tile[*,i1579])
  R699  = float(tile[*,i699])
  R989  = float(tile[*,i989])
  ;
  cs = (R1579 - R699)/(wl[i1579] - wl[i699])
  if zmask[0] ne -1 then cs[zmask] = 1.0
  ;
  bd930 = 1 - (R929/(cs * (wl[i929] - wl[i699]) + R699))
  bd990 = 1 - (R989/(cs * (wl[i989] - wl[i699]) + R699))
  ;
  if zmask[0] ne -1 then bd990[zmask] = 1.0
  ratio = bd930/bd990
  if zmask[0] ne -1 then ratio[zmask] = m3_params_get_badval()
  return, ratio

end
