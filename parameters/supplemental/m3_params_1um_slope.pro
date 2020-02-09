function m3_params_1um_slope, tile, wl, return_nums=return_nums, line=line, zmask=zmask
compile_opt strictarr

   nums = [699, 1579]
   if keyword_set(return_nums) then return, nums

   
   i699 = m3_wl_lookup(wl, nums[0])
   i1579 = m3_wl_lookup(wl, nums[1])

   R1579 = float(tile[*, i1579])
   R699 = float(tile[*, i699])
   dx = wl[i1579] - wl[i699]

   slope = (R1579 - R699)/dx

   if ~keyword_set(line) then begin
     slope = slope * 100
     if zmask[0] ne -1 then slope[zmask]=m3_params_get_badval()
     return, slope
   endif

   s = size(tile, /dimensions)
   ns  = s[0]
   cont = fltarr(s)
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
    knowny = [refl[i699], refl[i1579]]
    knownx = [wl[i699], wl[i1579]]
    cont[i,*] = interpol(knowny, knownx, wl)
   endfor
   return, cont

end
