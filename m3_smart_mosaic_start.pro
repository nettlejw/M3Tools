pro m3_smart_mosaic_get_mosaic_rule, coefficients
;
;  asks the user for the way in which the mosaic is built (which pixels survive in
;  cases of multiple coverages)
;
;--------------------------------------------------------------------------------------
compile_opt strictarr, hidden
;
;  for now just use the obs band names
;
list= ['To-Sun Azimuth', 'To-Sun Zenith', $
       'To-M3 Azimuth',  'To-M3 Zenith', $
       'Phase', 'To-Sun Path Length', $
       'To-M3 Path Length', 'Facet Slope', $
       'Facet Aspect', 'Facet Cos(i)']
nlist=n_elements(list)
coefficients=intarr(nlist)
;
;  use auto-managed widget for now
;
tlb=widget_auto_base(title='M3 Smart Mosaic')
sb1=widget_base(tlb,/row)
wsl=widget_slist(tlb,list=list,prompt='Select Rule to use:',uvalue='slist',/auto)
sb2=widget_base(tlb,/row)
text='Then choose to use either minimum or maximum for this rule:'
wtxt=widget_label(sb2,value=text, xsize=225)
sb3=widget_base(tlb,/row)
list=['Minimum','Maximum']
wtog=widget_toggle(sb3,uvalue='toggle',list=list, /auto)
result=auto_wid_mng(tlb)
if result.accept eq 0 then return
;
; set coefficients according to user preference (need to be -1 for max and +1 for min
;
coefficients[result.slist] = -1
if result.toggle eq 0 then coefficients=coefficients * (-1)
;
end

pro m3_smart_mosaic_pick_time_range_and_region_type, region_type, op_selected
;
; 1.  Lets user pick an optical period, then time ranges (from index files) in play
; 2.  Lets user decide to draw roi or specify lac chart
;
; *note: for now assume #1 is all files in OP1B, so only implement #2
;
;------------------------------------------------------------------------------------
compile_opt strictarr,hidden
;
;  use auto-managed widget for now
;
tlb=widget_auto_base(title='M3 Smart Mosaic')
sb=widget_base(tlb,/column)
op_list=['OP1A','OP1B','OP2A','OP2B','OP2C']
wm=widget_menu(sb,prompt='Pick OP to mosaic from:',list=op_list,uvalue='op_sel',/excl,/auto)
sb1=widget_base(tlb,/row)
text='Select the way you want to do your mosaic:'
wtxt=widget_label(sb1,value=text, xsize=225)
sb2=widget_base(tlb,/row)
list=['Draw an ROI','Select a LAC Chart(s)']
wtog=widget_toggle(sb2,uvalue='toggle',list=list, /auto)
result=auto_wid_mng(tlb)
if result.accept eq 0 then return
;
case result.toggle of
0:region_type='user_drawn'
1:region_type='lac_based'
endcase
;
op_selected=op_list[result.op_sel]
;
end

pro m3_smart_mosaic_pick_lacs_event, event
;
;  get state structure containing all the info we need
;
widget_control, event.top, get_uvalue=pinfo
info=*pinfo
;
;  handle events based on which widget id we receive
;
case event.id of
  info.okID:  begin
    ;
    ; check to make sure at least one lac is on
    ;
    mask=info.mask
    idx=where(mask gt 0,count)
    if count eq 0 then begin
      msg='You did not select any lac charts.  Try again or press cancel.'
      ok=dialog_message(msg,/error)
      return
    endif
    ;
    ;  store current list of selected lac charts in a pointer
    ;
    widget_control, info.bgroup, get_value=bgroup_vector
    info.lacs_chosen = bgroup_vector
    *pinfo=info
    ;
    ;  destroy widget
    ;
    widget_control, event.top, /destroy
    ;
    end
  info.cancelID:  begin
    ;
    ;  cleanup
    ;
    widget_control, event.top, /destroy
    end
  info.bgroup:  begin
    ;
    ; get new list of what's selected
    ;
    widget_control, info.bgroup, get_value=index
    selected=where(index eq 1,count)+1
    ;
    ;  update draw widget
    ;
    if count gt 0 then begin
      ;
      ;  calculate new mask
      ;
      bp=info.bp
      mask=bp*0
      for c=0,count-1 do begin
        addr=where(bp eq selected[c])
        mask[addr]=255
      endfor
      ;
      ;  update state pointer and display
      ;
      info.mask=mask
      *pinfo=info
      update_lac_display_image, pinfo
      ;
    endif
    ;
    end
  info.dw:  begin
    ;
    ; only process "button up" events
    ;
    if event.type eq 1 then begin
       mask=info.mask
       x=event.x
       y=event.y
       ;
       ; turning on or turning off?
       ;
       current=mask[x,y]
       if current eq 255 then newval=0
       if current eq 0 then newval=1
       ;
       ;  get LAC clicked on and all pixels to fill
       ;
       lac_clicked=info.bp[x,y]
       idx=where(info.bp eq lac_clicked,count)
       if count eq 0 then message, 'NO LAC Chart found.'
       mask[idx]=255*newval
       ;
       ;  update the button group
       ;
       widget_control, info.bgroup, get_value=bgroup_vector
       bgroup_vector[lac_clicked-1]=newval
       widget_control, info.bgroup, set_value=bgroup_vector
       ;
       ;  update info structure
       ;
       info.mask = temporary(mask)
       *pinfo=info
       ;
       ;  display new image
       ;
       update_lac_display_image, pinfo
       ;
    endif
    ;
    end
  else: ;do nothing
endcase
;
end

pro update_lac_display_image, pinfo
;
;  handles updating the draw widget
;
;  grab state structure
;
info=*pinfo
mask=info.mask
cbg=info.cbg
cbg=cbg[*,*,0]
;
; blend
;
alpha=0.5
red=byte((mask>cbg)*alpha + (1.0-alpha)*cbg)
disp_img=[[[red]],[[cbg]],[[cbg]]]
;
; update info
;
info.disp_img=disp_img
*pinfo=info
;
; display
;
widget_control, info.dw, get_val=draw_wid
wset,draw_wid
tv, disp_img, true=3
;
end

pro m3_smart_mosaic_pick_lacs, lac_list
;
;  hardcoded paths to change
;
start_dir=filepath('', root_dir=m3_programrootdir(), subdir=['resources', 'smart_mosaic'])
if strmid(start_dir,0,1,/reverse_offset) ne path_sep() then start_dir=start_dir+path_sep()
cbgf=start_dir+'lac_option_cbg_w_lac_labels'
bpf=start_dir+'lac_option_backplane'
;
;  set display size for draw widget
;
xds=720
yds=360
;
; open and display labeled cbg
;
envi_open_file, cbgf, r_fid=cbg_fid, /no_realize
envi_file_query, cbg_fid,ns=cns,nl=cnl,data_type=cdt
envi_file_mng,id=cbg_fid,/remove
cbg_full=make_array(cns,cnl,type=cdt)
openr,lun,cbgf,/get_lun
readu,lun,cbg_full
free_lun,lun
cbg_full=reverse(cbg_full,2)  ;reverse image to match IDL Origin
cbg=rebin(cbg_full,xds,yds)
;
;  read in lac index backplane
;
envi_open_file, bpf, r_fid=bp_fid, /no_realize
envi_file_query, bp_fid, ns=bpns, nl=bpnl, data_type=bpdt
envi_file_mng,id=bp_fid,/remove
bp_full=make_array(bpns,bpnl,type=bpdt)
openr,lun,bpf,/get_lun
readu,lun,bp_full
free_lun,lun
bp=rebin(bp_full,xds,yds)
;
;  lac indices
;
lac_names=strtrim(indgen(144)+1,2)
for i = 0,98 do lac_names[i]='0'+lac_names[i]
for i = 0,8  do lac_names[i]='0'+lac_names[i]
;
;  realize widget
;
tlb=widget_base(title='M3 Smart Mosaic',column=1, /base_align_center,xoffset=xoff, yoffset=yoff)
dw=widget_draw(tlb,xsize=xds,ysize=yds, /button_events)
bgroup=cw_bgroup(tlb,lac_names,column=12,/nonexclusive)
;bgroup=widget_menu(tlb,list=lac_names, rows=12)
slb=widget_base(tlb, column=2)
okID=widget_button(slb,value='OK', xsize=45)
cancelID=widget_button(slb,value='Cancel',xsize=45)
widget_control, tlb, /realize
;
disp_img=[[[cbg]],[[cbg]],[[cbg]]]
widget_control,dw,get_value=draw_wid
wset, draw_wid
tv, disp_img, true=3
;
;  set up info structure to hold all the state info, register event handler
;
cbg=[[[cbg]],[[cbg]],[[cbg]]]
info= {  cbg:cbg, $
         bp:bp, $
         lac_list:0, $
         lacs_chosen:intarr(144),$
         bgroup:bgroup, $
         dw:dw, $
         okID:okID, $
         cancelID:cancelID, $
         disp_img:disp_img, $
         mask:bp*0 $
      }
pinfo=ptr_new(info)
widget_control, tlb, set_uvalue=pinfo
xmanager, 'm3_smart_mosaic_pick_lacs', tlb
;
; display list of lac charts selected
;
info=*pinfo
lacs_chosen=info.lacs_chosen
idx=where(lacs_chosen eq 1,count)
if count gt 0 then lacs_in_play=idx+1
lac_list=idx+1
;
ptr_free, pinfo
;
end

pro m3_smart_mosaic_get_user_mask_event, event
compile_opt strictarr, hidden
;
;CATCH, error
;IF (error NE 0) THEN BEGIN
;  catch, /cancel
;  ok = m3_error_message()
;  return
;ENDIF
;
widget_control, event.top, get_uvalue=pressed_cancel
widget_control, event.id, get_value=ButtonValue
if ButtonValue eq 'OK' then widget_control, event.top, /destroy
if ButtonValue eq 'Cancel' then begin
   *pressed_cancel=1
   widget_control, event.top, /destroy
endif
;
end

pro m3_smart_mosaic_get_user_mask, maskf, roi_id
;
;  lets the user draw an ROI based on a CBG display
;
;-----------------------------------------------------------------------------------
compile_opt strictarr, hidden
;
;  error handling
;
;CATCH, error
;IF (error NE 0) THEN BEGIN
;  catch, /cancel
;  ok = m3_error_message()
;  return
;ENDIF
;
;  hard coded paths to update as necessary
;
start_dir=filepath('', root_dir=m3_programrootdir(), subdir=['resources', 'smart_mosaic'])
cbgf=start_dir + 'raw_cbg_extended_24deg_rebin_10x'
maskf=filepath('smart_mosaic_mask.img', /tmp)
open=0  ;leave the files open or not
;
;  open clementine background file
;
envi_open_file, cbgf, r_fid=cbg_fid
envi_file_query, cbg_fid, ns=ns, nl=nl
dims=[-1,0,ns-1,0,nl-1]
map_info=envi_get_map_info(fid=cbg_fid)
mc=map_info.mc
;
; display cbg
;
envi_display_bands, cbg_fid, 0, /new
all_dgn=envi_get_display_numbers()
dgn=all_dgn[n_elements(all_dgn)-1]
;
;  draw GUI that gets user instructions and tells us ROI has been drawn
;
cr=string(13b)
text=cr
text=text+'  1.  Create on ROI on the display just opened.'+cr
text=text+'      Use any of the standard ENVI ROI methods.'+cr+cr
text=text+'  2.  Press OK when you are done.'+cr+cr
text=text+'  3.  In the next dialog box you will enter the'+cr
text=text+'      rest of the mosaic parameters.'+cr+cr+cr
envi_center,xoff,yoff
tlb=widget_base(title='M3 Smart Mosaic',column=1, /base_align_center,xoffset=xoff, yoffset=yoff)
wl=widget_label(tlb,value=text, xsize=250, ysize=150,/align_left, /frame)
slb=widget_base(tlb, column=2)
ok=widget_button(slb,value='OK', xsize=45)
cancel=widget_button(slb,value='Cancel',xsize=45)
widget_control, tlb, /realize
pressed_cancel=ptr_new(0)
widget_control, tlb, set_uvalue=pressed_cancel
xmanager, 'm3_smart_mosaic_get_user_mask', tlb
if *pressed_cancel then goto, cleanup
;
;  get the ROI the user just drew
;
roi_ids=envi_get_roi_ids(fid=cbg_fid, roi_names=roi_names)
n_roi=n_elements(roi_ids)
if n_roi gt 1 then begin
  ;
  ;  they made more than one ROI, ask which to use
  ;
  tlb=widget_auto_base(title='ROI Selection')
  prompt='You created more than one ROI.  Select the one to use.'
  ws=widget_slist(tlb, list=roi_names, prompt=prompt, uvalue='index', /auto)
  result=auto_wid_mng(tlb)
  roi_id=roi_ids[result.index]
  ;
endif else roi_id = roi_ids
;
;  get roi pixels, check to make sure there are some to use
;
roi_addr=envi_get_roi(roi_id)
if roi_addr[0] eq -1L then goto, cleanup ;no pixels to process
np=n_elements(roi_addr)
;
;  get ROI bounding box
;
pts=array_indices([ns,nl],roi_addr,/dimensions)
s=pts[0,*]
l=pts[1,*]
maxs=max(s,imaxs,min=mins,subscript_min=imins)
maxl=max(l,imaxl,min=minl,subscript_min=iminl)
;
; xstart and ystart
;
x0=s[imins]
y0=l[iminl]
;
;  create mask
;
mns=maxs-mins+1
mnl=maxl-minl+1
mask=bytarr(mns,mnl)
;
;  figure offset and set roi pixels on
;
x=s-x0
y=l-y0
mask[x,y]=1
;
; update UL geo point
;
envi_convert_file_coordinates,cbg_fid,x0,y0,xmap,ymap,/to_map
mc[2]=xmap
mc[3]=ymap
map_info.mc=mc
;
; write mask to file, set up header
;
openw,lun,maskf,/get_lun
writeu,lun,mask
free_lun, lun
def_stretch=envi_default_stretch_create(/linear, val1=0.0, val2=1.0)
envi_setup_head,fname=maskf,ns=mns,nl=mnl,nb=1,offset=0,data_type=1,interleave=0,$
    xstart=x0,ystart=y0,def_stretch=def_stretch,map_info=map_info,bnames='Mask Band',$
    /write,open=keyword_set(open)
;
; clean up
;
cleanup:
envi_close_display, dgn
if ~keyword_set(open) then envi_file_mng, id=cbg_fid, /remove
ptr_free, pressed_cancel
;
end



pro m3_smart_mosaic_build_glt,igm,lac_sl,lac_el,ns_igm,iproj,oproj,x0_mos,y0_mos,ns_mos,nl_mos,ps,gltf,$
                              ulo,ss_glt,es_glt,sl_glt,el_glt
;
; build an m3 glt in the grid space of the mosaic
;
; figure how big a glt this file will make in the output grid
;
; get the edge pixels in clockwise order
;
ns=ns_igm
nl_used=lac_el-lac_sl+1
edge_lon=dblarr(2l*ns_igm+(nl_used-2)*2l)
edge_lat=dblarr(2l*ns_igm+(nl_used-2)*2l)
;
ptr=0l
;
t=igm[*,0:1,lac_sl]
edge_lon[ptr]=t[*,0]
edge_lat[ptr]=t[*,1]
ptr=ptr+ns_igm
;
for i=0l,nl_used-3 do begin
  ;
  t=igm[[0,ns_igm-1],0:1,i+1+lac_sl]
  edge_lon[ptr]=t[1,0]
  edge_lat[ptr]=t[1,1]
  edge_lon[2l*ns_igm+(nl_used-2)*2l-1-i]=t[0,0]
  edge_lat[2l*ns_igm+(nl_used-2)*2l-1-i]=t[0,1]
  ptr=ptr+1
  ;
endfor
;
t=igm[*,0:1,lac_el]
ptr=ns_igm+nl_used-2
edge_lon[ptr]=t[*,0]
edge_lat[ptr]=t[*,1]
;
; convert them to grid s and l
;
envi_convert_projection_coordinates,edge_lon,edge_lat,iproj,edge_x,edge_y,oproj
edge_s=(edge_x-x0_mos)/ps
edge_l=(y0_mos-edge_y)/ps
;
nso=es_glt-ss_glt+1
nlo=el_glt-sl_glt+1
dxs=ps*lindgen(nso)
dys=dblarr(nso)
dxl=0d
dyl=-ps
x0o=ulo[0]
y0o=ulo[1]
rotation=0d
;
; build the output lookup table images that will be used for
; the creation of the geocoded imagery file
;
luts=intarr(nso,nlo)
lutl=intarr(nso,nlo)
dxim=fltarr(nso,nlo)
dyim=fltarr(nso,nlo)
;
sptr=lindgen(ns)+1
;
for i=lac_sl,lac_el do begin
  ;
  ; get the lat and lon for this in line
  ;
  t=igm[*,0:1,i]
  lon=reform(t[*,0])
  lat=reform(t[*,1])
  neg_lon=where(lon gt 180d,n_neg_lon)
  if(n_neg_lon gt 0)then lon[neg_lon]=lon[neg_lon]-360d
  ;
  ; convert to glt s and l
  ;
  envi_convert_projection_coordinates,lon,lat,iproj,x,y,oproj
  t[0,0]=x-x0o
  t[0,1]=y-y0o
  ;
  ; see which fit
  ;
  nptrs=long(t[*,0]/ps)
  nptrl=long(-t[*,1]/ps)
  val=where(nptrs ge 0 and nptrs lt nso and nptrl ge 0 and nptrl lt nlo,nval)
  ;
  ; place the points if any fit
  ;
  if(nval gt 0)then begin
    ;
    ptr=nptrs[val]+nso*nptrl[val]
    luts[ptr]=sptr[[val]]
    lutl[ptr]=i+1
    dxim[ptr]=float(t[val,0])
    dyim[ptr]=float(t[val,1])
    ;print,i,nval,n_elements(uniq(nptrs,sort(nptrs)))
    ;
  endif
  ;
endfor
;
; write the luts,lutl and dxim,dyim files to disk
; to get them out of memory, before pixel infilling
;
; write the luts, lutl, and dx and dy files
;
openw,un1,/get,gltf
for i=0l,nlo-1 do writeu,un1,luts[*,i],lutl[*,i]
free_lun,un1
temp_glt=bytarr(nso,nlo)
for i=0l,nlo-1 do temp_glt[0,i]=luts[*,i] gt 0
;
openw,un1,/get,gltf+'_tmp'
;
dxhalf_pixel=(dxs(1)+dxl)/2
dyhalf_pixel=(dys(1)+dyl)/2
;
for i=0l,nlo-1 do begin
  ;
  t=dxim(*,i) ne 0
  ;
  writeu,un1,float(t*(dxim(*,i)-(dxs+i*dxl+dxhalf_pixel))),$
             float(t*(dyim(*,i)-(dys+i*dyl+dyhalf_pixel)))
endfor
;
free_lun,un1
;
luts=0b
lutl=0b
dxim=0b
dyim=0b
;
; figure the pixels that make up the boundary or boundaries of the in-image area(s)
;
; loop over output lines and do the pixel infilling
; using a 3*3 mask for nearest neighbor finding,
; on each output line that has data:
;   1) find the gaps that need filling
;   2) loop over gap pixels
;   3) use the mask to find nearest valid pixel
;   4) infill the lut file (with negative flag set)
;
; build the 3*3 masks of rotated integer dx and dy
;
idx=[[-1,0,1],[-1,0,1],[-1,0,1]]*ps
idy=[[1,1,1],[0,0,0],[-1,-1,-1]]*ps
;rdx=float(cos(-rotr)*idx-sin(-rotr)*idy)
;rdy=float(sin(-rotr)*idx+cos(-rotr)*idy)
rdx=float(idx)
rdy=float(idy)
;
; build the 7*7 masks of rotated distances
;
idx7=intarr(7,7)
for i=0,6 do idx7(0,i)=indgen(7)-3
idy7=intarr(7,7)
for i=0,6 do idy7(0,i)=intarr(7)-3+i
idx7=idx7*ps
idy7=idy7*ps
rdx7=idx7
rdy7=idy7
;
openu,un1,/get,gltf
openr,un2,/get,gltf+'_tmp'
bil2=assoc(un1,intarr(nso,2))
bil3=assoc(un2,fltarr(nso,2))
;
; build and fill the 3-line buffers of dx,dy and luts,lutl values
;
lutsbuff=intarr(nso,3,/no)
lutlbuff=intarr(nso,3,/no)
dxbuff=fltarr(nso,3,/no)
dybuff=fltarr(nso,3,/no)
;
; allow for glt images shorter than 3 lines long
;
max_read_buff_lines=min([3,nlo])
;
for i=0,max_read_buff_lines-1 do begin
  t=bil2(i)
  lutsbuff(0,i)=t(*,0)
  lutlbuff(0,i)=t(*,1)
  t=bil3(i)
  dxbuff(0,i)=t(*,0)
  dybuff(0,i)=t(*,1)
