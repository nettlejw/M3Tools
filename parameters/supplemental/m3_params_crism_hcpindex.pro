function m3_params_crism_hcpindex, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr

  nums = [1470, 1050, 2067]
  if keyword_set(return_nums) then return, nums


  i1470 = m3_wl_lookup(wl, nums[0])
  i1050 = m3_wl_lookup(wl, nums[1])
  i2067 = m3_wl_lookup(wl, nums[2])

  R1470 = float(tile[*, i1470])
  R1050 = float(tile[*, i1050])
  R2067 = float(tile[*, i2067])
  
  if zmask[0] ne -1 then R1470[zmask] = 1.0

  out= ((R1470-R1050)/(R1470+R1050)) * ((R1470-R2067)/(R1470+R2067))
  if zmask[0] ne -1 then out[zmask] = m3_params_get_badval()
  
  return, out

end
