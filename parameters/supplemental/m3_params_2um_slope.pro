function m3_params_2um_slope, tile, wl, return_nums = return_nums, line=line, zmask=zmask
compile_opt strictarr

  nums = [2538, 1578]
  if keyword_set(return_nums) then return, nums

  i2538 = m3_wl_lookup(wl, nums[0])
  i1578 = m3_wl_lookup(wl, nums[1])


  R2538 = float(tile[*, i2538])
  R1578 = float(tile[*, i1578])
  dx = wl[i2538] - wl[i1578]

  slope = (R2538 - R1578)/dx

  if ~keyword_set(line) then begin
     slope=slope * 100
     if zmask[0] ne -1 then slope[zmask]=m3_params_get_badval()
     return, slope 
  endif   

   cont = fltarr(size(tile, /dimensions))
   ns = (size(tile,/dimensions))[0]
   zmask_tile=intarr(ns)
   if zmask[0] ne -1 then zmask_tile[zmask] = 1

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
    knowny = [refl[i1578], refl[i2538]]
    knownx = [wl[i1578], wl[i2538]]
    cont[i,*] = interpol(knowny, knownx, wl)
   endfor
   return, cont

end
