function m3_params_nbd1400, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr
  ;
  nums = [1348, 1368, 1428, 1448, 1408]
  if keyword_set(return_nums) then return, nums
  ;
  i1348  = m3_wl_lookup(wl, nums[0])
  i1368  = m3_wl_lookup(wl, nums[1])
  i1428  = m3_wl_lookup(wl, nums[2])
  i1448  = m3_wl_lookup(wl, nums[3])
  i1408  = m3_wl_lookup(wl, nums[4])
  ;
  R1348 = float(tile[*,i1348])
  R1368 = float(tile[*,i1368])
  R1428 = float(tile[*,i1428])
  R1448 = float(tile[*,i1448])
  R1408 = float(tile[*,i1408])
  ;
  RC = (R1348 + R1368)/2
  LC = (R1428 + R1448)/2
  DEN=RC+LC
  if zmask[0] ne -1 then DEN[zmask] = 1.0
  BB = R1408
  out = 1 - 2*(BB/DEN)
  if zmask[0] ne -1 then out[zmask] = m3_params_get_badval()
  ;
  return, out

end
