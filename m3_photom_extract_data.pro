pro m3_photom_extract_data, rdnf, obsf, locf, outf, ss, es
;
;
envi_open_file,rdnf, r_fid=rdnfid
envi_file_query, rdnfid, ns=ns, nl=nl, nb=nb, wl=wl
rdnpos = lindgen(nb)
;
envi_open_file,obsf, r_fid=obsfid
envi_file_query, obsfid, bnames=bnames
incidenceb = where(bnames eq 'To-Sun Zenith (deg)',count)
if count eq 0 then message, 'incidence band not found'
emissionb = where(bnames eq 'To-M3 Zenith (deg)', count)
if count eq 0 then message, 'emission band not found'
phaseb = where(bnames eq 'Phase (deg)', count)
if count eq 0 then message, 'incidence band not found'
;
envi_open_file,locfile, r_Fid=locfid
envi_file_query, locfid, bnames=bnames
latb = where(bnames eq 'Latitude', count)
if count eq 0 then message, 'lat band not found'
lonb = where(bnames eq 'Longitude', count)
if count eq 0 then message, 'lon band not found'
;
;
meanrad = fltarr(nb,nl)
;
for idx = 0, nl-1 do begin
  ;
  ;  radiance
  ;
  rdnslice = envi_get_slice(fid=rdnfid, line=idx, pos=rdnpos, xs=ss, xe=es, /bil)
  meanrad[*,idx] = total(rdnslice,1)/(es - ss + 1)
  ;
  ;  obs
  ;
  i = mean(envi_get_slice(fid=obsfid, line=idx, pos=incidenceb, xs=ss, xe=es, /bil))
  e = mean(envi_get_slice(fid=obsfid, line=idx, pos=emissionb, xs=ss, xe=es, /bil))
  g = mean(envi_get_slice(fid=obsfid, line=idx, pos=phaseb, xs=ss, xe=es, /bil))
  ;
  ;  loc
  ;
  lat = mean(envi_get_slice(fid=locfid, line=idx, pos=latb, xs=ss, xe=es, /bil))
  lon = mean(envi_get_slice(fid=locfid, line=idx, pos=lonb, xs=ss, xe=es, /bil))
  ;
  print, i, e, g, lat, lon, meanrad
   ;
  empty
  wait, 0.0001
endfor
  
envi_file_mng, id=rdnfid, /remove
envi_file_mng, id=obsfid, /remove
envi_file_mng, id=locfid, /remove
;
end
