function m3_wl_lookup, wl, val
  ;
  ;standard compiler directive, forces you to use []'s to denote array subscripts
  ;
  COMPILE_OPT strictarr
  ;
  ;simple (standard) error catching mechanism
  ;
  CATCH, error
  IF (error NE 0) THEN BEGIN
    catch, /cancel
    ok = m3_error_message()
    return, -1
  ENDIF
 ;

  diffs = abs(wl - val)
  posn = (where(diffs eq min(diffs), count))[0]

  case 1 of
   (count eq 1):  ;do nothing, we want this to be the result
   (count gt 1):  begin
         Message, 'More than one wavelength position was found for:  ' + strtrim(string(val),2)
         end
   (count lt 1):  begin
         Message, 'An appropriate M3 wavelength position could not be found for: ' + $
            strtrim(string(val),2)
         end
  endcase

  return, posn

END
