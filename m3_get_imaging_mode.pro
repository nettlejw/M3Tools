function m3_get_imaging_mode, input, fid=fid, long_str=long_str
compile_opt strictarr, hidden
;
On_error, 2 ;if an error occurs, return to calling program
;
;  see if input is a filename or an fid
;
case size(input, /type) of 
  3: begin ;input is fid
       fid=input
       envi_file_query,fid, fname=infile
     end 
  7: begin ;input is filename
       infile=input
       ;don't open the file yet, wait until we're sure we need it
     end
endcase
;
;  this will be our return value
;
guess = ''
;
;  1. look at file name first.  Was M3 naming scheme followed? If so,
;  just return the third character.  if not, continue on
;
basename = file_basename(infile)
if (stregex(basename, '^M3(G|T)200(8|9)',/boolean) eq 1) then guess = strupcase(strmid(basename,2,1))
;
;  2.  look at the number of bands
;
if guess eq '' then begin
  if n_elements(fid) eq 0 then envi_open_file, infile, r_fid=fid,/no_realize,/no_interactive_query
  if fid gt 0 then begin
    envi_file_query, fid, nb=nb
    case nb of
      85:guess='G'
      86:guess='G'
      260:guess='T'
      else:guess=''
    endcase
  endif  
endif
;
;  3.  Have to just ask the user
;
if guess eq '' then begin
  base = widget_auto_base(title='M3')  
  list = ['Global', 'Target']  
  sb = widget_base(base, /row)  
  prompt='Choose input file type:'
  wt = widget_toggle(sb, uvalue='toggle', prompt=prompt,list=list, /auto)  
  result = auto_wid_mng(base)  
  if (result.accept eq 0) then return, ''  ;this should never happen (hopefully!)  
  guess = (['G','T'])[result.toggle]  
endif
;
; should have a guess by now or user would've cancelled the widget, so handle
; long_str keyword and return
;
if keyword_set(long_str) then begin
  if guess eq 'G' then return, 'global'
  if guess eq 'T' then return, 'target'
endif else return, guess
;
end