pro m3_utils_read_isis, event, infile
;
;  ask for input file name if not supplied
;
if n_elements(infile) eq 0 then $
  infile = dialog_pickfile(title='Select ISIS file...')
if infile eq '' then return
;
;  read header text, which is the first 1024 bytes of the isis file
;
hdrlen = 1024
hdr = bytarr(hdrlen)
openr, lun, infile, /get_lun
readu, lun, hdr
free_lun, lun
;
;  turn header text into lines of strings
;
cr = where(hdr eq 13, count) ;this is actually a vertical tab apparently
if count eq 0 then message, 'no returns found.'
lines = strarr(count)
for i = 0, count - 1 do begin
  istart = (cr[i-1>0] + 2 )*(i gt 0)
  istop  = cr[i]-1
  lines[i]=strtrim(string(hdr[istart:istop]),2)
endfor
;
;  For now assume byte_order=1, not sure how to read this info from the isis
;  file itself
;
byte_order=1
;
;  get interleave
;
idx= where(stregex(lines, '^AXES_NAME',/boolean), count)
if count eq 0 then message, 'could not determine interleave.'
line = lines[idx]
pair = strsplit(line, '=', /extract)
value = strtrim(pair[1],2)
case value of
 '(SAMPLE,LINE,BAND)':interleave=0
 '(SAMPLE,BAND,LINE)':interleave=1
 '(BAND,SAMPLE,LINE)':interleave=2
 else: message, 'could not determine interleave.'
endcase
;
; get dimensions
;
idx= where(stregex(lines, '^CORE_ITEMS',/boolean), count)
if count eq 0 then message, 'could not determine dimensions.'
line = lines[idx]
pair = strsplit(line, '=', /extract)
value = strtrim(pair[1],2)
value = strmid(value, 1, strlen(value) - 2) ;remove parenthesis
dims = long(strsplit(value, ',', /extract))
case interleave of
  0: begin
       ns = dims[0]
       nl = dims[1]
       nb = dims[2]
     end
  1: begin
       ns = dims[0]
       nl = dims[2]
       nb = dims[1]
     end
  2: begin
       ns = dims[1]
       nl = dims[2]
       nb = dims[0]
     end
endcase
;
; get data type
;
idx= where(stregex(lines, '^CORE_ITEM_BYTES',/boolean), count)
if count eq 0 then message, 'could not determine data type.'
line = lines[idx]
pair = strsplit(line, '=', /extract)
value = fix(strtrim(pair[1],2))
case value of
  1:dt=0
  2:dt=1
  4:dt=4
  else: message, 'could not determine data type.'
endcase
;
;  check to make sure dimensions equal file size
;
fsize=(file_info(infile)).size
if fsize ne (ns*nl*nb*value+hdrlen) then message, 'gathered info does not reconcile with file size.'
;
;  try to read wavelengths from m3 routines
;
m3_read_wl_info, twl=twl, gwl=gwl
if n_elements(gwl) gt 0 then begin
  if nb eq n_elements(twl) then wl=twl
  if nb eq n_elements(gwl) then wl=gwl
  if nb eq 86 then wl = [0.0d, gwl]
endif
;
;  set up header
;
envi_setup_head, fname=infile, ns=ns, nl=nl, nb=nb, data_type=dt, offset=hdrlen, $
  interleave=interleave, byte_order=byte_order, wl=wl, /write, /open
;
end
