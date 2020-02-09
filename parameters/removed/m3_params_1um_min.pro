function m3_params_1um_min, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr
  ;
  ;  simple (standard) error catching mechanism
  ;
  ;CATCH, error
  ;IF (error NE 0) THEN BEGIN
  ;   catch, /cancel
  ;   ok = m3_error_message()
  ;   return, -1
  ;ENDIF
  ;
  ; handle the return_nums keyword
  ;
  if n_elements(wl) eq 0 then begin
    nums = [890, 1349]
   endif else begin
    w =where((wl ge 890) and (wl le 1349), count)
    if count le 0 then message, 'No wavelengths between 890 and 1349 nm were supplied.'
    nums = wl[w]
  endelse
  if keyword_set(return_nums) then return, nums
  ;
  ; get the continuum
  ;
  continuum = m3_params_1um_slope(tile, wl, /line, zmask=zmask)
  if zmask[0] ne -1 then continuum[zmask,*] = 1.0
  ;
  ;  get array indices to subset with
  ;
  pos = indgen(n_elements(nums))
  for j = 0, n_elements(nums) - 1 do pos[j] = m3_wl_lookup(wl, nums[j])
  ;
  ; calculate ratio and subtract from 1
  ;
  ratio = 1 - float(tile)/continuum
  ;
  ; subset the ratio
  ;
  subset = ratio[*, pos]
  ;
  ; find max for each col, store subscripts in variable ms
  ;
  maxr = max(subset,ms, dimension = 2)
  ;
  ;  the subscripts stored in ms are 1d subscripts into 'subset', we need to find
  ;  row indices so that we can then subscript the wavelength array
  ;
  wls = wl[pos] ;subscript the wl array to the given range
  ind = array_indices(subset, ms)
  ind = reform(ind[1,*])
  wl_out = fltarr(n_elements(maxr))
  for x = 0, n_elements(maxr)  - 1 do wl_out[x] = wls[ind[x]]
  ;
  if zmask[0] ne -1 then wl_out[zmask] = m3_params_get_badval()
  return, wl_out
  ;
end




