function m3_params_1um_sym, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr
  ;
  ;  get the nums from the fwhm parameter
  ;
  nums = m3_params_1um_fwhm(/return_nums)
  if keyword_set(return_nums) then return, nums
  ;
  ;  get the input tiles we need
  ;
  mintile = m3_params_1um_min(tile, wl, zmask=zmask)
  fwhm = m3_params_1um_fwhm(tile, wl, /return_pts, low_tile=low_tile, $
             high_tile=high_tile, zmask=zmask)
  lwl = wl[low_tile]
  hwl = wl[high_tile]
  ;
  ;  figure the a and b distances, return the ratio
  ;
  a = mintile - lwl
  b = hwl - mintile
  ;
  ; handle zmask, return ratio
  ;
  if zmask[0] ne -1 then b[zmask] = 1.0
  ratio = a/b
  if zmask[0] ne -1 then ratio[zmask] = m3_params_get_badval()
  return, ratio
  ;
end
