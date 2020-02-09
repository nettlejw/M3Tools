pro m3_utils_disp_band84, event
;
;  PURPOSE:  Lets a user select from a list of opened global data files and
;            displays band 84 in a new window
;
;-------------------------------------------------------------------------------
compile_opt strictarr
;
;  simple (standard) error catching mechanism
;
print
CATCH, error
IF (error NE 0) THEN BEGIN
  catch, /cancel
  ok = m3_error_message()
  return
ENDIF

;
;  select files
;
envi_select, fid=fid, title='Select Global Image', /file_only, /no_spec, /no_dims
if fid[0] eq -1 then return
;
;  check to make sure there's a band 84 to display
;
envi_file_query, fid, nb=nb
if nb lt 84 then begin
  msg = 'Ummm, how do you expect me to display a band 84 when there are '
  msg = msg + 'only ' + strtrim(nb,2) + ' bands in this image? :)'
  message, msg
endif
;
;  display the band
;
envi_display_bands, [fid,fid,fid], [83,83,83], /new 
;
end