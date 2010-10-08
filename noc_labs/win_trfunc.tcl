proc TrFuncFileDialog {w ent operation filepath} {
    #   Type names		Extension(s)	Mac File Type(s)
    #
    #---------------------------------------------------------
    set types {
	{"Linear chains"	{.tf}	}
	{"Arbitrary chains"	{.cof}	}
	{"All files"		*	}
    }
    set initdir [file dirname $filepath]
    set initfile [file tail $filepath]
    set initext [file extension $filepath]
    if { $initext == "" } {
	set initext .tf
    } else {
	foreach {name ext} $types {
	    set i [lsearch -exact $ext $initext]
	    if { $i >= 0 } {
		set initext [lindex $ext $i]
		break
	    }
	}
    }
    #puts "Extension: $initext"

    if {$operation == "open"} {
	set filepath [tk_getOpenFile -filetypes $types -parent $w \
			  -initialdir $initdir -initialfile $initfile \
			  -defaultextension $initext ]
    } else {
	set filepath [tk_getSaveFile -filetypes $types -parent $w \
			  -initialdir $initdir -initialfile $initfile \
			  -defaultextension $initext ]
    }
    if {[string compare $filepath ""]} {
	$ent delete 0 end
	$ent insert 0 $filepath
	$ent xview end
    }
}

proc TrFuncWindowOk {w entry var} {
    TrFuncWindowApply $w $entry $var
    destroy $w
}

proc TrFuncWindowApply {w entry var} {
    upvar $var fileName
    set fileName [$entry get]
    puts "TrFuncWindowApply: '$fileName'"

    # Restore normal attributes
    set normalBg [$w.buttons.cancel cget -bg]
    set normalFg [$w.buttons.cancel cget -fg]
    set activeBg [$w.buttons.cancel cget -activebackground]
    set activeFg [$w.buttons.cancel cget -activeforeground]
    $w.buttons.ok configure -bg $normalBg -fg $normalFg \
	-activebackground $activeBg -activeforeground $activeFg
    $w.buttons.apply configure -bg $normalBg -fg $normalFg \
	-activebackground $activeBg -activeforeground $activeFg
}

proc TrFuncWindowEdit {w title var} {
    upvar $var fileName
    TextEditWindow $w "$title" $fileName
}

proc TrFuncWindowModified {w entry} {
    #puts "Modified: $w $entry"
    # Set attributes of modified text contents
    set modifiedFg white
    set modifiedBg red
    $w.buttons.ok configure -bg $modifiedBg -fg $modifiedFg \
	-activebackground $modifiedBg -activeforeground $modifiedFg
    $w.buttons.apply configure -bg $modifiedBg -fg $modifiedFg \
	-activebackground $modifiedBg -activeforeground $modifiedFg
    return 1
}

proc TrFuncProbe {w entry func} {
    set nameTrFunc [$entry get]
    puts "TrFuncProbe: '$nameTrFunc'"
    if {![file exists $nameTrFunc]} {
	puts stderr "File '$nameTrFunc' does not exist"
	return
    }

    # Prepare probe signal
    set len0 10
    set len1 90
    set len [expr $len0 + $len1]
    set nameInput "[file dirname $nameTrFunc][file separator]probe_$func.dat"
    set nameOutput "[file dirname $nameTrFunc][file separator]response_$func.dat"
    if [catch {open $nameInput w} fdInput] {
	puts stderr "Failed to create $nameInput"
	return
    }
    switch -glob $func {
	sin_* {
	    #regexp {[a-z]*\((\d+)\)} $func all period
	    regexp {[a-z]*_(\d+)} $func all period
	    unset all
	}
    }
    for { set i 0 } { $i <= $len } {incr i } {
	switch -glob $func {
	    step {
		if { $i < $len0 } {
		    puts $fdInput "0"
		} else {
		    puts $fdInput "1"
		}
	    }
	    pulse {
		if { $i != $len0 } {
		    puts $fdInput "0"
		} else {
		    puts $fdInput "1"
		}
	    }
	    sin_* {
		puts $fdInput [expr {sin(3.1415926*2*$i/$period)}]
	    }
	}
    }
    close $fdInput

    # Execute probing procedure
    set rc [catch { exec dtf $nameTrFunc $nameInput $nameOutput } dummy]
    if { $rc == 0 } {
	# Plot results
	GrSeriesAddSeries $w "[lindex [GrSeriesReadFile $nameInput] 0]" "$func"
  	GrSeriesAddSeries $w "[lindex [GrSeriesReadFile $nameOutput] 0]" "f($func)"
	GrSeriesWindow $w "Series plot"
    }
}

# p - parent widget
# title - description of the given transfer function
# var - name of variable where to store filename
proc TrFuncWindow {p title var} {
    upvar $var globalFileName
    set fileName $globalFileName
    set w $p.trfunc
    catch {destroy $w}
    toplevel $w
    wm title $w $title

    frame $w.file
    label $w.file.label -text "File name:" -anchor w
    entry $w.file.entry -width 40 -textvariable fileName
    $w.file.entry insert 0 $fileName
    button $w.file.button -text "Browse..." \
	-command "TrFuncFileDialog $w $w.file.entry open $fileName"
    pack $w.file.label $w.file.entry -side left
    pack $w.file.button -side left -pady 5 -padx 10
    pack $w.file -side top

    frame $w.buttons
    pack $w.buttons -side bottom -fill x -pady 2m
    button $w.buttons.ok -text "OK" \
	-command "TrFuncWindowOk $w $w.file.entry globalFileName"
    button $w.buttons.apply -text "Apply" \
	-command "TrFuncWindowApply $w $w.file.entry globalFileName"
    button $w.buttons.edit -text "Edit..." \
	-command "TextEditWindow $w TITLE \$fileName"
    button $w.buttons.view -text "View..."
    #button $w.buttons.probe -text "Probe..." \
	#-command "TrFuncProbe $w $w.file.entry"

    set m $w.buttons.probe.m
    menubutton $w.buttons.probe -text "Probe..." -underline 0 \
	-direction below -menu $m -relief raised
    menu $m -tearoff 0
    foreach signal {pulse step sin_4 sin_10 sin_20} {
	$m add command -label $signal \
	    -command "TrFuncProbe $w $w.file.entry $signal"
    }
    grid $w.buttons.probe -row 1 -column 0 -sticky n

    button $w.buttons.cancel -text "Cancel" -command "destroy $w"
    pack $w.buttons.ok $w.buttons.apply $w.buttons.edit $w.buttons.view \
	$w.buttons.probe $w.buttons.cancel -side left -expand 1

    $w.file.entry configure -validate key -vcmd "TrFuncWindowModified $w %W"
    focus $w.file.entry
}

#	-command "TrFuncWindowEdit $w $title fileName" 

#font create myDefaultFont -family Freesans -size 11
#option add *font myDefaultFont
option readfile noc_labs.ad

source win_textedit.tcl
source win_grseries.tcl

#font configure default -family Freesans -size 11

#set myvar "../d.cf"
set myvar "d.tf"
#puts $myvar
TrFuncWindow "" "Plant function" myvar
#puts $myvar
