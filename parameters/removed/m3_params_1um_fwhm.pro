function m3_params_1um_fwhm, tile, wl, return_nums = return_nums, return_pts=return_pts, $
                                    low_tile=low_tile, high_tile=high_tile, zmask=zmask
compile_opt strictarr
  ;
  bounds = [700,1500]
  if n_elements(wl) eq 0 then begin
    nums = bounds
   endif else begin
    w =where((wl ge bounds[0]) and (wl le bounds[1]), count)
    if count le 0 then message, 'No wavelengths between 890 and 1108 nm were supplied.'
    nums = wl[w]
  endelse
  if keyword_set(return_nums) then return, nums
  ;
  ;  get the 1um_min parameter values & the continuum
  ;
  wlmin = m3_params_1um_min(tile, wl, zmask=zmask)
  cont = m3_params_1um_slope(tile, wl, /line, zmask=zmask)
  if zmask[0] ne -1 then cont[zmask,*] = 1.0
  ;
  ;  remove continuum from reflectance data & subset it
  ;
  crtile = float(tile)/cont
  ;
  ;  get array indices to subset with
  ;
  subset = indgen(n_elements(nums))
  for j = 0, n_elements(nums) - 1 do subset[j] = m3_wl_lookup(wl, nums[j])
  ;
  ;  subset the data now
  ;
  crsubset = crtile[*, subset]
  wlsubset = wl[subset]
  ;
  ;  set up output array(s)
  ;
  ns = (size(tile, /dimensions))[0]
  out_tile = fltarr(ns)
  if keyword_set(return_pts) then begin
    low_tile = fltarr(ns)
    high_tile = fltarr(ns)
  endif
  zmask_tile=intarr(ns)
  if zmask[0] ne -1 then zmask_tile[zmask] = 1
  ;
  ;  do the calcs over a loop
  ;
  for j = 0, ns - 1 do begin
    ;
    if zmask_tile[j] eq 1 then begin
      if keyword_set(return_pts) then begin
        low_tile[j] = m3_params_get_badval()
        high_tile[j] = m3_params_get_badval()
      endif  
      out_tile[j] = m3_params_get_badval()
      continue
    endif
    ;
    i = where(wlsubset eq wlmin[j], count)
    if count ne 1 then message, 'position of 1um min wavelength not found.'
    ;
    ;  pick out the current cont. rem. reflectance curve
    ;
    cr = reform(crsubset[j,*])
    ;
    ;  find halfmax reflectance value and subtract from cont. rem. refl's so that we can find positions
    ;
    halfmax = (((1 - cr[i])/2.0) + cr[i])[0]
    diffs = abs(cr - halfmax)
    ;
    ;  break up diffs array into two chunks, low and high, and find min differences to halfmax
    ;
    diffs_low = diffs[0:i-1]
    diffs_high = diffs[i+1:n_elements(diffs)-1]
    wl_low = wlsubset[0:i-1]
    wl_high = wlsubset[i+1:n_elements(diffs)-1]
    ;
    ;  low first
    ;
    lowpos = where(diffs_low eq min(diffs_low), lowcount)
    lowpos = lowpos[0]            ;set the answer to the 1st wavelength - this might be dangerous
    ;
    ;  high
    ;
    highpos = where(diffs_high eq min(diffs_high), highcount)
    highpos = highpos[0]          ;ditto for this
    ;
    ;  output the distance in wl units
    ;
    print, wl_low
    help, lowpos
    out_tile[j] = wl_high[highpos] - wl_low[lowpos]
    ;
    if keyword_set(return_pts) then begin
      highindex = where(wl eq wl_high[highpos])
      lowindex  = where(wl eq wl_low[lowpos])
      high_tile[j] = highindex
      low_tile[j] = lowindex
    endif
    ;
  endfor
  ;
;  if zmask[0] ne -1 then out_tile[zmask] = m3_params_get_badval()
  return, out_tile
  ;
end
