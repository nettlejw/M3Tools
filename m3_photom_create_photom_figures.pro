
  

pro m3_photom_create_photom_figures
  
  ;
  ;
  plotimage, bytscl(maresli), imgxrange=[400,3000], xtitle = 'Wavelength (nm)', Title = 'Mare', $
   color = fsc_color('black'), background=fsc_color('white'), ytitle = 'Phase Angle (deg.)', $
   xticklen = 0.04, yticklen = 0.04, xthick = 2, ythick = 2,  font = 1, charsize = 1.5 , charthick = 8
  fname = indir + 'phase_plot_mare.png'
  graph = tvrd(/true)
  write_png, fname, graph
  ;
  loadct, 11
  ;
  plotimage, bytscl(highlandssli), imgxrange=[400,3000], xtitle = 'Wavelength (nm)', Title = 'Highlands',$
   color = fsc_color('black'), background=fsc_color('white'), ytitle = 'Phase Angle (deg.)', $
   xticklen = 0.04, yticklen = 0.04, xthick = 2, ythick = 2,  font = 1, charsize = 1.5 , charthick = 8
  fname = indir + 'phase_plot_highlands.png'
  graph = tvrd(/true)
  write_png, fname, graph

  ;
  plotimage, bytscl(ap16sli), imgxrange=[400,3000], xtitle = 'Wavelength (nm)', Title = 'Apollo 16',$
   color = fsc_color('black'), background=fsc_color('white'), ytitle = 'Phase Angle (deg.)', $
   xticklen = 0.04, yticklen = 0.04, xthick = 2, ythick = 2,  font = 1, charsize = 1.5 , charthick = 8
  fname = indir + 'phase_plot_ap16.png'
  graph = tvrd(/true)
  write_png, fname, graph

  ;start the viewer
spectra_view, mfid

;get the base of the widget
envi_reg_base, base=mbase, name='Spectral Library Viewer', /query

;p_data is a pointer to an anonymous structure containing all the library info
widget_control, mbase, get_uvalue=p_data

;fake an event as if we clicked on the fifth spectrum
id = (*p_data).lw  ; list widget ID

for i = 0L, 90L, 5L do begin
  ev = {top:mbase, handler:0L, id:id, index:i}
  spectra_view_event, ev
endfor

  ;start the viewer
spectra_view, hfid

;get the base of the widget
envi_reg_base, base=hbase, name='Spectral Library Viewer', /query

;p_data is a pointer to an anonymous structure containing all the library info
widget_control, hbase, get_uvalue=p_data

;fake an event as if we clicked on the fifth spectrum
id = (*p_data).lw  ; list widget ID

for i = 0L, 90L, 5L do begin
  ev = {top:hbase, handler:0L, id:id, index:i}
  spectra_view_event, ev
endfor

  ;start the viewer
spectra_view, afid

;get the base of the widget
envi_reg_base, base=abase, name='Spectral Library Viewer', /query

;p_data is a pointer to an anonymous structure containing all the library info
widget_control, abase, get_uvalue=p_data

;fake an event as if we clicked on the fifth spectrum
id = (*p_data).lw  ; list widget ID

for i = 0L, 90L, 5L do begin
  ev = {top:abase, handler:0L, id:id, index:i}
  spectra_view_event, ev
endfor


end

