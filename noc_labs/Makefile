EXESCRIPTS	=nnacs
TCLSCRIPTS	=nnacs.ad \
		main.tcl \
		data_file.tcl \
		draw_nn.tcl \
		draw_prim.tcl \
		files_loc.tcl \
		par_file.tcl \
		universal.tcl \
		win_controller.tcl \
		win_dcsloop.tcl \
		win_grseries.tcl \
		win_nnpedit.tcl \
		win_plant.tcl \
		win_signal.tcl \
		win_textedit.tcl \
		win_trfunc.tcl

install:	$(EXESCRIPTS) $(TCLSCRIPTS) install-templates
		install -d $(PREFIX)/bin $(PREFIX)/scripts
		install -m 775 -t $(PREFIX)/bin $(EXESCRIPTS)
		install -m 664 -t $(PREFIX)/scripts $(TCLSCRIPTS)

install-templates:
		make -C templates install
