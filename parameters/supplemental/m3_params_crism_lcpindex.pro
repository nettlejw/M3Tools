function m3_params_crism_lcpindex, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr

  nums = [1330, 1050, 1815]
  if keyword_set(return_nums) then return, nums

  i1330 = m3_wl_lookup(wl, nums[0])
  i1050 = m3_wl_lookup(wl, nums[1])
  i1815 = m3_wl_lookup(wl, nums[2])

  R1330 = float(tile[*, i1330])
  R1050 = float(tile[*, i1050])
  R1815 = float(tile[*, i1815])
  
  if zmask[0] ne -1 then R1330[zmask] = 1.0

  out = ((R1330-R1050)/(R1330+R1050)) * ((R1330-R1815)/(R1330+R1815))
  if zmask[0] ne -1 then out[zmask] = m3_params_get_badval()
  return, out
end
