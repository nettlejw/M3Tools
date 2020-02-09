function m3_params_nbd1480, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr
  ;
  nums = [1428, 1448, 1508, 1528, 1488]
  if keyword_set(return_nums) then return, nums
  ;
  i1428  = m3_wl_lookup(wl, nums[0])
  i1448  = m3_wl_lookup(wl, nums[1])
  i1508  = m3_wl_lookup(wl, nums[2])
  i1528  = m3_wl_lookup(wl, nums[3])
  i1488  = m3_wl_lookup(wl, nums[4])
  ;
  R1428 = float(tile[*,i1428])
  R1448 = float(tile[*,i1448])
  R1508 = float(tile[*,i1508])
  R1528 = float(tile[*,i1528])
  R1488 = float(tile[*,i1488])
  ;
  RC = (R1428 + R1448)/2
  LC = (R1508 + R1528)/2
  DEN=RC+LC
  if zmask[0] ne -1 then DEN[zmask] = 1.0
  BB = R1488
  out=1 - 2*(BB/DEN)
  if zmask[0] ne -1 then out[zmask] = m3_params_get_badval()
  return, out

end
