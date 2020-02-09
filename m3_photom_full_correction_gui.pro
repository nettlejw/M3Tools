pro check_coeffs, info, result
;
;  PURPOSE:  after ok button is pressed, makes sure the table coeffs sum to 1 and put the 
;            correct values into the params pointer
;
;----------------------------------------------------------------------------------------------
compile_opt strictarr
;
;  simple (standard) error catching mechanism
;
CATCH, error
IF (error NE 0) THEN BEGIN
  catch, /cancel
  ok = m3_error_message()
  return
ENDIF
;
result=0
;;
;;  get the coefficients
;;
;widget_control, info.mare_txt, get_value=mare
;widget_control, info.highlands_txt, get_value=highlands
;widget_control, info.ap16_txt, get_value=ap16
;;
;; convert text values to floats
;;
;mare=float(mare)
;highlands=float(highlands)
;ap16=float(ap16)
;;
;if mare+highlands+ap16 ne 1.0 then begin
;  ok=dialog_message('Coefficients do not sum to 1.0, please correct.')
;  return
;endif
;
; get rdn and obs files
;
widget_control, info.inf_txt, get_value=rdn_file
widget_control, info.obsf_txt, get_value=obs_file
;
if rdn_file eq '' then begin
  ok=dialog_message('Please select a radiance file.')
  return
endif
if obs_file eq '' then begin
  ok=dialog_message('Please select an OBS file.')
  return
endif

if ~file_test(rdn_file) then begin
  ok=dialog_message(file_basename(rdn_file)+' could not be found.')
  return
endif
if ~file_test(obs_file) then begin
  ok=dialog_message(file_basename(obs_file)+' could not be found.')
  return
endif
;
; get output root and binary values for deleting files
;
widget_control, info.outroot_txt, get_value=out_root
widget_control, info.outfactor_checkbox, get_value=delete_factors
widget_control, info.outfile_checkbox, get_value=delete_intermediates
if out_root eq '' then begin
  ok=dialog_message('Please select an output root name.')
  return
endif
;
; fill in the params struct
;
ptr_params=info.ptr_params
params=*ptr_params
params.rdn_file=rdn_file
params.obs_file=obs_file
;params.coeffs=[highlands,mare,ap16]
params.coeffs=[0.5,0.5,0.0]  ;substitute a default set for now
params.out_root=out_root
params.delete_factors=delete_factors
params.delete_intermediates=delete_intermediates
*ptr_params=params
;
result=1
;
end

pro m3_photom_full_correction_gui_event, event
;
;  PURPOSE:  Event handler for photometric correction gui
;
;----------------------------------------------------------------------------------------------
compile_opt strictarr
;
;  simple (standard) error catching mechanism
;
CATCH, error
IF (error NE 0) THEN BEGIN
  catch, /cancel
  ok = m3_error_message()
  return
ENDIF
widget_control, event.top, get_uvalue=info

case event.id of 
 info.ok_btn: begin
   ;
   ;  check to make sure coeffs are right
   ;
   check_coeffs, info, result
   ;
   if result eq 1 then widget_control, event.top, /destroy
   ;
 end
 ;  
 info.cancel_btn: begin
   ;
   ptr_params=info.ptr_params
   params=*ptr_params
   params.cancel=1
   *ptr_params=params
   widget_control, event.top, /destroy
   ;
 end
 ;  
 info.help_btn: print, 'Launch help file.'
 ;
 info.inf_btn: begin
   ;
   envi_select, fid=fid, /no_spec, /no_dims, /file_only, title='Radiance File:'
   if fid[0] eq -1 then return
   envi_file_query, fid, fname=fname
   ;
   dirname=file_dirname(fname, /mark_directory)
   basename=file_basename(fname)
   ;
   ;  put selected file in text box
   ;
   widget_control, info.inf_txt, set_value=fname
;   ;
;   ;  handle obs file
;   ;
;   widget_control, info.obsf_txt, get_value=obs_file_name
;   if obs_file_name eq '' then begin
;     if strmid(basename, strlen(basename)-8,8) eq '_RDN.IMG' then begin
;      base=strmid(basename, 0,strlen(basename)-8)
;      obsf_guess=dirname+base+'_OBS.IMG'
;      if file_test(obsf_guess) then begin
;         widget_control, info.obsf_txt, set_value=obsf_guess 
;         if info.obs_fid ne 0L then begin
;           envi_open_file, obsf_guess, r_fid=obs_fid, /no_realize, /no_interactive_query
;           info.obs_fid=obs_fid
;         endif
;      endif else widget_control, info.obsf_txt, set_value=dirname
;      ;
;      guess_len=strlen(obsf_guess)
;      widget_control, info.obsf_txt, set_text_select=[strlen(dirname)+guess_len, 1]  
;      ;  
;     endif else widget_control, info.obsf_txt, set_value=dirname
;   endif
;   ;
;   ;  handle output root
;   ;
;   widget_control, info.outroot_txt, get_value=current_out_root
;   if current_out_root eq '' then begin
;     if strmid(basename, strlen(basename)-8,8) eq '_RDN.IMG' then begin
;       base=strmid(basename, 0,strlen(basename)-8)
;       outroot_guess=dirname+base+'_PHOTOM_'  
;       widget_control, info.outroot_txt, set_value=outroot_guess
;     endif else widget_control, info.outroot_txt, set_value=dirname  
;   endif
   ;
 end
 ;
 info.obsf_btn: begin
   ;
   envi_select, fid=fid, /no_spec, /no_dims, /file_only, title='OBS File:'
   if fid[0] eq -1 then return
   envi_file_query, fid, fname=fname
   ;
   widget_control, info.obsf_txt, set_value=fname
   ;
 end
 ;
 info.outroot_btn:  begin
   ;
   out_root=envi_pickfile(title='Select Output Root:')
   if out_root eq '' then return
   widget_control, info.outroot_txt, set_value=out_root
   ;
 end
 
 ; 
 else: ;do nothing
