pro m3_figure_and_apply_flip_and_subset,ifile,ofile
;
; figure which of the four flip time windows an m3 file is in
; then apply the correct spatial subsetting and smaple/line flipping
;
; spatial subsetting is fixed in the unflipped data:
;
;   G ss:es:ns 9:312:304 0-based
;
;   T ss:es:ns 18:625:608 0-based
;
; flipping depends on date:
;
;   1: mission start            through 2008 DEC 18 04:08:00 UTC
;     descending forwards - no sample flip, no line flip
;
;   2: 2008 DEC 18 04:08:01 UTC through 2009 MAR 15 14:10:00 UTC
;     descending backwards - yes sample flip, no line flip
;
;   3: 2009 MAR 15 14:10:01 UTC through 2009 JUN 18 02:00:00 UTC
;     ascending backwards - no sample flip, yes line flip
;
;   4: 2009 JUN 18 02:00:01 UTC through mission end
;     ascending forwards - yes sample flip, yes line flip
;
; preprocess name to strip any path info
;
last_slash=max(where(byte(ifile) eq 47b or byte(ifile) eq 92b))
ifile_short=strmid(ifile,last_slash+1)
;print,'input file name : ',ifile
;
; get flip flag : 1,2,3 or 4
;
; parse ifle name for date and time and convert to julday
;
year=fix(strmid(ifile_short,3,4))
month=fix(strmid(ifile_short,7,2))
day=fix(strmid(ifile_short,9,2))
hour=fix(strmid(ifile_short,12,2))
minute=fix(strmid(ifile_short,14,2))
second=fix(strmid(ifile_short,16,2))
jd_ifile=julday(month,day,year,hour,second,minute)
;
; compare to julday values for flip times
;
jd_flips=dblarr(5)
jd_flips[0]=julday(11,16,2008,00,00,00)
jd_flips[1]=julday(12,18,2008,04,08,00)
jd_flips[2]=julday(03,15,2009,14,10,00)
jd_flips[3]=julday(06,18,2009,02,00,00)
jd_flips[4]=julday(08,17,2009,00,00,00)
flip=max(where(jd_flips lt jd_ifile))+1
if(flip eq 0 or flip eq 5)then begin
  ;
  envi_error,'***error*** image time outside m3 mission window : '
  return
  ;
endif
flip_str=strarr(4)
flip_str[0]='descending forwards - no sample flip, no line flip'
flip_str[1]='descending backwards - yes sample flip, no line flip'
flip_str[2]='ascending backwards - no sample flip, yes line flip'
flip_str[3]='ascending forwards - yes sample flip, yes line flip'
rstr=flip_str[flip-1]
;print,'flip mode : ',flip,flip_str[flip-1]
;
; get file mode : G or T
; and set ss, es, ns (0-based)
;
mode=strmid(ifile_short,2,1)
if(mode ne 'G' and mode ne 'T')then begin
  ;
  envi_error,'***error*** mode ne T or G'
  return
  ;
endif
if(mode eq 'G')then begin
  ;
  ss=9l
  es=312
  ;
endif else begin
  ;
  ss=18
  es=625
  ;
endelse
ns=es-ss+1
;print,'m3 mode, ss, es, ns (0-based) : ',mode,ss,es,ns
;
; check to see if input file is a L0.IMG, if so handle the frame headers
;
last6=strmid(ifile_short,strlen(ifile_short)-6)
if(last6 eq 'L0.IMG')then begin
  ;
  rstr=[rstr,'detected L0.IMG input, handling frame headers']
  if(mode eq 'T')then nb_extra=1 else nb_extra=2
  ;
endif else begin
  ;
  rstr=[rstr,'detected generic input, not handling L0.IMG frame headers']
  nb_extra=0
  ;
endelse
;
; get ifile specifics then open and assoc to the bil input file
;
envi_open_file,ifile,r_fid=fid
envi_file_query,fid,ns=ns_in,nl=nl_in,nb=nb_in,interleave=interleave,data_type=data_type,wl=wl, $
  offset=offset, descrip=descrip, bnames=bnames, xstart=xstart, ystart=yxstart
map_info=envi_get_map_info(fid=fid)
envi_file_mng,id=fid,/remove
if(interleave ne 1)then begin
  ;
  envi_error,'***error*** interleave must be BIL'
  return
  ;
endif
if(data_type ne 2 and data_type ne 4)then begin
  ;
  envi_error,'***error*** data_type not I*2 or R*4'
  return
  ;
endif
;
openr,un1,/get,ifile
if(data_type eq 2)then bil=assoc(un1,intarr(ns_in,nb_in+nb_extra))
if(data_type eq 4)then bil=assoc(un1,fltarr(ns_in,nb_in+nb_extra))
;
; open output file
;
sflip=reverse(indgen(ns))
openw,un2,/get,ofile
;
;  set up progress bar
;
envi_report_init, rstr, base=progbar, title='Creating flip/subset image'
envi_report_inc, progbar, nl_in
;
;  add wavelengths if the input file does not already have them
;
help, wl
print, wl[0]
if wl[0] eq -1 then begin
  m3_read_wl_info, gwl=gwl
  wl=gwl
endif

;
;  loop to create proper subset and flip image
;
if(flip le 2)then begin
  ;
  for i=0L,nl_in-1 do begin
    ;
    envi_report_stat, progbar, i, nl_in
    t=bil[ss:es,nb_extra+1:nb_extra+nb_in-1,i]
    if(flip eq 1)then writeu,un2,t else writeu,un2,t[sflip,*]
    ;
  endfor
  ;
endif else begin
  ;
  for i=nl_in-1l,0L,-1 do begin
    ;
    envi_report_stat, progbar, nl_in-i, nl_in
    t=bil[ss:es,nb_extra+1:nb_extra+nb_in-1,i]
    if(flip eq 3)then writeu,un2,t else writeu,un2,t[sflip,*]
    ;
  endfor
  ;
endelse
;
;  close files and progress bar
;
envi_report_init, base=progbar, /finish
free_lun,un1,un2
;
; create a nominal envi hdr for the output
;
envi_setup_head,fname=ofile,ns=ns,nl=nl_in,nb=85,offset=0,data_type=data_type,wl=wl,$
  interleave=interleave,map_info=map_info,descrip=descrip,xstart=xstart,ystart=ystart, $
  bnames=bnames, /write
;
end