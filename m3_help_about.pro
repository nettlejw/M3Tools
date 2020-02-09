pro m3_help_about_event, event
compile_opt strictarr
;
;  PURPOSE:  Event handler for the "About" window.
;
;---------------------------------------------------------------------------------------------------
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
widget_control, event.id, get_value=ButtonValue
if ButtonValue eq 'OK' then widget_control, event.top, /destroy
end

pro m3_help_about, event
compile_opt strictarr
;
; PURPOSE:  Displays the Help, About window, which in turn tells you the version of m3tools you're
;           using.
;
;--------------------------------------------------------------------------------------------------
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
;  get the version info
;
version=m3_utils_get_version()
;;
;;  get ip address
;;
;idl_version=float(strmid(!version.RELEASE, 0, strpos(!version.RELEASE, '.', /reverse_search)))
;if idl_version ge 6.4 then begin
;  oUrl = OBJ_NEW('IDLnetUrl')  
;  oUrl->SetProperty, timeout=15 ;die if no response in 15 sec
;  ip_addr=string(oUrl->Get(url='http://ifconfig.me/ip', /buffer))
;  obj_destroy, oUrl
;  ip_str='Your IP address is '+ip_addr 
;endif else ip_str=' '
ip_str=' ' ;blank space (don't try to get ip address)
;
;  build label text
;
cr=string(13b)
text=cr + cr + ip_str + cr + cr + cr + cr + 'M3 Tools Version' + cr + cr + version + cr
;
;  construct widget to display it
;
envi_center,xoff,yoff
tlb=widget_base(title='M3Tools',column=1, /base_align_center,xoffset=xoff, yoffset=yoff)
wl=widget_label(tlb,value=text, xsize=250, ysize=200,/align_center, /frame)
slb=widget_base(tlb,row=1,xsize=50)
ok=widget_button(slb,value='OK', xsize=45)
widget_control, tlb, /realize
;
; register event handler
;
xmanager, 'm3_help_about', tlb
end