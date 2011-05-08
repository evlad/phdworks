package provide win_plant 1.0

package require Tk
package require universal
package require win_textedit
package require trfunc
package require draw_nn

proc PlantWindowOk {w entry var} {
    PlantWindowApply $w $entry $var
    destroy $w
}

proc PlantWindowApply {w entry var} {
    upvar #0 $var fileName
    set fileName [$entry get]
    puts "PlantWindowApply: '$fileName'"

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

proc PlantWindowEdit {w title var} {
    upvar #0 $var fileName
    TextEditWindow $w "$title" $fileName
}

proc PlantWindowModified {w entry} {
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

# Call file transfer function editor
proc PlantEdit {p sessionDir title fileRelPath} {
    puts "PlantEdit: $sessionDir $fileRelPath"
    set fileName [AbsPath $sessionDir $fileRelPath]
    if {![file exists $fileName]} {
	# New file must be created; let's ask about its type
	# Let's determine type of the file
	switch -glob -- $fileName {
	    *.tf {
		set ftype trfunc
		puts "PlantEdit:TODO - new .tf file"
		set idname [TrFuncSelect $p]
		if {$idname != {}} {
		    TrFuncUseTemplate $idname $fileName
		}
	    }
	    default {
		set ftype undefined
		puts "PlantEdit:TODO - undefined"
		return
	    }
	}
	# Now it's possible to edit the file
    }
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
    switch -exact -- $ftype {
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
}


# Select file for plant and store new value to var global variable.
proc PlantSelectTrFile {p sessionDir var} {
    global $var
    upvar #0 $var fileRelPath
    set fileName [AbsPath $sessionDir $fileRelPath]
    set trfuncfiletypes {
	{"Линейные звенья" {.tf}}
	{"Произвольные функции" {.cof}}
	{"Все файлы" *}
    }
    set fileName [fileSelectionBox $p open $fileName $trfuncfiletypes]
    set fileRelPath [RelPath $sessionDir $fileName]
}


# Create dialog window with controller settings.
# - p - parent widget;
# - sessionDir - current session directory (for relative paths mostly);
# - arref - name of global array variable where to store settings;
# - plantfile - index of traditional (not nn) controller file;
# Return: 1 if some changes took place and 0 otherwise.
proc PlantWindow {p sessionDir arref plantfile} {
    upvar $arref arvar

    set w $p.plant
    catch {destroy $w}
    toplevel $w
    wm title $w "Plant settings"

    global var_plantfile
    set var_plantfile [RelPath $sessionDir $arvar($plantfile)]

    global $w.applyChanges
    set $w.applyChanges 0

    set f $w.p
    frame $f

    label $f.title -text "Объект управления"
    grid $f.title
    grid $f.title -row 0 -column 0 -columnspan 4

    label $f.lin_fl -text "Имя файла:" -anchor w
    entry $f.lin_fe -width 30 -textvariable var_plantfile
    button $f.lin_fsel -text "Выбор..." \
	-command "PlantSelectTrFile $w $sessionDir var_plantfile"
    button $f.lin_fedit -text "Изменить..." \
	-command "PlantEdit $w $sessionDir \"$var_plantfile\" $var_plantfile"
    grid $f.lin_fl $f.lin_fe $f.lin_fsel $f.lin_fedit
    grid $f.lin_fl -sticky e

    pack $f -side top

    frame $w.buttons
    pack $w.buttons -side bottom -fill x -pady 2m
    button $w.buttons.ok -text "OK" \
	-command "set $w.applyChanges 1 ; destroy $w"
    button $w.buttons.cancel -text "Отмена" -command "destroy $w"
    pack $w.buttons.ok $w.buttons.cancel -side left -expand 1

    tkwait window $w

    set changed 0
    if {[set $w.applyChanges]} {
	if {$var_plantfile != $arvar($plantfile)} {
	    set arvar($plantfile) $var_plantfile
	    set changed 1
	}
    }
    return $changed
}
