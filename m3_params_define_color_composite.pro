pro m3_params_define_color_composite_event, event
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
widget_control, event.top, get_uvalue=info
ptr_params=info.ptr_params
params=*ptr_params

;
case event.id of 
  ; 
  info.red_btn: begin
    ;
    envi_select, fid=fid, title='Select RED Band:', /band_only, pos=pos
    envi_file_query, fid, bnames=bnames
    lbl=bnames[pos]
    params.red_label = lbl
    *ptr_params=params
    ;
    widget_control, info.red_txt, set_value=lbl
    ;
  end  
  ;
  info.green_btn: begin
    ;
    envi_select, fid=fid, title='Select GREEN Band:', /band_only, pos=pos
    envi_file_query, fid, bnames=bnames
    lbl=bnames[pos]
    params.green_label = lbl
    *ptr_params=params
    ;
    widget_control, info.green_txt, set_value=lbl
    ;
  end
  ;
  info.blue_btn: begin
    ;
    envi_select, fid=fid, title='Select BLUE Band:', /band_only, pos=pos
    envi_file_query, fid, bnames=bnames
    lbl=bnames[pos]
    params.blue_label = lbl
    *ptr_params=params
    ;
    widget_control, info.blue_txt, set_value=lbl
    ;
  end
  ;
  info.ok_btn:  begin
    ;
    ;  check to make sure the name of the composite is set
    ;
    widget_control, info.name_txt, get_value=name_text
    if name_text eq '' then begin
      ok=dialog_message('Please enter a name for your composite.')
      return
    endif
    ;
    ;  check to make sure the band names are set
    ;
    if params.red_label eq '' then begin
      ok=dialog_message('Please pick the RED band.')
      return
    endif
    if params.green_label eq '' then begin
      ok=dialog_message('Please pick the GREEN band.')
      return
    endif
    if params.blue_label eq '' then begin
      ok=dialog_message('Please pick the BLUE band.')
      return
    endif
    ;
    ;  store the composite name
    ;
    widget_control, info.name_txt, get_value=comp_name
    params.comp_name = comp_name
    *ptr_params=params
    ;
    ;  destroy widget
    ;
    widget_control, event.top, /destroy
    ;
  end
  ;  
  info.cancel_btn:  begin
    ;
    params.cancel = 1
    widget_control, event.top, /destroy
    ;
  end
  ;
  else: ;do nothing
endcase
;
end



pro m3_params_define_color_composite, event
;
;  allows user to define their own color composite display combo
;
;-----------------------------------------------------------------------------------------------------
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
envi_center, xoff, yoff
tlb=widget_base(row=5, xoffset=xoff, yoffset=yoff, tab_mode=1, title='M3 Parameters')
  sb1=widget_base(tlb,row=4,/frame)
    red_base=widget_base(sb1, row=2,xsize=xs)
      lbl1=widget_label(red_base, value='Select Band to be displayed in Red:',/align_left, xsize=xs)
      sb1a=widget_base(red_base, row=1, xsize=xs)
        red_btn=widget_button(sb1a, value='Choose', tab_mode=0)
        red_txt=widget_text(sb1a, value='', /editable, xsize=52)
    green_base=widget_base(sb1, row=2,xsize=xs)
      lbl2=widget_label(green_base, value='Select Band to be displayed in Green:',/align_left, xsize=xs)
      sb1b=widget_base(green_base, row=1, xsize=xs)
        green_btn=widget_button(sb1b, value='Choose', tab_mode=0)
        green_txt=widget_text(sb1b, value='', /editable, xsize=52)
    blue_base=widget_base(sb1, row=2,xsize=xs)
      lbl3=widget_label(blue_base, value='Select Band to be displayed in Blue:',/align_left, xsize=xs)
      sb1c=widget_base(blue_base, row=1, xsize=xs)
        blue_btn=widget_button(sb1c, value='Choose', tab_mode=0)
        blue_txt=widget_text(sb1c, value='', /editable, xsize=52) 
  sb2=widget_base(tlb, row=3, /frame, xsize=xs)
    name_lbl=widget_label(sb2, value='Enter a name for your composite:',/align_left, xsize=xs)
    sb2a=widget_base(sb2, row=1, xsize=xs)
      name_txt=widget_text(sb2a, value='', /editable, xsize=62)         
  accept_base=widget_base(tlb,row=1,/align_center)
    ok_btn=widget_button(accept_base, value='OK', tab_mode=0)
    cancel_btn=widget_button(accept_base, value='Cancel', tab_mode=0)       
;
widget_control, tlb, /realize
;
params={red_label:'', green_label:'', blue_label:'', comp_name:'', cancel:0}
ptr_params=ptr_new(params)
;
info={red_btn:red_btn, red_txt:red_txt, green_btn:green_btn, green_txt:green_txt, $
      blue_btn:blue_btn, blue_txt:blue_txt, ok_btn:ok_btn, cancel_btn:cancel_btn, $
      name_txt:name_txt, ptr_params:ptr_params}
      
widget_control, tlb, set_uvalue=info       
XMANAGER, 'm3_params_define_color_composite', tlb
;
;  get the params pointer
;
params=*ptr_params
ptr_free, ptr_params
if params.cancel eq 1 then return
;
; get custom color comp directory in prefs object
;
prefs=obj_new('m3_prefs')
ccomp_dir=prefs->get('color_composite_dir')
if strmid(ccomp_dir,0,1,/reverse_offset) ne path_sep() then ccomp_dir=ccomp_dir+path_sep()
;
;  get rid of spaces in the filename & add output directory
;
if strpos(params.comp_name, ' ') ne -1 then begin
  splits=strsplit(params.comp_name, ' ', /extract)  
  n=n_elements(splits)
  comp_name=splits[0]+'_'
  for i=1,n-2 do comp_name=comp_name+splits[i]+'_'
  comp_name=comp_name + splits[n-1]
endif else comp_name = params.comp_name
ccomp_file=ccomp_dir + comp_name + '.txt'
;
;  write the band names to the file
;
openw, lun, ccomp_file, /get_lun
printf, lun, params.red_label
printf, lun, params.green_label
printf, lun, params.blue_label
free_lun, lun
;
;  destroy preferences object
;
obj_destroy, prefs
;
end