endfor
;
; define left and right pointers to data swath, it needs some
; handholding to avoid raggedy edges
;

;
; build the mask for this polygon in the map space
;
out_mask=bytarr(nso,nlo)
oroi=obj_new('idlanroi',edge_s-ss_glt,edge_l-sl_glt)
out_mask=oroi->computemask(mask_rule=2,dimensions=[nso,nlo],pixel_center=[0.5,0.5])
obj_destroy,oroi
out_mask=out_mask gt 0
;
; now scan out_mask and build nump,sno,lno,nseg
;
; first pass through and just get a total segment count
; by filling the nseg vector
;
nseg=intarr(nlo)
for i=0l,nlo-1 do begin
  ta=fix(out_mask(*,i) gt 0)
  tb=shift(ta,1)
  tb(0)=0
  tc=ta-tb
  n_new=total(tc eq 1)
  if(ta(0) eq 1)then n_new=n_new+1
  nseg(i)=n_new
endfor
tot_nseg=total(nseg)
;
; build nump,sno,lno for each output segment
;
nump=intarr(tot_nseg)
sno=intarr(tot_nseg)
lno=lonarr(tot_nseg)
ptr=0l
;
for i=0l,nlo-1 do begin
  ta=fix(out_mask(*,i) gt 0)
  tb=shift(ta,1)
  tb(0)=0
  tc=ta-tb
  seg_start=where(tc eq 1,n_seg_start)
  if(n_seg_start gt 0)then begin
    if(ta(0) eq 1)then begin
      seg_start=[0,seg_start]
      n_seg_start=n_seg_start+1
    endif
    sno(ptr)=seg_start
    lno(ptr)=replicate(i,n_seg_start)
    for j=0,n_seg_start-1 do begin
      td=ta(seg_start(j):*)
      temp=where(td ne td(0),n_temp)
      if(n_temp eq 0)then begin
        nump(ptr)=n_elements(td)
        ptr=ptr+1
      endif else begin
        nump(ptr)=min(temp)
        ptr=ptr+1
      endelse
    endfor
  endif else begin
    if(ta(0) eq 1)then begin
      sno(ptr)=0
      lno(ptr)=i
      temp=where(ta ne ta(0),n_temp)
      if(n_temp eq 0)then begin
        nump(ptr)=n_elements(ta)
        ptr=ptr+1
      endif else begin
        nump(ptr)=min(temp)
        ptr=ptr+1
      endelse
    endif
  endelse
