pro m3_params_display_color_composite, event

  ;This routine allows a user to display pre-defined color composites for use in spectral
  ;descrimination.
  ;
  ;The user must input a pre-calculated spectral parameters cube - this routine simply looks
  ;for the right combination of bands and displays them in RGB space, it does not actually calculate
  ;any parameters.
  ;
  ;Furthermore, the routine does a fairly strict search for certain band names.  If the bands in the input
  ;spectral parameters cube are not named in the way that this routine expects, an error can result.
  ;
  ;*******************************************************************************************************
  compile_opt strictarr
  ;simple (standard) error catching mechanism
  CATCH, error
  IF (error NE 0) THEN BEGIN
     catch, /cancel
     ok = m3_error_message()
     return
  ENDIF
  ;
  ;   specify directory to search for color composite definition files
  ;
  ccdir = filepath('', root_dir = m3_programrootdir(), subdirectory = ['resources', 'parameter_composites'])
  ccfiles = file_search(ccdir + '*.txt')
  prefs=obj_new('m3_prefs')
  ccdir=prefs->get('color_composite_dir')
  if strmid(ccdir,0,1,/reverse_offset) ne path_sep() then ccdir=ccdir+path_sep()
  custom_files=file_search(ccdir+'*.txt', count=nf)
  if nf gt 0 then ccfiles=[ccfiles,custom_files]
  ;
  ;  build auto-managed widget that asks user which composite to use
  ;
  cclist = strupcase(file_basename(ccfiles, '.txt'))
  base = widget_auto_base(title = 'Select Color Composite to Display')
  wm = widget_multi(base, list=cclist, uvalue='cclist_indices', /auto)
  result = auto_wid_mng(base)
  if (result.accept eq 0) then return
  cc_selected = where(result.cclist_indices eq 1, count)
  ;
  ;  Get the input file whose bands are to be displayed & get its band names
  ;
  envi_select, title = 'Select Input file', fid = fid, /file_only
  if (fid eq -1) then return
  envi_file_query, fid, bnames = bnames, fname=fname
  infile = file_basename(fname)
  ;
  ;  Loop through list of select composites, read their respective data files, and display
  ;
  if count gt 0 then begin
   for i = 0, count - 1 do begin
     datafile = ccfiles[cc_selected[i]]
     if file_lines(datafile) ne 3 then message, 'the datafile ' + file_basename(datafile) + $
         ' does not appear to be in the proper format.'
     openr, lun, datafile, /get_lun
     red = ''
     green = ''
     blue = ''
     readf, lun, red
     readf, lun, green
     readf, lun, blue
     free_lun, lun
     ;
     ired = where(bnames eq red, count)
     if count ne 1 then begin
       Message, 'The ' + red + ' band was not found in the file ' + infile + '.'
     endif
     ;
     igreen = where(bnames eq green, count)
     if count ne 1 then begin
       Message, 'The ' + green + ' band was not found in the file ' + infile + '.'
     endif
     ;
     iblue = where(bnames eq blue, count)
     if count ne 1 then begin
       Message, 'The ' + blue + ' band was not found in the file ' + infile + '.'
     endif
     ;
     envi_display_bands, [fid, fid, fid], [ired, igreen, iblue], /new
   endfor
  endif
;
end