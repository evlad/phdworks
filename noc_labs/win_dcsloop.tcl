package provide win_dcsloop 1.0

#set font "-*-helvetica-*-r-*-*-14-*-*-*-*-*-koi8-*"

package require files_loc
package require draw_prim
package require par_file
package require win_textedit
package require win_controller
package require win_plant
package require win_signal

# Draw panel contents in given canvas
proc dcsloopDrawPanel {this c} {
    DrawLargeBlock $c reference "Уставка" 1.8c 4c
    DrawSmallBlock $c checkpoint_r "r" 3.5c 4c
    DrawGather $c cerr 4.5c 4c "s"
    DrawSmallBlock $c checkpoint_e "e" 5.4c 4c
    DrawLargeBlock $c controller "Регулятор" 7.1c 4c
    DrawSmallBlock $c checkpoint_u "u" 8.8c 4c
    DrawLargeBlock $c plant "Объект" 10.4c 4c
    DrawGather $c nadd 12c 4c "none"
    DrawLargeBlock $c noise "Помеха" 12c 1.7c
    DrawSmallBlock $c checkpoint_n "n" 12c 3c
    DrawSmallBlock $c checkpoint_y "y" 12c 5.3c

    DrawDirection $c reference "e" checkpoint_r "w" last
    DrawDirection $c checkpoint_r "e" cerr "w" last
    DrawDirection $c cerr "e" checkpoint_e "w" last
    DrawDirection $c checkpoint_e "e" controller "w" last
    DrawDirection $c controller "e" checkpoint_u "w" last
    DrawDirection $c checkpoint_u "e" plant "w" last
    DrawDirection $c plant "e" nadd "w" last

    DrawDirection $c noise "s" checkpoint_n "n" last
    DrawDirection $c checkpoint_n "s" nadd "n" last
    DrawDirection $c nadd "s" checkpoint_y "n" last

    DrawDirection $c checkpoint_y "w" cerr "s" hor

#    DrawArrow $c 6c 5c 9c 5c middle
#    DrawArrow $c 9c 5c 11c 5c last
#    DrawArrow $c 11c 2c 11c 5c last
}


# 8. Run the program in its session directory
proc dcsloopRun {p sessionDir parFile} {
    set cwd [pwd]
    puts "Run dcsloop"
    catch {cd $sessionDir} errCode1
    puts "rc=$errCode1 [pwd]"
    catch {exec dcsloop $parFile >/dev/null 2>dcsloop.err} errCode2
    puts "rc=$errCode2"
    cd $cwd

    # 9. Refresh state of controls
    # TODO

    # 10. It's possible to display log
    set logFile [file rootname $parFile].log
    $p.controls.log configure \
	-command "TextEditWindow $p \"$logFile\" \"$logFile\""
}

# Add given checkpoint to plotter window or display the data file.
proc dcsloopCheckPoint {p chkpnt sessionDir fileName label} {
    set filePath [AbsPath $sessionDir $fileName]
    global dcsloop_grSeries
    if {[GrSeriesCheckPresence $p]} {
	# Avoid adding one series several times
	if {[lsearch -exact $dcsloop_grSeries $fileName] == -1} {
	    if {[file exists $filePath]} {
		set wholeData [GrSeriesReadFile $filePath]
		GrSeriesAddSeries $p "[lindex $wholeData 0]" $label
		GrSeriesRedraw $p
		lappend dcsloop_grSeries $fileName
	    }
	}
    } else {
	# Make empty list of series to plot
	set dcsloop_grSeries {}

	# Display file contents
	if {[file exists $filePath]} {
	    TextEditWindow $p "Series $fileName" $filePath
	}
    }
}

# Create window with panel and controls.  Returns this instance.
proc dcsloopCreateWindow {p title} {
    set w $p.dcsloop

    # Don't create the window twice
    if {[winfo exists $w]} return

    toplevel $w
    wm title $w "Control system loop modeling"
    wm iconname $w "CSLoop"

    # 1. Create session directory and remember it
    global curSessionDir
    set curSessionDir [SessionDir "1"]
 
    set parFile [file join $curSessionDir dcsloop.par]
    if {![file exists $parFile]} {
	# 2. Create default parameters from templates
	file copy -force [file join [TemplateDir] dcsloop.par] $parFile
    }

    # 3. Assign parameters from file
    global dcsloop_params
    #upvar #0 dcsloopparams params
    array set dcsloop_params {}
    ParFileFetch $parFile dcsloop_params

    global dcsloop_grSeries
    set dcsloop_grSeries {}

    # 4. Draw control system loop schema
    frame $w.controls
    pack $w.controls -side bottom -fill x -pady 2m
    button $w.controls.params -text "Параметры" \
	-command "TextEditWindow $w \"$parFile\" \"$parFile\""
    button $w.controls.run -text "Запустить" \
	-command "dcsloopRun $w $curSessionDir $parFile"
    button $w.controls.log -text "Протокол"
    button $w.controls.series -text "Графики" \
	-command "GrSeriesWindow $w \"Series plot\""
    button $w.controls.close -text "Закрыть" \
	-command "destroy $w"
    pack $w.controls.params $w.controls.run $w.controls.log \
	$w.controls.series $w.controls.close -side left -expand 1

    frame $w.frame
    pack $w.frame -side top -fill both -expand yes
    set c $w.frame.c

    canvas $c -width 14c -height 7c -relief sunken -borderwidth 2 \
	-background white
    pack $c -side top -fill both -expand yes

    #set t "Моделирование системы автоматического управления"
    set textFont [option get $c fontLargeBlock ""]
    $c create text 0.5c 0.2c -text "$title" -justify left -anchor nw \
	-fill DarkGreen -font "$textFont"

    dcsloopDrawPanel {} $c

    # 5. Connect callbacks with visual parameters settings
    # (reference+noise, modelling length) including selection of tf
    $c.reference configure \
	-command "SignalWindow $w $curSessionDir refer dcsloop_params input_kind in_r refer_tf stream_len ; ParFileAssign $parFile dcsloop_params"
    $c.controller configure \
	-command "ContrWindow $w $curSessionDir dcsloop_params contr_kind lincontr_tf nncontr nnc_mode ; ParFileAssign $parFile dcsloop_params"
    $c.plant configure \
	-command "PlantWindow $w $curSessionDir dcsloop_params linplant_tf ; ParFileAssign $parFile dcsloop_params"
    $c.noise configure \
	-command "SignalWindow $w $curSessionDir noise dcsloop_params input_kind in_n noise_tf stream_len ; ParFileAssign $parFile dcsloop_params"

    # Assign name of check point output files
    foreach {chkpnt parname} {checkpoint_r out_r checkpoint_n out_n
	checkpoint_u out_u checkpoint_e out_e checkpoint_y out_ny} {
	set label [$c.$chkpnt cget -text]
	$c.$chkpnt configure \
	    -command "dcsloopCheckPoint $w $chkpnt $curSessionDir $dcsloop_params($parname) \"$label\""
    }

    # 
    # Prepare template parameters file
    # Provide its name for editing by $w.controls.params
    # At $w.controls.run replaces several parameters by preset values
    # During the run display progress bar
    # After the run gather files and be ready to draw series
    # Drawing series may be tuned on and off in custom manner
}

#proc dcsloopSingle {} {
#    NewUser "" user1
#    dcsloopCreateWindow ""
#}

#dcsloopSingle

# End of file