endfor
;
; loop over output lines, finding gaps and filling them
;
no3by3=0l
no7by7=0l
for i=1l,nlo-2 do begin
  ;
  ; skip empty lines
  ;
  if(nseg(i) gt 0)then begin
    ;
    ; read in the luts,lutl data for this line
    ; and find the blanks that need filling
    ;
    t=bil2(i)
    segptr=where(lno eq i)
    for l=0l,nseg(i)-1 do begin
      bs=t(*,0)
      lp=sno(segptr(l))
      rp=lp+nump(segptr(l))-1
      blank=where(bs(lp:rp) eq 0,nblank)+lp
      ;
      ; loop over blanks, if any, and fill them
      ;
      if(nblank gt 0)then begin
        for j=0l,nblank-1 do begin
          b=blank(j)
          if(b gt 0 and b lt nso-1)then begin
            dx=(rdx+dxbuff(b-1:b+1,*))^2
            dy=(rdy+dybuff(b-1:b+1,*))^2
            ds=dx+dy
            val=where(lutsbuff(b-1:b+1,*) gt 0,nval)
            if(nval gt 0)then begin
              nnval=min(ds(val),nnptr)
              nnptrs=(val(nnptr) mod 3)+b-1
              nnptrl=val(nnptr)/3
              t(b,*)=-[lutsbuff(nnptrs,nnptrl),lutlbuff(nnptrs,nnptrl)]
            endif else begin
              no3by3=no3by3+1l
              lpz=(b-3)>0
              rpz=(b+3)<(nso-1)
              tpz=(i-3)>0
              bpz=(i+3)<(nlo-1)
              ssz=lpz-b+3
              slz=tpz-i+3
              nsz=rpz-lpz+1
              nlz=bpz-tpz+1
              zbuffs=intarr(nsz,nlz)
              zbuffl=intarr(nsz,nlz)
              zbuffdx=fltarr(nsz,nlz)
              zbuffdy=fltarr(nsz,nlz)
              for k=tpz,bpz do begin
                tz=bil2(lpz:rpz,*,k)
                zbuffs(0,k-tpz)=tz(*,0)
                zbuffl(0,k-tpz)=tz(*,1)
                tz=bil3(lpz:rpz,*,k)
                zbuffdx(0,k-tpz)=tz(*,0)
                zbuffdy(0,k-tpz)=tz(*,1)
              endfor
              dx=(rdx7(ssz:ssz+nsz-1,slz:slz+nlz-1)+zbuffdx)^2
              dy=(rdy7(ssz:ssz+nsz-1,slz:slz+nlz-1)+zbuffdy)^2
              ds=dx+dy
              val=where(zbuffs gt 0,nval)
              if(nval gt 0)then begin
                nnval=min(ds(val),nnptr)
                nnptrs=(val(nnptr) mod nsz)
                nnptrl=val(nnptr)/nsz
                t(b,*)=-[zbuffs(nnptrs,nnptrl),zbuffl(nnptrs,nnptrl)]
              endif else begin
                no7by7=no7by7+1l
              endelse
            endelse
          endif
        endfor
      endif
    endfor
    bil2(i)=t
  endif
  ;
  ; JWB 7/11/5 3
  ;
  if(i lt nlo-2)then begin
    lutsbuff(0,0)=lutsbuff(*,1:2)
    lutlbuff(0,0)=lutlbuff(*,1:2)
    ;t2=bil2(i+1)
    t2=bil2(i+2)
    lutsbuff(0,2)=t2(*,0)
    lutlbuff(0,2)=t2(*,1)
    dxbuff(0,0)=dxbuff(*,1:2)
    dybuff(0,0)=dybuff(*,1:2)
    ;t2=bil3(i+1)
    t2=bil3(i+2)
    dxbuff(0,2)=t2(*,0)
    dybuff(0,2)=t2(*,1)
  endif
