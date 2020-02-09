pro m3_smart_mosaic_build_mosaic, event
;
;  PURPOSE:  Second half of smart mosaic tool.  This half builds the mosaic using the glt 
;            created in the first half.  
;
;---------------------------------------------------------------------------------------------
compile_opt strictarr
;
;
;  simple (standard) error catching mechanism
;
;CATCH, error
;IF (error NE 0) THEN BEGIN
;  catch, /cancel
;  ok = m3_error_message()
;  return
;ENDIF
;
;  get data directory preference
;
prefs=obj_new('m3_prefs')
raw_root=prefs->get('archivedir')
obj_destroy, prefs
if raw_root eq '<undefined>' then begin
  envi_error, ['You have not set your (Archive)Data Directory Preference.', $
               'Please do that before using Smart Mosaic.']
  return
endif
;
;  get glt file
;
envi_select, fid=fid, /file_only, title='Select GLT File:', /no_spec, /no_dims
if fid[0] eq -1 then return
envi_file_query, fid, fname=glt_file



;
;  widget for input parameters
;
ftype_list=['ARFL', 'RDN', 'OBS', 'Other']
tlb=widget_auto_base(title='M3 Smart Mosaic')
;wo1=widget_outf(tlb, prompt='Pick 3 band GLT:', uvalue='gltf', /auto)
;wo2=widget_outf(tlb, prompt='Pick raw file root dir:', uvalue='raw',/directory, /auto)
wm=widget_menu(tlb, list=ftype_list, prompt='Select file type to mosaic:',uvalue='sel',/exclusive,/auto)   
wo = widget_outf(tlb, prompt='Pick mosaic file name:', func='m3_file_test', uvalue='outf', /auto)
result = auto_wid_mng(tlb)  
if (result.accept eq 0) then return  
;glt_file=result.gltf
;raw_root=result.raw
out_file=result.outf
;
;  second widget, if necessary, to specify file type
;
ftype_chosen=result.sel
n_list=n_elements(ftype_list)
if ftype_chosen eq n_list - 1 then begin
  tlb2=widget_auto_base(title='M3 Smart Mosaic')
  ws=widget_string(tlb2,uvalue='tstr',prompt='Specify file type (abbr.):',/auto)
  result=auto_wid_mng(tlb2)
  if result.accept eq 0 then return
  ftype=result.tstr     
endif else ftype=ftype_list[ftype_chosen]
;
; read file indices and basenames from glt header
;
envi_open_file,glt_file,r_fid=fid_glt
index_names=envi_get_header_value(fid_glt, 'basename_list')
index=envi_get_header_value(fid_glt, 'index_list', /long)
n_index=n_elements(index)
;
; assoc to the glt file and get map info
;
envi_file_query,fid_glt,ns=ns_glt,nl=nl_glt,nb=nb_glt,data_type=data_type,interleave=interleave
map_info=envi_get_map_info(fid=fid_glt)
openr,un1,/get,glt_file
glt_bil=assoc(un1,intarr(ns_glt,nb_glt))
;
; parse it for the pixel count of each index
; index must be complete and 1-based in file above
;
index_count=lonarr(n_index)
;
for i=0l,nl_glt-1 do begin
  ;
  t=glt_bil[*,2,i]
  val=where(t ne 0,n_val)
  ;
  if(n_val gt 0)then begin
    ;
    tval=t[val]
    tval=tval[sort(tval)]
    uval=tval[uniq(tval)]
    nuval=n_elements(uval)
    ;
    ;for j=0l,nuval-1 do index_count[uval[j]-1]=index_count[uval[j]-1]+total(tval eq uval[j])
    for j=0l,nuval-1 do index_count[where(index eq uval[j])]=index_count[where(index eq uval[j])]+total(tval eq uval[j])
    ;
  endif
  ;
endfor
;
; reduce scope to only those files that are referenced by the mosaic glt
;
ref=where(index_count gt 0,n_ref)
print,'number of unique files referenced by the mosaic glt : ',n_ref
if n_ref eq 0 then begin
  envi_error, 'No M3 files from the selected OP fall into the mosaic.'
  return
endif
;
; reconcile the files used against those in the raw dir and
; warn on any missing files
;
raw_exists=bytarr(n_ref)
raw_files=strarr(n_ref)
;
recurse_pattern='*'+ftype+'.IMG'
for i=0l,n_ref-1 do begin
  ;
  ; fix to allow recursive search through subdirectories JWN
  ; raw_file=file_search(raw_root+strmid(index_names[ref[i]],0,19)+'*ARFL.IMG',count=count)
  ; 
  raw_file=file_search(raw_root,index_names[ref[i]]+recurse_pattern,count=count)
  raw_exists[i]=count
  raw_files[i]=raw_file
  print,i+1,index[ref[i]],raw_exists[i],' ',raw_file
  ;
endfor
;
raw_present=where(raw_exists eq 1,n_raw_present)
raw_missing=where(raw_exists eq 0,n_raw_missing)
raw_multiple=where(raw_exists gt 1,n_raw_multiple)
;
if(n_raw_multiple gt 0)then begin
  ;
  print,'***error***, raw files have multiple instances '
  for i=0l,n_raw_multiple-1 do print,raw_multiple[i]+1,index[ref[raw_multiple[i]]],' ',index_names[ref[raw_multiple[i]]]
  stop
  ;
endif
;
if(n_raw_missing gt 0)then begin
  ;
  print,'***warning***, raw files missing, continuing with those present '
  for i=0l,n_raw_missing-1 do print,raw_missing[i]+1,index[ref[raw_missing[i]]],' ',index_names[ref[raw_missing[i]]]
  ;
