pro m3_params_cube_wrapper, event
compile_opt strictarr
;
;  PURPOSE:  Allows use of both gui code and engine code in a modular fashion by other programs. Takes 
;            the output of the gui code and feeds it to the engine code.  
;
;-----------------------------------------------------------------------------------------------------
;
;  get the widget event
;
widget_control, event.id, get_uvalue=group
;
;  call the gui
;
m3_params_gui, group, infile, dims, outfile, params_list
if n_elements(outfile) eq 0 then return
;
;  hand off to parameters engine
;
m3_params_engine, infile, dims, outfile, params_list
;
end