pro m3_read_wl_info, twl=twl, tfwhm=tfwhm, gwl=gwl, global_mapping=global_mapping, $
                     check=check
   ;
   ;  PURPOSE:  returns the m3 wavelength resampling information.
   ;            output is three arrays, each with one element per TARGET channel.
   ;            the arrays are:  wavelength, fwhm, and global_mapping.  The value of "global_mapping" 
   ;            tells you which global channel the given target channel should be averaged into.
   ;
   ;  MODIFICATION HISTORY:
   ;    -Written. Jeff Nettles, 8/20/2008
   ;    -Modified to use new band centers from new wl calib. JWN, 12/13/2008
   ;    -Redid how the first global channel is removed to a more sensible method
   ;     and added a sanity check to make sure wavelengths match those expected. 
   ;     JWN, 4/25/2009
   ;--------------------------------------------------------------------------------
   compile_opt strictarr
   ;
   ;  get the input directory and filename to use
   ;
   infile = filepath('m3_wavelengths.csv', root_dir = m3_programrootdir(), $
                       subdirectory = 'resources')
   ;
   ;  count lines
   ;
   nlines = file_lines(infile)
   dlines = nlines - 1 ;one header line, the rest is data
   ;
   ;  read in header, then the rest of the file into a separate array
   ;
   openr, lun, infile, /get_lun
   header = ''
   readf, lun, header
   alld = strarr(dlines)
   readf, lun, alld
   free_lun, lun
   ;
   ;  split the arrays up
   ;
   splits = strarr(7, dlines)
   for i = 0, n_elements(alld) - 1 do splits[*, i] = strsplit(alld[i],',',/preserve_null, /extract)
   twl = double(reform(splits[3,*]))
   tfwhm = double(reform(splits[4,*]))
   global_mapping = fix(reform(splits[6,*]))
   gwl_check = double(reform(splits[1,*]))
   idx = where(gwl_check gt 0, count)
   if count le 0 then message, 'Error reading wavelength csv file.'
   gwl_check = gwl_check[idx]
   ;
   ;  create the global wl array
   ;
   g_uniq=uniq(global_mapping, sort(global_mapping))
   ngwl = n_elements(g_uniq)
   gwl = dblarr(ngwl)
;   global_mapping = global_mapping - 1 ;convert channel nums to indices   
   ;
   ;  do the averaging to get global wavelengths
   ;
   for i = 0, ngwl - 1 do begin
     idx = where(global_mapping eq i+1, count)
     if count le 0 then message, 'iteration ' + strtrim(i,2) + ' did not find a global_mapping.'
     gwl[i] = total(twl[idx])/count     
   endfor     
   ;
   ;  remove first global channel
   ;
   gwl=gwl[1:n_elements(gwl)-1]
   gwl_check=gwl_check[1:n_elements(gwl_check)-1]
   ;
   ;  now check to make sure the wavelengths calculated match the check
   ;
   threshold=0.01
   diffs=abs(gwl-gwl_check)
   errpos=where(diffs gt threshold, count)
   if count gt 0 then message, 'Calculated wavelengths do not match those expected.'
   ;
   check=gwl_check
   ;
end