endfor
;
free_lun,un1,un2
file_delete,gltf+'_tmp'
;
if(no3by3 gt 0)then begin
  ;
  print,'number of no 3*3 '+strtrim(no3by3,2)
  print,'number of no 7*7 '+strtrim(no7by7,2)
  ;
endif
;
; build ENVI header for GLT file
;
ops=[ps,ps]
mc=[0,0,ulo[0],ulo[1]]
rotation=0
map_info=envi_map_info_create(proj=oproj,datum=datum,ps=ops,mc=mc,rotation=rotation)
bnames=['sample number lookup','line number lookup']
descrip='AIG M3 Ortho GLT'
envi_setup_head,fname=gltf,ns=nso,nl=nlo,nb=2,interleave=1,data_type=2,offset=0,$
  bnames=bnames,descrip=descrip,map_info=map_info,/write
;
end

pro m3_smart_mosaic_build_rule,glt,ss_glt,es_glt,sl_glt,el_glt,contrib_line_range,ns_in,$
                    loc_bil,obs_bil,temps,rule_null,coefs,rule
;
; build a smart mosaic rule image
;
; build the raw format rule for the contributing line range
;
nl_contrib=contrib_line_range[1]-contrib_line_range[0]+1
rule_raw=fltarr(ns_in,nl_contrib)
for i=0l,nl_contrib-1 do rule_raw[0,i]=obs_bil[*,*,i+contrib_line_range[0]]#coefs
;
; build the null mosaic grid rule image
;
ns_glt=es_glt-ss_glt+1
nl_glt=el_glt-sl_glt+1
rule=fltarr(ns_glt,nl_glt)+rule_null
;
; pass the raw rule through the glt to the mosaic grid image
;
buff=fltarr(ns_glt)+rule_null
;
for i=0l,nl_glt-1 do begin
  ;
  raw_s=reform(long(abs(glt[*,0,i])))-1
  raw_l=reform(long(abs(glt[*,1,i])))-1-contrib_line_range[0]
  val=where(glt[*,0,i] ne 0,n_val)
  if(n_val gt 0)then begin
    ;
    buff[val]=rule_raw[raw_s[val]+ulong64(raw_l[val])*ns_in]
    rule[0,i]=buff
    if(min(buff[val]) eq max(buff[val]) and n_val gt 300)then print,crap
    buff[*]=rule_null
    ;
  endif
  ;
