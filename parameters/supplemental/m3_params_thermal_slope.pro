function m3_params_thermal_slope, tile, wl, return_num = return_num, line=line, zmask=zmask
compile_opt strictarr

  nums = [2538, 2978]
  if keyword_set(return_nums) then return, nums

  i2538 = m3_wl_lookup(wl, nums[0])
  i2978 = m3_wl_lookup(wl, nums[0])

  R2538 = float(tile[*, i2538])
  R2978 = float(tile[*, i2978])

  dx = wl[i2978] - wl[i2538]
  if zmask[0] ne -1 then dx[zmask] = 1.0

  slope =  (R2978 - R2538)/dx

  if ~keyword_set(line) then begin
    slope= slope * 100
    if zmask[0] ne -1 then slope[zmask]=m3_params_get_badval()
    return, slope
  endif

  s = size(tile, /dimensions)
  ns = s[0]
  cont = fltarr(s)
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
    knowny = [refl[i2538], refl[i2978]]
    knownx = [wl[i2538], wl[i2978]]
    cont[i,*] = interpol(knowny, knownx, wl)
   endfor
   return, cont


end


