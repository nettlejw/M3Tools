function m3_params_vis_slope, tile, wl, line=line, return_nums=return_nums, zmask=zmask
compile_opt strictarr

  nums = [419, 749]
  if keyword_set(return_nums) then return, nums

  ;if the line keyword is set, the function returns the actual continuum
  ;curve rather than just the slope.

  i419 = m3_wl_lookup(wl, nums[0])
  i749 = m3_wl_lookup(wl, nums[1])
  num = float(tile[*, i749]) - float(tile[*, i419])
  den = wl[i749] - wl[i419]

  ;return slope in percent if not being asked to return the continuum itself
  ;
  slope = num/den
  if ~keyword_set(line) then begin
    slope=slope * 100.00
    if zmask[0] ne -1 then slope[zmask]=m3_params_get_badval()
    return, slope
  endif


  s = size(tile, /dimensions)
  ns = s[0]
  nb = s[1]  ;calling this nb instead of nl b/c it should be a BIL tile so it's [ns, nb]
  cont = fltarr(ns, nb)
  zmask_tile=intarr(ns)
  if zmask[0] ne -1 then zmask_tile[zmask]=1

  ;interpolate continuum curve for each reflectance curve
  ;
  ;  (this could use some optimizing)
  ;
  for i = 0,ns - 1 do begin
    if zmask_tile[i] eq 1 then begin
      cont[i,*]=m3_params_get_badval()
      continue
    endif
    refl = reform(tile[i,*])
    knowny = [refl[i419], refl[i749]]
    knownx = [wl[i419], wl[i749]]
    cont[i,*] = interpol(knowny, knownx, wl)
  endfor
  return, cont


end
