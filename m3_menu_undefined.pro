PRO M3_menu_UNDEFINED, event, subteams
  ;
  ;PURPOSE:  this is a placeholder routine so that menu items can be created without the procedures that 
  ;          handle them being in place.  Inspired by CRISM CAT by Shannon Pelkey
  ;
  ;standard compiler directive, forces you to use []'s to denote array subscripts (hide it with 'hidden')
  ;
  COMPILE_OPT strictarr, hidden
  ;
  ;simple (standard) error catching mechanism
  ;
  CATCH, error
  IF (error NE 0) THEN BEGIN
    catch, /cancel
    ok = m3_error_message()
    return
  ENDIF
  ;
  MESSAGE, 'This functionality has not been implemented yet.', /noname
  ;
END