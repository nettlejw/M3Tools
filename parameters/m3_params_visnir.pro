function m3_params_visnir, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr
  ;
  nums = [699, 1579]
  if keyword_set(return_nums) then return, nums
  ;
  i699  = m3_wl_lookup(wl, nums[0])
  i1579 = m3_wl_lookup(wl, nums[1])
  ;
  R699  = float(tile[*, i699])
  R1579 = float(tile[*, i1579])
  ;
  if zmask[0] ne -1 then R1579[zmask] = 1.0
  ;
  ratio = R699/R1579
  if zmask[0] ne -1 then ratio[zmask] = m3_params_get_badval()
  ;
  return, ratio
  ;
end
