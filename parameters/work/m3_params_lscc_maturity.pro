function m3_params_lscc_maturity, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr
 ;
 ;  get dummy tile for now
 ;
 wl = wl/1000 ;convert to microns
 ;
 ;  set up coefficients array, initially as 1D then later transform it to same size as cr tile
 ;
 wk = [0.5437, -0.0373, -1.7886, 0.4399, 0.0191, 1.3602, -0.2237, -0.1013, 0.9749, $
       0.8511, -2.2591, 1.1401, -1.6381, 1.6678, -0.8136, -0.2906, -0.2254, -2.7015, $
       1.2513, -2.1461, 0.5259, 3.6570, -0.9080, -2.2861, -1.1221, 3.2813, 0.5704, -1.6918,$
       -1.3381, 3.2822, 0.6930, 1.3396, -2.5702, -1.0514, 1.4725, -3.2801, -1.2144, 0.2801, $
       0.6140, -1.7001, 1.1014, 1.9980, -2.8937, 0.0858, 0.5151, 2.0071]
 ;
 ;  set up output wavelength values
 ;
 nc = n_elements(wk) + 1
 o_wl = findgen(nc) * 0.05 + 0.3
 if keyword_set(return_nums) then return, o_wl
 ;
 ;  resample the tile to the wavelengths the equation needs
 ;
 ENVI_RESAMPLE_SPECTRA, wl, tile, o_wl, out_tile, interleave=1, out_dt=4
 ;
 ;  calculate the color ratios
 ;
 shifts = shift(out_tile, 0, -1)  ;shift elements up
 if zmask[0] ne -1 then shifts[zmask,*]=1.0
 cr = out_tile/shifts  ;get the ratios
 cr = cr[*,0:nc - 2] ;trim the last row off
 ;
 ;  now reform the wk array to equal the size of a tile
 ;
 ns = (size(tile, /dimensions))[0]
 wk = rebin(reform(wk,1,nc-1),ns, nc-1)
 ;
 ;  calculate the equation now and return it
 ;
 out= total(finite(wk*cr*10), 2)+ 26.99990
 if zmask[0] ne -1 then out[zmask]=m3_params_get_badval()
 return, out
 ;
 ;
end