endfor
;
end

pro m3_smart_mosaic_figure_contrib,max_line_range,proj_loc,proj_out,x0_out,y0_out,ps_out,ns_out,nl_out,loc_bil,ns_in,$
                                   contrib_line_range,this_line,ss_glt,es_glt,sl_glt,el_glt,ulo
;
; figure if a loc file contributes to the mosaic
; if it does figfure the line range and the mosaic grid space subset in play
;
; set up variables
;
nl=max_line_range[1]-max_line_range[0]+1
this_line=lonarr(nl)
ss_glt=ns_out+1
es_glt=-1
sl_glt=nl_out+1
el_glt=-1
contrib_line_range=[-1l,-1l]
;
; loop over possible lines in play for this file
;
for i=0,nl-1 do begin
  ;
  ; get lon and lat values
  ;
  t=loc_bil[*,0:1,i+max_line_range[0]]
  lon=t[*,0]
  lat=t[*,1]
  ;
  ; convert to +/- 180 lon
  ;
  neg=where(lon gt 180,n_neg)
  if(n_neg gt 0)then lon[neg]=lon[neg]-360d
  ;
  ; convert them to output s and l
  ;
  envi_convert_projection_coordinates,lon,lat,proj_loc,x,y,proj_out
  s=long((x-x0_out)/ps_out)
  l=long((y0_out-y)/ps_out)
  ;
  in=where(s ge 0 and s lt ns_out and l ge 0 and l lt nl_out,n_in)
  this_line[i]=n_in
  ;
  ; drop any out of the mosaic and update ss,es,sl,el
  ;
  if(n_in gt 0)then begin
    ;
    if(n_in ne ns_in)then begin
      ;
      s=s[in]
      l=l[in]
      ;
    endif
    ;
    ss_glt=ss_glt<min(s)
    es_glt=es_glt>max(s)
    sl_glt=sl_glt<min(l)
    el_glt=el_glt>max(l)
    ;
  endif
  ;
endfor
;
; if some contribute figure line range and mosaic grid subset
;
if(total(this_line) gt 0)then begin
  ;
  ; clip it to the actual boundary of the mosaic
  ;
  if(ss_glt lt 0)then ss_glt=0
  if(es_glt ge ns_out)then es_glt=ns_out-1
  if(sl_glt lt 0)then sl_glt=0
  if(el_glt ge nl_out)then el_glt=nl_out-1
  ulo=[x0_out+ps_out*ss_glt,y0_out-sl_glt*ps_out]
  ;
  contrib_line_range[0]=min(where(this_line gt 0),max=t)+max_line_range[0]
  contrib_line_range[1]=t+max_line_range[0]
  ;
endif
;
end

