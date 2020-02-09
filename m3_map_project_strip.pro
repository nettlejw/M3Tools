pro m3_map_project_strip, event
;
;  PURPOSE:  Routine to apply a projection to an m3 image file
;
;-------------------------------------------------------------------------------------------
compile_opt strictarr
;
;  error handling
;
CATCH, error
IF (error NE 0) THEN BEGIN
  catch, /cancel
  ok = m3_error_message()
  return
ENDIF
;
;  get input file 
;
envi_select, fid=infid, dims=dims, pos=pos, title='Select Input File:'
if infid[0] eq -1 then return
;
;  see if input file is a LOC file, if not ask for it
;
envi_file_query, infid, fname=fname, nb=nb, data_type=dt
if strpos(file_basename(fname), 'LOC') gt 0 and nb eq 3 then begin 
  ;
  ;  Input file is LOC (probably)
  ;
  locfid=infid
  ;
endif else begin
  ;
  ;  Input file is not LOC so ask for it
  ;
  envi_select, fid=locfid, /no_dims, /no_spec, /file_only, title='Select LOC File:'
  if locfid[0] eq -1 then return
  ;
endelse
;
;  Ask for output file
;
base = widget_auto_base(title='M3 Projection Tool')
wo = widget_outfm(base, uvalue='outf',/auto)
result = auto_wid_mng(base)
if (result.accept eq 0) then return
if ((result.outf.in_memory) eq 0) then begin
    outfile=result.outf.name
    in_memory=0 
  endif else begin
    mem_check = magic_mem_check(dims=dims,in_memory = result.outf.in_memory, $
                out_dt=dt, nb=nb, out_name = result.outf.name)
    if (mem_check.cancel EQ 1) then return
    in_memory = mem_check.in_memory
    outfile = mem_check.out_name
endelse
;
; set up projection to match the LOC bands (the igm)
;
datum='Moon Sphere 1737.4'
deg_units=envi_translate_projection_units('Degrees')
iproj=envi_proj_create(datum=datum,/geographic,units=deg_units)
;
;  get lat and lon bands 
;
lon=envi_get_data(fid=locfid, dims=dims, pos=0)
lat=envi_get_data(fid=locfid, dims=dims, pos=1)
;
;  figure the center lat and lon
;
minlon=min(lon,max=maxlon)
minlat=min(lat,max=maxlat)
clon=(minlon+maxlon)/2d
clat=(minlat+maxlat)/2d
;
; handle dateline wrapping
;
if(clon gt 180)then clon=clon-360d
help, clon, clat
;
;  output projection parameters
;
lunar_radius_m=1737400d
x0=0d
y0=0d
scale=0.9996d
;
;  set up either polar or TM based on latitude
;
if (min(abs(lat)) ge 70.) then begin
  ;
  print, 'Using Polar Stereographic Projection...'
  type=31
  name='M3 Polar Stereographic'
  params=[lunar_radius_m,lunar_radius_m,clat,clon,x0,y0]
  ;
endif else begin
  ;
  print, 'Using Local Transverse Mercator Projection...'
  type=3
  name='M3 Local TM'
  params=[lunar_radius_m,lunar_radius_m,clat,clon,x0,y0,scale]
  ;
endelse
oproj=envi_proj_create(type=type,params=params,datum=datum, name=name)
;
;  Create the GLT
;
if in_memory eq 0 then begin
  outdir=file_dirname(outfile, /mark_directory)
  outbase=file_basename(outfile)
  dot=strpos(outbase, '.', /reverse_search)
  if dot eq -1 then ext='' else ext=strmid(outbase, dot)
  outbase=file_basename(outfile, ext)
  gltfile=outdir+outbase+'_glt'+ext
endif
envi_doit, 'envi_glt_doit', dims=dims, i_proj=iproj, o_proj=oproj, $
  out_name=gltfile, in_memory=in_memory, r_fid=glt_fid, x_fid=locfid, $
  x_pos=0, y_fid=locfid, y_pos=1
if glt_fid eq -1 then begin
  envi_error, ['Could not create a GLT.']
  return
endif
;
;  apply the glt now
;
envi_doit, 'envi_georef_from_glt_doit', fid=infid, glt_fid=glt_fid, pos=pos, $
  in_memory=in_memory, out_name=outfile, subset=dims
if in_memory eq 1 then envi_file_mng, id=glt_fid, /remove, /delete

;
end
