package provide win_controller 1.0

package require Tk
package require universal
package require win_textedit
package require win_trfunc
package require draw_nn

proc ContrWindowOk {w entry var} {
    ContrWindowApply $w $entry $var
    destroy $w
}

proc ContrWindowApply {w entry var} {
    upvar #0 $var fileName
    set fileName [$entry get]
    puts "ContrWindowApply: '$fileName'"

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

proc ContrWindowEdit {w title var} {
    upvar #0 $var fileName
    TextEditWindow $w "$title" $fileName
}

proc ContrWindowModified {w entry} {
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


# Create controller of new type at given file path
proc ContrNewType {p sessionDir fileRelPath {force false}} {
    set fileName [SessionAbsPath $sessionDir $fileRelPath]
    if {[file exists $fileName] && !$force} {
	# Not created
	return {}
    }

    # New file must be created; let's ask about its type
    # Let's determine type of the file
    switch -glob -- $fileName {
	*.tf {
	    set ftype trfunc
	    puts "ContrNewType: - new .tf file"
	    set idname [TrFuncSelect $p]
	    if {$idname != {}} {
		TrFuncUseTemplate $idname $fileName
	    }
	}
	default {
	    set ftype undefined
	    puts "ContrNewType: - undefined"
	    # Let's create empty file
	    if [catch {open $fileName w} fdNewFile] {
		close $fdNewFile
	    }
	}
    }
    return $ftype
}


# Call file transfer function editor
# - forceNew - boolean: true to create new file anyway
# - asText - boolean: true to edit as text file
proc ContrEdit {p sessionDir title fileRelPath {forceNew false} {asText false}} {
    puts "ContrEdit: $sessionDir $fileRelPath"
    set ftype [ContrNewType $p $sessionDir $fileRelPath $forceNew]
    set fileName [SessionAbsPath $sessionDir $fileRelPath]
    # Now it's possible to edit the file

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
    # Let's call edit method
    if {$asText} {
	set ftype undefined
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


# Select file for traditional controller and store new value to var
# global variable.
proc ContrSelectTrFile {p sessionDir var} {
    global $var
    upvar #0 $var fileRelPath
    puts "sessionDir=$sessionDir"
    puts "fileRelPath=$fileRelPath"
    set fileName [SessionAbsPath $sessionDir $fileRelPath]
    set trfuncfiletypes {
	{"Линейные звенья" {.tf}}
	{"Произвольные функции" {.cof}}
	{"Все файлы" *}
    }
    set fileName [fileSelectionBox $p open $fileName $trfuncfiletypes]
    if {$fileName != {}} {
	set fileRelPath [SessionRelPath $sessionDir $fileName]
    }
}


# Select file for neural net controller and store new value to var
# global variable.
proc ContrSelectNNFile {p sessionDir var} {
    global $var
    upvar #0 $var fileRelPath
    set fileName [SessionAbsPath $sessionDir $fileRelPath]
    set nnfiletypes {
	{"Нейронные сети" {.nn}}
	{"Все файлы" *}
    }
    set fileName [fileSelectionBox $p open [file join SessionDir $fileName] $nnfiletypes]
    if {$fileName != {}} {
	set fileRelPath [SessionRelPath $sessionDir $fileName]
    }
}


# Display neural network where filepath is referred by var.
proc ContrlViewNNFile {p sessionDir var} {
    global $var
    upvar #0 $var fileRelPath
    DisplayNeuralNetArch $p $fileRelPath [SessionAbsPath $sessionDir $fileRelPath]
}


# Create dialog window with controller settings.
# - p - parent widget;
# - sessionDir - current session directory (for relative paths mostly);
# - arref - name of global array variable where to store settings;
# - ckind - index of controller kind parameter;
# - trcfile - index of traditional (not nn) controller file;
# - nncfile - index of nn controller file;
# - nncinputs - index of nn controller inputs architecture.
# Return: 1 if some changes took place and 0 otherwise.
proc ContrWindow {p sessionDir arref ckind trcfile nncfile nncinputs} {
    upvar $arref arvar

    set w $p.contr
    catch {destroy $w}
    toplevel $w
    wm title $w "Controller settings"

    puts "arvar($trcfile)=$arvar($trcfile)"

    global var_ckind var_trcfile var_nncfile var_nncinputs
    set var_ckind $arvar($ckind)
    set var_trcfile [SessionRelPath $sessionDir $arvar($trcfile)]
    set var_nncfile [SessionRelPath $sessionDir $arvar($nncfile)]
    set var_nncinputs $arvar($nncinputs)

    puts "var_trcfile=$var_trcfile"

    global $w.applyChanges
    set $w.applyChanges 0

    set f $w.p
    frame $f

    label $f.title -text "Регулятор"
    grid $f.title
    grid $f.title -row 0 -column 0 -columnspan 4

    radiobutton $f.lin_rb -text "Традиционный регулятор" \
	-variable var_ckind -value lin
    label $f.lin_fl -text "Имя файла:" -anchor w
    entry $f.lin_fe -width 30 -textvariable var_trcfile
    button $f.lin_fsel -text "Выбор..." \
	-command "ContrSelectTrFile $w $sessionDir var_trcfile"

    set m $f.lin_fedit.m
    menubutton $f.lin_fedit -text "Изменить..."  -underline 0 \
	-direction below -menu $m -relief raised
    menu $m -tearoff 0
    $m add command -label "Тип звена" \
	-command "ContrEdit $w $sessionDir \"$var_trcfile\" $var_trcfile true"
    $m add command -label "Параметры" \
	-command "ContrEdit $w $sessionDir \"$var_trcfile\" $var_trcfile"
    $m add command -label "Как текст" \
	-command "ContrEdit $w $sessionDir \"$var_trcfile\" $var_trcfile false true"

    grid $f.lin_rb
    grid $f.lin_fl $f.lin_fe $f.lin_fsel $f.lin_fedit
    grid $f.lin_rb -sticky nw
    grid $f.lin_fl -sticky e

    radiobutton $f.nnc_rb -text "Нейросетевой регулятор" \
	-variable var_ckind -value nnc
    label $f.nnc_fl -text "Имя файла:"
    entry $f.nnc_fe -width 30 -textvariable var_nncfile
    button $f.nnc_fsel -text "Выбор..." \
	-command "ContrSelectNNFile $w $sessionDir var_nncfile"
    button $f.nnc_fview -text "Показать..." \
	-command "ContrlViewNNFile $w $sessionDir var_nncfile"
    label $f.inp_l -text "Входы:"
    frame $f.inputs
    foreach {n v} {re "e+r" eee "e+e+..." ede "e+de"} {
	radiobutton $f.inputs.$n -variable var_nncinputs -value $v -text $v
	pack $f.inputs.$n -padx 2 -side left
    }
    grid $f.nnc_rb
    grid $f.nnc_fl $f.nnc_fe $f.nnc_fsel $f.nnc_fview
    grid $f.inp_l -row 5 -column 0
    grid $f.inputs -row 5 -column 1 -columnspan 2
    grid $f.nnc_rb -sticky nw
    grid $f.nnc_fl -sticky e
    grid $f.inp_l -sticky e
    grid $f.inputs -sticky w

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
	puts "dcsloop: apply changes"
	if {$var_ckind != $arvar($ckind)} {
	    set arvar($ckind) $var_ckind
	    set changed 1
	}
	if {$var_trcfile != $arvar($trcfile)} {
	    set arvar($trcfile) [SessionRelPath $sessionDir $var_trcfile]
	    set changed 1
	}
	if {$var_nncfile != $arvar($nncfile)} {
	    set arvar($nncfile) [SessionRelPath $sessionDir $var_nncfile]
	    set changed 1
	}
	if {$var_nncinputs != $arvar($nncinputs)} {
	    set arvar($nncinputs) $var_nncinputs
	    set changed 1
	}
    }
    if {$changed == 0} {
	puts "dcsloop: no changes"
    }
    return $changed
}

#font create myDefaultFont -family Freesans -size 11
#option add *font myDefaultFont
#option readfile noc_labs.ad

#set myvar "../d.cf"
#set myvar "pid.tf"
#puts $myvar
#ContrWindow "" "Plant function" myvar
#puts $myvar