pro m3_smart_mosaic_sort_filenames_by_time,files,order,files_sorted
;
; sort m3 filename by time and write to a new file
;
; get the number of input files
;
nf=n_elements(files)
;
; sort them based on time
;
short_files=strarr(nf)
for i=0l,nf-1 do begin
  ;
  ; strip each file to its date start
  ;
  last_fslash=strpos(files[i],'/',/reverse_search)
  last_bslash=strpos(files[i],'\',/reverse_search)
  last_slash=max([last_fslash,last_bslash])
  ;
  short_files[i]=strmid(files[i],last_slash+4)
  ;
endfor
;
order=sort(short_files)
files_sorted=files[order]
;
end

pro smart_mosaic_lac_mask,lac_list,lac_index,mask,mask_map_info
;
; build a mask of one or more lac sheets
;
nlac=n_elements(lac_list)
mask=lac_index eq lac_list[0]
for i=1l,nlac-1 do mask=mask or (lac_index eq lac_list[i])
;
ps=[1d,1]
mc=[0d,0d,-180d,90d]
datum='Moon Sphere 1737.4'
mask_map_info=envi_map_info_create(/geographic,ps=ps,mc=mc,datum=datum)
;
end

pro smart_mosaic_find_lac_list,lac_index,mask,mask_map_info,lac_list
;
; given a simple cylindrical mask file
; figure which lac sheets the mask-on pixels touch
; returning a list of those lac indices
;
; get lon and lat of on pixels from mask
;
t=size(mask)
ns_mask=t[1]
nl_mask=t[2]
;
on=where(mask gt 0,n_on)
ps=(mask_map_info.ps)[0]
x0=(mask_map_info.mc[2])
y0=(mask_map_info.mc[3])
on_lon=(on mod ns_mask)*ps+x0
on_lat=y0-(on/ns_mask)*ps
;
; handle date line wrapping from extended mask
;
; jwb
;
; build map in the form of lac_index with on pixels set
;
ns_map=360l
nl_map=180l
map=bytarr(ns_map,nl_map)
map_x0=-180d
map_y0=90d
map_ps=1d
s_map=long((on_lon-map_x0)/map_ps)
l_map=long((map_y0-on_lat)/map_ps)
map[l_map*ns_map+s_map]=1
;
; insert check to see if ROI contained more than one blob. JWN.
;
lr=label_region(map)
blobs=where(lr gt 0)
regions=map[blobs]
ureg=uniq(regions, sort(regions))
blob_count=n_elements(ureg)
if blob_count ne 1 then begin
  print, 'blob_count=', blob_count
  lac_list = -1
  envi_error, 'The ROI you entered contained more than one blob.  It must contain only one.'
  return
endif
;
; figure the unique set of lac files that are touched
;
map=map*lac_index
lac_list=map[where(map ne 0)]
lac_list=lac_list[sort(lac_list)]
lac_list=lac_list[uniq(lac_list)]
;
end

pro smart_mosaic_get_extent_proj_grid,region_type,mask,mask_map_info,lac_list,lac_extents_file,$
                                  lonlat_extent,proj_out,ns_out,nl_out,ps_out,x0_out,y0_out
;
; given a simple cylidrical mask file
; figure the lon/lat extent of the mask-on pixels,
; build a region-centered local tm projection,
; define the mosaic output grid details in the output projection space
;
; if region is a lac_based single lac just use the existing lac projection and grid
;
if(region_type eq 'lac_based' and n_elements(lac_list eq 1))then begin
  ;
  ; just grab existing info on single lac sheet
  ;
  print,'not implemented yet! jwb'
  ;return
  ;
endif
;
; otherwise we need to build the stuff based on the mask
;
;
; figure the lon/lat extent and center
;
t=size(mask)
ns_mask=t[1]
nl_mask=t[2]
;
on=where(mask gt 0,n_on)
ps=(mask_map_info.ps)[0]
x0=(mask_map_info.mc[2])
y0=(mask_map_info.mc[3])
on_lon=(on mod ns_mask)*ps+x0
on_lat=y0-(on/ns_mask)*ps
;
lonlat_extent=dblarr(2,2)
;
minl=min(on_lon,max=maxl)
lonlat_extent[0,0]=minl
lonlat_extent[1,0]=maxl
lon_c=(minl+maxl)/2d
;
minl=min(on_lat,max=maxl)
lonlat_extent[0,1]=minl
lonlat_extent[1,1]=maxl
lat_c=(minl+maxl)/2d
;
; handle dateline wrapping from extended mask
;
if(lon_c gt 180)then lon_c=lon_c-360d
;
; build the local tm projection
;
lunar_radius_m=1737400d

datum='Moon Sphere 1737.4'
x0_tm=0d
y0_tm=0d
scale_tm=0.9996d
params=[lunar_radius_m,lunar_radius_m,lat_c,lon_c,x0_tm,y0_tm,scale_tm]
proj_out=envi_proj_create(type=3,params=params,datum=datum)
;
; convert on pixels lon/lat to the new projection xy
;
mask_proj=mask_map_info.proj
envi_convert_projection_coordinates,on_lon,on_lat,mask_proj,on_x,on_y,proj_out
;
; define the output grid details
; for now we fix the pixel size jwb
;
fixed_ps=140d
ps_out=fixed_ps
;
x0_out=floor(min(on_x)/ps_out)*ps_out
y0_out=ceil(max(on_y)/ps_out)*ps_out
;
ns_out=ceil((max(on_x)-x0_out)/ps_out)
nl_out=ceil((y0_out-min(on_y))/ps_out)
;
end

pro m3_smart_mosaic_build_dirnames, op_selected, coverage_dir, loc_root, obs_root
;
;  puts together directory names that the rest of the code uses
;
;---------------------------------------------------------------------------------
compile_opt strictarr
;
;  old hardcoded values:
;  
;loc_root='D:\joes_coverage\OP1_L1B\B\'
;obs_root='D:\joes_coverage\OP1_L1B\B\'
;coverage_dir='D:\joes_coverage\OP1B_M3_COVERAGE\'
;
;  path to coverage info
;
coverage_root=filepath('', root_dir=m3_programrootdir(), subdir=['resources','smart_mosaic','coverage'])
if strmid(coverage_root,0,1,/reverse_offset) ne path_sep() then coverage_root=coverage_root+path_sep()
coverage_dir=coverage_root+op_selected+path_sep()
;
;  path to l1b files
;
prefs=obj_new('m3_prefs')
l1b_root=prefs->get('archivedir')
obj_destroy, prefs
if l1b_root eq '<undefined>' then begin
  envi_error, 'Your Data Directory preference is not set.  Please set it before using Smart Mosaic.'
  return
endif
l1b_dir=l1b_root+op_selected+path_sep()+'L1B'+path_sep()
loc_root=l1b_dir
obs_root=l1b_dir
;
end


pro m3_smart_mosaic,region_type,lac_list,mask_file,out_root,coefs, op_selected
;
; stub of the smart mosaic tool
;
; hardcode lac_index_file and coverage dir
;
lac_index_file=filepath('lac_index', root_dir=m3_programrootdir(), subdir=['resources','smart_mosaic'])
temp_root=out_root + 'mosaic_temp_'
;
;  build remaining directories the code needs based on which OP was selected
;
m3_smart_mosaic_build_dirnames, op_selected, coverage_dir, loc_root, obs_root
;
;  output files and obs band names
;
glt_file=out_root+'_mos_glt'
rule_file=out_root+'_mos_rule'
obs_list= ['To-Sun Azimuth', 'To-Sun Zenith', $
       'To-M3 Azimuth',  'To-M3 Zenith', $
       'Phase', 'To-Sun Path Length', $
       'To-M3 Path Length', 'Facet Slope', $
       'Facet Aspect', 'Facet Cos(i)']
;
; read in the lac_index
;
openr,un1,/get,lac_index_file
lac_index=bytarr(360,180)
readu,un1,lac_index
free_lun,un1
;
; if user_drawn read in the mask file and get its map_info jwb
;
if(region_type eq 'user_drawn')then begin
  ;
  envi_open_file,mask_file,r_fid=mask_fid
  envi_file_query,mask_fid,ns=ns_mask,nl=nl_mask
  mask_map_info=envi_get_map_info(fid=mask_fid)
  envi_file_mng,id=mask_fid,/remove
  openr,un1,/get,mask_file
  mask=bytarr(ns_mask,nl_mask)
  readu,un1,mask
  free_lun,un1
  ;
endif
;
; for a lac-based region we make a fake mask and map_info to have a single code stream
;
if(region_type eq 'lac_based')then smart_mosaic_lac_mask,lac_list,lac_index,mask,mask_map_info
;
; for a user-drawn region figure which lac sheets are in play
;
if(region_type eq 'user_drawn')then smart_mosaic_find_lac_list,lac_index,mask,mask_map_info,lac_list
if lac_list[0] eq -1 then return  ;fix for ROI's with more than one blob
;
; ***note*** at this point we have region_type, mask, mask_map_info and lac_list all set in
; either region_type case so the two streams converge and are treated as one (mostly)
;
; figure extent, create projection and define output grid
;
smart_mosaic_get_extent_proj_grid,region_type,mask,mask_map_info,lac_list,lac_extents_file,$
                                  lonlat_extent,proj_out,ns_out,nl_out,ps_out,x0_out,y0_out
;
; ***note*** for now we only address a single coverage tree jwb
;
; summarize results to report file and to screen
;
report_file=out_root+'_mos_report.txt'
openw,un10,/get,report_file
print,'m3 mosaic report'
print,systime(0)
printf,un10,'m3 mosaic report'
printf,un10,systime(0)
print,' '
printf,un10,' '
print,'mosaic 3-band glt file :',glt_file
printf,un10,'mosaic 3-band glt file :',glt_file
print,' '
printf,un10,' '
print,'mosaic rule minimization file :',rule_file
printf,un10,'mosaic rule minimization file :',rule_file
print,'obs rule coefficients :'
printf,un10,'obs rule coefficients :'
for i=0l,9 do begin
  ;
  print,obs_list[i],coefs[i],format='(a20,i5)
  ;
endfor
print,' '
printf,un10,' '
;
; loop over lac sheets involved and get total list of all possible files involved
;
n_lac=n_elements(lac_list)
nl_index_total=0l
lac_index_files=strarr(n_lac)
;
print, 'lac index files:'
for i=0l,n_lac-1 do begin
  ;
  ; build lac sheet index file name
  ;
  lac_str=strtrim(string(fix(lac_list[i])),2)
  if(lac_list[i] lt 100)then lac_str='0'+lac_str
  if(lac_list[i] lt 10)then lac_str='0'+lac_str
  lac_index_files[i]=coverage_dir+'GLOBAL/LAC/INDEX/M3_GLOBAL_LAC'+lac_str+'_INDEX_REPORT.TXT'
  ;
  ; count the total lines in all index files
  ;
  nl_index=file_lines(lac_index_files[i])
  nl_index_total=nl_index_total+nl_index
  print, file_basename(lac_index_files[i]), nl_index
  ;
endfor
print, 'total=', nl_index_total
if nl_index_total eq 0 then begin
  envi_error, 'No files were found within the mosaic region.'
  return
endif
;
; read in the index file and convert to file names and
; line ranges (change from 1-based to 0-based)
;
file_list=strarr(nl_index_total)
file_indices=lonarr(nl_index_total)
line_ranges=lonarr(2,nl_index_total)
ptr=0l
;
print,'number of lac sheets touched by region : ',n_lac
printf,un10,'number of lac sheets touched by region : ',n_lac
print,' '
printf,un10,' '
;
for i=0l,n_lac-1 do begin
  ;
  print,'parsing lac index sheet : ',lac_index_files[i]
  printf,un10,'parsing lac index sheet : ',lac_index_files[i]
  ;
  nl_index=file_lines(lac_index_files[i])
  ;
  ; fix for handling the case where LAC chart is empty (index file has 0 lines). JWN.
  ;
  if nl_index eq 0 then continue
  ;
  openr,un1,/get,lac_index_files[i]
  index=strarr(nl_index)
  readf,un1,index
  free_lun,un1
  ;
  for j=0l,nl_index-1 do begin
    ;
    t=strsplit(index[j],' ',/extract)
    file_list[ptr]=t[0]
    file_indices[ptr]=long(t[1])
    line_ranges[0,ptr]=long(t[[6,7]])-1
    ptr=ptr+1l
    ;
  endfor
  ;
endfor
;
print,' '
printf,un10,' '
;
; sort file_list, find unique files and reconcile line ranges to retain max ranges
;
o=sort(file_list)
file_list=file_list[o]
file_indices=file_indices[o]
line_ranges=line_ranges[*,o]
;
uptr=uniq(file_list)
ufiles=file_list[uptr]
n_ufiles=n_elements(ufiles)
;
print,'maximum number of unique files possibly in play : ',n_ufiles
printf,un10,'maximum number of unique files possibly in play : ',n_ufiles
print,' '
printf,un10,' '
;
for i=0l,n_ufiles-1 do begin
  ;
  this_file=where(file_list eq ufiles[i],n_this_file)
  for j=0l,n_this_file-1 do begin
    ;
    line_ranges[0,this_file]=min(line_ranges[0,this_file])
    line_ranges[1,this_file]=max(line_ranges[1,this_file])
    ;
  endfor
  ;
endfor
;
; keep only unique files, indices and ranges and sort them in time order
;
file_list=ufiles
file_indices=file_indices[uptr]
line_ranges=line_ranges[*,uptr]
;
nf=n_elements(file_list)
;
file_list_in=file_list
m3_smart_mosaic_sort_filenames_by_time,file_list_in,order,file_list
file_indices=file_indices[order]
line_ranges=line_ranges[*,order]
;
; setup three-band i*2 mosaic glt and single-band r*4 rule image, fill with zeroes and rule_null
;
mc=[0d,0d,x0_out,y0_out]
ps=[ps_out,ps_out]
datum='Moon Sphere 1737.4'
map_info_out=envi_map_info_create(mc=mc,proj=proj_out,ps=ps,datum=datum)
;
openw,un1,/get,glt_file
glt_bil=assoc(un1,intarr(ns_out,3))
glt_buff=intarr(ns_out,3)
for i=0l,nl_out-1 do glt_bil[i]=glt_buff
bnames=['sample','line','file']
envi_setup_head,fname=glt_file,ns=ns_out,nl=nl_out,nb=3,data_type=2,interleave=1,offset=0,$
                bnames=bnames,map_info=map_info_out,data_ignore_value=0,/write
;
openw,un2,/get,rule_file
rule_bil=assoc(un2,fltarr(ns_out))
rule_null=-9999.
rule_buff=fltarr(ns_out)+rule_null
for i=0l,nl_out-1 do rule_bil[i]=rule_buff
bnames='score'
envi_setup_head,fname=rule_file,ns=ns_out,nl=nl_out,nb=1,data_type=4,interleave=1,offset=0,$
                bnames=bnames,map_info=map_info_out,data_ignore_value=rule_null,/write
;
; loop over the files and build the glt mosaic and rule score images
;
proj_loc=envi_proj_create(/geographic,datum='Moon Sphere 1737.4')
;
print,'determining contributing files'
printf,un10,'determining contributing files'
print,'index, loc file, loc sl, loc el, npix in mos area, npix survived, mos ss, mos es, mos sl, mos el (all 1-based)'
printf,un10,'index, loc file, loc sl, loc el, npix in mos area, npix survived, mos ss, mos es, mos sl, mos el (all 1-based)'
;
for i=0l,nf-1 do begin
  ;
  ; open loc and obs files
  ;
  locf=loc_root+file_list[i]
  obsf=obs_root+strmid(file_list[i],0,strlen(file_list[i])-7)+'OBS.IMG'
  ;
  mode=strmid(file_list[i],2,1)
  if(mode eq 'G')then ns_in=300
  ;
  openr,un3,/get,locf
  loc_bil=assoc(un3,dblarr(ns_in,3))
  openr,un4,/get,obsf
  obs_bil=assoc(un4,fltarr(ns_in,10))
  ;
  ; figure what lines, if any, of this file contribute and
  ; if it does contribute figure the ss,es and sl,el
  ;
  m3_smart_mosaic_figure_contrib,line_ranges[*,i],proj_loc,proj_out,x0_out,y0_out,ps_out,ns_out,nl_out,loc_bil,ns_in,$
                                   contrib_line_range,this_line,ss_glt,es_glt,sl_glt,el_glt,ulo
  ;
  ; if it contributes see if it updates the mosaic glt
  ;
  if(min(contrib_line_range) ge 0)then begin
    ;
    ; build the local glt
    ;
    sl=contrib_line_range[0]
    el=contrib_line_range[1]
    tstr=strtrim(string(i+1),2)
    if(i+1 lt 10)then tstr='0'+tstr
    if(i+1 lt 100)then tstr='0'+tstr
    gltf=temp_root+tstr+'_glt'
    ;
    m3_smart_mosaic_build_glt,loc_bil,sl,el,ns_in,proj_loc,proj_out,x0_out,y0_out,ns_out,nl_out,ps_out,gltf,$
                              ulo,ss_glt,es_glt,sl_glt,el_glt
    ;
    ; read in the glt and delete glt file and hdr
    ;
    openr,un5,/get,gltf
    ns_glt=es_glt-ss_glt+1
    nl_glt=el_glt-sl_glt+1
    glt=intarr(ns_glt,2,nl_glt,/nozero)
    readu,un5,glt
    free_lun,un5
    file_delete,gltf,gltf+'.hdr'
    ;
    ; build the local rule image
    ;
    ;coefs=[0d,0,0,0,1,0,0,0,0,0]
    m3_smart_mosaic_build_rule,glt,ss_glt,es_glt,sl_glt,el_glt,contrib_line_range,ns_in,$
                    loc_bil,obs_bil,temps,rule_null,coefs,rule
    ;
    ; apply to mosaic where blank or rule is better met
    ;
    this_line_used=lonarr(nl_glt)
    ;
    for j=0l,nl_glt-1 do begin
      ;
      ; grab current mos glt and mos rule
      ;
      glt_buff=glt_bil[j+sl_glt]
      rule_buff=rule_bil[j+sl_glt]
      ;
      ; replace any voids with new data and also
      ; replace any old data with new data where the rule is now better met
      ;
      rule_sub=rule_buff[ss_glt:es_glt]
      use_new=where((rule_sub eq rule_null or rule_sub gt rule[*,j]) and (rule[*,j] ne rule_null),n_use_new)
      this_line_used[j]=n_use_new
      ;
      if(n_use_new gt 0)then begin
        ;
        rule_buff[use_new+ss_glt]=reform(rule[use_new,j])
        glt_buff[use_new+ss_glt,0]=reform(glt[use_new,0,j])
        glt_buff[use_new+ss_glt,1]=reform(glt[use_new,1,j])
        glt_buff[use_new+ss_glt,2]=file_indices[i]
        ;
      endif
      ;
      ; put these updated buffers back into the file
      ;
      glt_bil[j+sl_glt]=glt_buff
      rule_bil[j+sl_glt]=rule_buff
      ;
    endfor
    ;
    ; report contribution
    ;
    n_pix_valid=total(this_line)
    n_pix_used=total(this_line_used)
    print,file_indices[i],' ',locf,contrib_line_range+1,n_pix_valid,n_pix_used,$
          [ss_glt,es_glt,sl_glt,el_glt]+1,format='(i6,2a,8i10)'
    printf,un10,file_indices[i],' ',locf,contrib_line_range+1,n_pix_valid,n_pix_used,$
          [ss_glt,es_glt,sl_glt,el_glt]+1,format='(i6,2a,8i10)'
    wait,.001
    empty
    ;
  endif
  ;
  free_lun,un3,un4
  ;
endfor
;
print,systime(0)
printf,un10,systime(0)
;
free_lun,un1,un2,un10
;
;  add basenames and indices to glt header. JWN.
;
bn=strmid(file_list,0,18)
envi_open_file, glt_file, r_fid=gfid, /no_realize, /no_interactive_query
envi_assign_header_value, fid=gfid, keyword='index_list', value=file_indices
envi_assign_header_value, fid=gfid, keyword='basename_list', value=bn
envi_write_file_header, gfid
;envi_file_mng, id=gfid, /remove  ;commented out so glt is in avail bands list after routine completes
;
end

pro m3_smart_mosaic_start, event
;
;  handles all the user input data and calls the backend code
;
;-------------------------------------------------------------
compile_opt strictarr
;
; get region_type (this will also get the time range eventually)
;
m3_smart_mosaic_pick_time_range_and_region_type, region_type, op_selected
if n_elements(region_type) eq 0 then return
;
; launch the appropriate gui
;
case region_type of
  'lac_based':begin
     m3_smart_mosaic_pick_lacs, lac_list
     if lac_list[0] eq 0 then return
     end
  'user_drawn': begin
     m3_smart_mosaic_get_user_mask, maskf, roi_id
     if n_elements(roi_id) eq 0 then return
     end
endcase
;
;  Get mosaic rule coefficients
;
m3_smart_mosaic_get_mosaic_rule, coefficients
if max(coefficients) eq 0 and min(coefficients) eq 0 then return
;
; get the output root names
;
cd,current=current_dir
out_root=dialog_pickfile(title='Pick Output Root Name:',path=current_dir)
if out_root eq '' then return
;
;  save roi to file
;
if region_type eq 'user_drawn' then envi_save_rois, out_root+'_user_drawn_roi.roi', roi_id
;
; build the 3-band glt and report files
;
m3_smart_mosaic,region_type,lac_list,maskf,out_root,coefficients, op_selected
;
end

