function m3_file_test, theFile, no_warning=no_warning, notified=notified
   compile_opt strictarr, hidden
   
   ;this function is to be used with output file widgets via the FUNC keyword
   ;to WIDGET_OUTF() or WIDGET_OUTFM().  It checks to see if a user selected an already
   ;existing file in an output file selection dialog and prompts the user if the file
   ;is to be overwritten.

   ;include this so that we can make this a recursive function
   ;
   forward_function m3_file_test

   file_exists = file_test(theFile)
   if file_exists eq 0 then begin
      no_warning = 1
      notified = 0
      return, 1
    endif else begin
      message = file_basename(theFile) + ' exists. Overwrite?'
      yn = strupcase(dialog_message(message, /question))
      case yn of
       'YES':  begin
          no_warning = 1
          notified = 1
          return, 1
          end
       'NO':  begin
          newfile = dialog_pickfile(title = 'Select Output file')
          ok = m3_file_test(newfile)
          ;no_warning = 0
          ;notified = 0
          ;return, 0
          end
      endcase

   endelse
end
