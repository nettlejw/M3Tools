function m3_params_r950_750, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr

  nums = [949, 749]
  if keyword_set(return_nums) then return, nums

  i949 = m3_wl_lookup(wl, nums[0])
  i749 = m3_wl_lookup(wl, nums[1])

  R949 = float(tile[*,i949])
  R749 = float(tile[*,i749])
  ;
  ;  check for zeroes
  ;
  if zmask[0] ne -1 then R749[zmask] = 1.0
  ;
  ; do the ratio, set bad values
  ;
  ratio = R949/R749
  if zmask[0] ne -1 then ratio[zmask] = m3_params_get_badval()
  ;
  return, ratio
end
