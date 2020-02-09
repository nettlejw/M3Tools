function m3_params_get_badval, badval, default=default, double=double
;
;  PURPOSE:  this is a simple function that returns the value that parameters
;            should be set to if the parameters encounter a spectrum of all 
;            zeroes or a zero at the wavelength the parameter is using.
;
;            The benefit of using this function is that if we decide to change 
;            what the bad value should be later, we can just change this single
;            function and the rest of the parameters will automatically start
;            using it.
;
;  Parameters:  badval = a value to use other than the default.  Once set, it's copied to a 
;                         common block and thus always used until set again.
;
;   Keywords:   default = use this to override anything in the common block and use the default.
;               double  = make the return value a double instead of a float
;----------------------------------------------------------------------------------------------------
compile_opt strictarr, hidden
common m3p_badval, bad_value
;
def_val=-9999.0d
if ~keyword_set(double) then def_val=float(def_val)
;
if keyword_set(default) then badval=def_val
;
if n_elements(badval) gt 0 then bad_value=badval
;
if n_elements(bad_value) gt 0 then retval=bad_value else begin
  retval=def_val
  bad_value=retval
endelse
;

;
return, retval
end