endif
;
if(n_raw_present eq 0)then begin
  ;
  print,'***error***, no referenced raw files are present '
  stop
  ;
endif
;
; subset to only those we can use
;
raw_files=raw_files[raw_present]
index=index[ref[raw_present]]
ref=ref[raw_present]
;
; get details on each file
;
n_raw=n_elements(raw_files)
raw_fids=lonarr(n_raw)
raw_ns=lonarr(n_raw)
raw_nl=lonarr(n_raw)
raw_nb=lonarr(n_raw)
raw_dt=intarr(n_raw)
nso=ns_glt
nlo=nl_glt
;
for i=0,n_raw-1 do begin
  ;
  envi_open_file,raw_files[i],r_fid=fid_raw
  envi_file_query,fid_raw,ns=nsraw,nl=nlraw,nb=nbraw,data_type=data_type_raw,interleave=interleave_raw,$
  bnames=bnames,wl=wl,fwhm=fwhm
  envi_file_mng,id=fid_raw,/remove
  ;
  if(interleave_raw ne 1 and nbraw gt 1)then begin
    print,'***raw file must be BIL format or single band***'
    return
  endif
  ;
  if(i gt 0 and nbraw ne raw_nb[0])then begin
    print,'***raw files must all have the same number of bands***'
    return
  endif
  ;
  if(i gt 0 and data_type_raw ne raw_dt[0])then begin
    print,'***raw files must all have the same data type***'
    return
  endif
  ;
  raw_fids[i]=fid_raw
  raw_ns[i]=nsraw
  raw_nl[i]=nlraw
  raw_nb[i]=nbraw
  raw_dt[i]=data_type_raw
  ;
endfor
;
; open the input mosaic glt and output ort file
; for direct idl access
;
openw,un3,/get,out_file
;
; loop over the raw files
;
n_placed=0
for i=0,n_raw-1 do begin
  ;
  openr,un2,/get,raw_files[i]
  ;
  if(raw_dt[i] eq 1)then begin
    raw=assoc(un2,bytarr(nsraw,nbraw))
    obuff=bytarr(nso,nbraw)
    out=assoc(un3,bytarr(nso,nbraw))
  endif else begin
    if(raw_dt[i] eq 2)then begin
      raw=assoc(un2,intarr(nsraw,nbraw))
      obuff=intarr(nso,nbraw)-9999
      out=assoc(un3,intarr(nso,nbraw))
    endif else begin
      if(raw_dt[i] eq 3)then begin
        raw=assoc(un2,lonarr(nsraw,nbraw))
        obuff=lonarr(nso,nbraw)-9999
        out=assoc(un3,lonarr(nso,nbraw))
      endif else begin
        if(raw_dt[i] eq 4)then begin
          raw=assoc(un2,fltarr(nsraw,nbraw))
          obuff=fltarr(nso,nbraw)-9999
          out=assoc(un3,fltarr(nso,nbraw))
        endif else begin
          if(raw_dt[i] eq 5)then begin
            raw=assoc(un2,dblarr(nsraw,nbraw))
            obuff=dblarr(nso,nbraw)-9999
            out=assoc(un3,dblarr(nso,nbraw))
          endif else begin
            if(raw_dt[i] eq 12)then begin
              raw=assoc(un2,uintarr(nsraw,nbraw))
              obuff=uintarr(nso,nbraw)
              out=assoc(un3,uintarr(nso,nbraw))
            endif else begin
              print,'***raw file must be byte, int, uint, long, float or double***'
              return
            endelse
          endelse
        endelse
      endelse
    endelse
  endelse
  if(nbraw eq 1)then obuff=reform(obuff,nso,1)
  ;
  ; for each raw file
  ; loop over lines building the
  ; output from the input, as directed by the look up tables
  ;
  rstr=['Input GLT File: '+glt_file,'Input Raw File: '+raw_files[i],'Output File: '+out_file]
  envi_report_init,rstr,title='M3 AIG Apply GLT',base=base
  envi_report_inc,base,nlo
  ;
  for j=0l,nlo-1 do begin
    ;
    envi_report_stat,base,i,nlo
    empty
    wait,0.000001
    ;
    ; if it is not the first file read in the previous data to update
    ;
    if(i gt 0)then obuff=out[j]
    ;
    ; fill new points
    ;
    t=glt_bil[j]
    t1=abs(t[*,0:1])-1
    t2=t[*,2]
    val=where(t1[*,0] ge 0 and t2 eq index[i],nval)
    n_placed=n_placed+nval
    if(nval gt 0)then begin
      for k=0,nval-1 do obuff[val[k],0]=reform(raw[t1[val[k],0],*,t1[val[k],1]],1,nbraw)
    endif
    ;
    ; write it back out
    ;
    out[j]=obuff
    ;
    ; if it is the first file, re-zero obuff
    ;

    if(i eq 0)then if(raw_dt[i] gt 1 and raw_dt[i] ne 12)then obuff[*]=-9999 else obuff[*]=0b
    ;
  endfor
  print,n_placed
  ;
  envi_report_init,base=base,/finish
  free_lun,un2
  ;
endfor
;
; 
free_lun,un1,un3
;envi_file_mng,id=fid_glt,/remove
envi_setup_head,fname=out_file,ns=nso,nl=nlo,nb=nbraw,interleave=1,$
                data_type=raw_dt[0],offset=0,descrip='M3 AIG Apply GLT Result',$
                map_info=map_info,bnames=bnames,wl=wl,fwhm=fwhm,data_ignore_value=-9999.,/write, /open
;
end