endcase 
;
end


pro m3_photom_full_correction_gui, event
;
;  PURPOSE:  Sets up a widget to gather all the input info needed for photometric correction
;
;----------------------------------------------------------------------------------------------
compile_opt strictarr
;
;  simple (standard) error catching mechanism
;
CATCH, error
IF (error NE 0) THEN BEGIN
  catch, /cancel
  ok = m3_error_message()
  return
ENDIF
;
;  build widget
;
xs=400
envi_center, xoff, yoff
tlb=widget_base(row=5, xoffset=xoff, yoffset=yoff, tab_mode=1, title='M3 Photometric Correction')
  file_base=widget_base(tlb,row=4,/frame)
    infile_base=widget_base(file_base, row=2,xsize=xs)
      lbl1=widget_label(infile_base, value='Select Radiance file:',/align_left, xsize=xs)
      infile_subbase=widget_base(infile_base, row=1, xsize=xs)
        inf_btn=widget_button(infile_subbase, value='Choose', tab_mode=0)
        inf_txt=widget_text(infile_subbase, value='', /editable, xsize=52)
    obsfile_base=widget_base(file_base, row=2,xsize=xs)
      lbl2=widget_label(obsfile_base, value='Select OBS file:',/align_left, xsize=xs)
      obsfile_subbase=widget_base(obsfile_base, row=1, xsize=xs)
        obsf_btn=widget_button(obsfile_subbase, value='Choose', tab_mode=0)
        obsf_txt=widget_text(obsfile_subbase, value='', /editable, xsize=52)
;  coeff_base=widget_base(tlb, row=4,/frame, xsize=xs+5)
;    coeff_label=widget_label(coeff_base, value='Set correction coefficients:',/align_left)  
;    highlands_base=widget_base(coeff_base, row=1)
;      highlands_txt=widget_text(highlands_base, value='0.5', /editable, xsize=3)
;      highlands_lbl=widget_label(highlands_base, value=': Highlands Table')    
;    mare_base=widget_base(coeff_base, row=1)
;      mare_txt=widget_text(mare_base, value='0.5', /editable, xsize=3)
;      mare_lbl=widget_label(mare_base, value=': Mare Table')
;    ap16_base=widget_base(coeff_base, row=1)
;      ap16_txt=widget_text(ap16_base, value='0.0', /editable, xsize=3)
;      ap16_lbl=widget_label(ap16_base, value=': Apollo Table')       
  outfile_base=widget_base(tlb,row=3,/frame)
    lbl3=widget_label(outfile_base, value='Select Output Root:',/align_left, xsize=xs)
    outfile_subbase1=widget_base(outfile_base, row=1, xsize=xs)
      outroot_btn=widget_button(outfile_subbase1, value='Choose', tab_mode=0)
      outroot_txt=widget_text(outfile_subbase1, value='', /editable, xsize=52)
    outfile_subbase2=widget_base(outfile_base, row=1, xsize=xs)   
      outfile_checkbox=cw_bgroup(outfile_subbase2, ['Delete intermediate files'], /nonexclusive, tab_mode=0) 
      outfactor_checkbox=cw_bgroup(outfile_subbase2, ['Delete correction factors'], /nonexclusive, tab_mode=0)
  accept_base=widget_base(tlb,row=1,/align_center)
    help_btn=widget_button(accept_base, value='Help', tab_mode=0)
    ok_btn=widget_button(accept_base, value='OK', tab_mode=0)
    cancel_btn=widget_button(accept_base, value='Cancel', tab_mode=0)       
;
widget_control, tlb, /realize
;
params={rdn_file:'', obs_file:'', coeffs:[0.5,0.5,0.0], out_root:'', delete_intermediates:0, $
        delete_factors:0, cancel:0}
ptr_params=ptr_new(params)              
;
info={inf_btn:inf_btn, inf_txt:inf_txt, obsf_txt:obsf_txt, obsf_btn:obsf_btn, $
      ;highlands_txt:highlands_txt,  mare_txt:mare_txt, ap16_txt:ap16_txt, $
      outroot_btn:outroot_btn, outroot_txt:outroot_txt, $
      outfile_checkbox:outfile_checkbox, outfactor_checkbox:outfactor_checkbox, help_btn:help_btn, $
      ok_btn:ok_btn, cancel_btn:cancel_btn, ptr_params:ptr_params, obs_fid:0L}
      
widget_control, tlb, set_uvalue=info       
XMANAGER, 'm3_photom_full_correction_gui', tlb
;
; get params, quit if cancel was pressed
;
params=*ptr_params
if params.cancel eq 1 then return
;
; call the engine
;
m3_photom_full_correction_engine, params=params
;
end

