package provide win_trfunc 1.0

package require Tk
package require win_textedit
package require win_grseries

proc TrFuncFileDialog {w ent operation filepath} {
    #   Type names		Extension(s)	Mac File Type(s)
    #
    #---------------------------------------------------------
    set types {
	{"Линейные звенья"	{.tf}	}
	{"Произвольные функции"	{.cof}	}
	{"Все файлы"		*	}
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
    upvar #0 $var fileName
    set fileName [$entry get]
    puts "TrFuncWindowApply: '$fileName'"

    # Restore normal attributes
    set normalBg [$w.buttons.cancel cget -bg]
    set normalFg [$w.buttons.cancel cget -fg]
    set activeBg [$w.buttons.cancel cget -activebackground]
    set activeFg [$w.buttons.cancel cget -activeforeground]
    $w.buttons.ok configure -bg $normalBg -fg $normalFg \
	-activebackground $activeBg -activeforeground $activeFg
    #$w.buttons.apply configure -bg $normalBg -fg $normalFg \
#	-activebackground $activeBg -activeforeground $activeFg
}

proc TrFuncWindowEdit {w title var} {
    upvar #0 $var fileName
    TextEditWindow $w "$title" $fileName
}

proc TrFuncWindowModified {w entry} {
    #puts "Modified: $w $entry"
    # Set attributes of modified text contents
    set modifiedFg white
    set modifiedBg red
    $w.buttons.ok configure -bg $modifiedBg -fg $modifiedFg \
	-activebackground $modifiedBg -activeforeground $modifiedFg
#    $w.buttons.apply configure -bg $modifiedBg -fg $modifiedFg \
#	-activebackground $modifiedBg -activeforeground $modifiedFg
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
    set nameInput [file join [file dirname $nameTrFunc] probe_$func.dat]
    set nameOutput [file join [file dirname $nameTrFunc] response_$func.dat]
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
    puts "rc=$rc; dummy=$dummy"
    if { $rc == 0 } {
	# Plot results
	GrSeriesAddSeries $w "[lindex [GrSeriesReadFile $nameInput] 0]" "$func"
  	GrSeriesAddSeries $w "[lindex [GrSeriesReadFile $nameOutput] 0]" "f($func)"
	GrSeriesWindow $w "Series plot"
    }
}

# Call file transfer function editor
proc TrFuncEdit {p title var} {
    upvar #0 $var globalFileName
    set fileName $globalFileName
    if {[file exists $fileName] && [file isfile $fileName]} {
	# Let's determine type of the file
	switch -glob -- $fileName {
	    *.tf {
		set descr [TrFuncParseFile $fileName]
		if {[llength $descr] == 4 &&
		    [lindex $descr 0] != {} && [lindex $descr 1] != {} &&
		    [lindex $descr 2] != {} && [lindex $descr 3] != {}} {
		    # The whole definition is in the file
		    set ftype trfunc
		} elseif {[llength $descr] == 4 &&
			  [lindex $descr 0] != {}} {
		    # Only idname was found: let's use template
		    set descr [TrFuncParseTemplate [lindex $descr 0]]
		    if {$descr != {}} {
			set ftype trfunc
		    } else {
			set ftype undefined
		    }
		} else {
		    set ftype undefined
		}
	    }
	    default {
		set ftype undefined
	    }
	}
	switch -exact --  $ftype {
	    trfunc {
		array set params {}
		set fd [open $fileName]
		set ftext [split [read $fd] \n]
		close $fd
		set idname [lindex $descr 0]
		set type [lindex $descr 1]
		set label [lindex $descr 2]
		set key_pos [lindex $descr 3]
		TrFuncLoadConfig params $descr $ftext
		if {[TrFuncEditor $p params $descr]} {
		    set headLineFields [split [lindex $ftext 0]]
		    set fd [open $fileName "w"]
		    if {[lindex $headLineFields 0] != ";NeuCon" &&
			[lindex $headLineFields 1] != "transfer" } {
			puts $fd ";NeuCon transfer 1.0"
			puts $fd "\[$type $idname\]"
		    }
		    TrFuncSaveConfig params $descr $fd $ftext
		    flush $fd
		    close $fd
		}
		# otherwise no changes took place
	    }
	    undefined {
		TextEditWindow $p "$title" $fileName
	    }
	}
    } else {
	# New file must be created; let's ask about its type
	puts "TODO"
    }
}

# p - parent widget
# title - description of the given transfer function
# var - name of variable where to store filename
proc TrFuncWindow {p title var} {
    upvar #0 $var globalFileName
    set fileName $globalFileName
    set w $p.trfunc
    catch {destroy $w}
    toplevel $w
    wm title $w $title

    frame $w.file
    label $w.file.label -text "Имя файла:" -anchor w
    entry $w.file.entry -width 40 -textvariable fileName
    $w.file.entry insert 0 $fileName
    button $w.file.button -text "Выбор..." \
	-command "TrFuncFileDialog $w $w.file.entry open $fileName"
    pack $w.file.label $w.file.entry -side left
    pack $w.file.button -side left -pady 5 -padx 10
    pack $w.file -side top

    frame $w.buttons
    pack $w.buttons -side bottom -fill x -pady 2m
    button $w.buttons.ok -text "OK" \
	-command "TrFuncWindowOk $w $w.file.entry globalFileName"
    #button $w.buttons.apply -text "Apply" \
    #	-command "TrFuncWindowApply $w $w.file.entry globalFileName"
    button $w.buttons.edit -text "Редактировать..." \
	-command "TrFuncEdit $w TITLE \$fileName"
    #button $w.buttons.view -text "View..."
    #button $w.buttons.probe -text "Probe..." \
	#-command "TrFuncProbe $w $w.file.entry"

    set m $w.buttons.probe.m
    menubutton $w.buttons.probe -text "Отклик" -underline 0 \
	-direction below -menu $m -relief raised
    menu $m -tearoff 0
    foreach signal {pulse step sin_4 sin_10 sin_20} {
	$m add command -label $signal \
	    -command "TrFuncProbe $w $w.file.entry $signal"
    }
    grid $w.buttons.probe -row 1 -column 0 -sticky n

    button $w.buttons.cancel -text "Отмена" -command "destroy $w"
    pack $w.buttons.ok $w.buttons.edit \
	$w.buttons.probe $w.buttons.cancel -side left -expand 1

    $w.file.entry configure -validate key -vcmd "TrFuncWindowModified $w %W"
    focus $w.file.entry
}

#	-command "TrFuncWindowEdit $w $title fileName" 

#font create myDefaultFont -family Freesans -size 11
#option add *font myDefaultFont
option readfile noc_labs.ad

#font configure default -family Freesans -size 11

#set myvar "../d.cf"
set myvar "pid.tf"
#puts $myvar
TrFuncWindow "" "Plant function" myvar
#puts $myvar
