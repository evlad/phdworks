package provide win_trfunc 1.0

package require Tk
package require universal
package require win_textedit


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

# Call file transfer function editor
proc ContrEdit {p title var} {
    upvar #0 $var globalFileName
    set fileName $globalFileName
    if {[file exists $fileName] && [file isfile $fileName]} {
	# Let's determine type of the file
	switch -glob -- $fileName {
	    *.tf {
		set descr [ContrParseFile $fileName]
		if {[llength $descr] == 4 &&
		    [lindex $descr 0] != {} && [lindex $descr 1] != {} &&
		    [lindex $descr 2] != {} && [lindex $descr 3] != {}} {
		    # The whole definition is in the file
		    set ftype trfunc
		} elseif {[llength $descr] == 4 &&
			  [lindex $descr 0] != {}} {
		    # Only idname was found: let's use template
		    set descr [ContrParseTemplate [lindex $descr 0]]
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
		ContrLoadConfig params $descr $ftext
		if {[ContrEditor $p params $descr]} {
		    set headLineFields [split [lindex $ftext 0]]
		    set fd [open $fileName "w"]
		    if {[lindex $headLineFields 0] != ";NeuCon" &&
			[lindex $headLineFields 1] != "transfer" } {
			puts $fd ";NeuCon transfer 1.0"
			puts $fd "\[$type $idname\]"
		    }
		    ContrSaveConfig params $descr $fd $ftext
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

# Create dialog window with controller settings.
# - p - parent widget;
# - arref - name of global array variable where to store settings;
# - ckind - index of controller kind parameter;
# - stdfile - index of standard (not nn) controller file;
# - nncfile - index of nn controller file;
# - nncinputs - index of nn controller inputs architecture.
# Return: 1 if some changes took place and 0 otherwise.
proc ContrWindow {p arref ckind stdfile nncfile nncinputs} {
    upvar $arref arvar

    set w $p.contr
    catch {destroy $w}
    toplevel $w
    wm title $w "Controller settings"

    global var_ckind var_stdfile var_nncfile var_nncinputs
    set var_ckind $arvar($ckind)
    set var_stdfile $arvar($stdfile)
    set var_nncfile $arvar($nncfile)
    set var_nncinputs $arvar($nncinputs)

    set f $w.p
    frame $f

    radiobutton $f.lin_rb -text "Традиционный контроллер" \
	-variable var_ckind -value lin
    label $f.lin_fl -text "Имя файла:" -anchor w
    entry $f.lin_fe -width 30 -textvariable var_stdfile
    button $f.lin_fb -text "Выбор..." \
	-command "puts TODO"
    grid $f.lin_rb
    grid $f.lin_fl $f.lin_fe $f.lin_fb
    grid $f.lin_rb -sticky nw
    grid $f.lin_fl -sticky e

    radiobutton $f.nnc_rb -text "Нейросетевой контроллер" \
	-variable var_ckind -value nnc
    label $f.nnc_fl -text "Имя файла:"
    entry $f.nnc_fe -width 30 -textvariable var_nncfile
    button $f.nnc_fb -text "Выбор..." \
	-command "puts TODO"
    label $f.inp_l -text "Входы:"
    frame $f.inputs
    foreach {n v} {re "r+e" eee "e+e+..." ede "e+de"} {
	radiobutton $f.inputs.$n -variable var_nncinputs -value $v -text $v
	pack $f.inputs.$n -padx 2 -side left
    }
    grid $f.nnc_rb
    grid $f.nnc_fl $f.nnc_fe $f.nnc_fb
    grid $f.inp_l -row 4 -column 0
    grid $f.inputs -row 4 -column 1 -columnspan 2
    grid $f.nnc_rb -sticky nw
    grid $f.nnc_fl -sticky e
    grid $f.inp_l -sticky e
    grid $f.inputs -sticky w

    pack $f -side top

    frame $w.buttons
    pack $w.buttons -side bottom -fill x -pady 2m
    button $w.buttons.ok -text "OK" \
	-command "puts TODO"
    button $w.buttons.cancel -text "Отмена" -command "destroy $w"
    pack $w.buttons.ok $w.buttons.cancel -side left -expand 1

    tkwait window $w

    set changed 0
    if {$var_ckind != $arvar($ckind)} {
	set arvar($ckind) $var_ckind
	set changed 1
    }
    if {$var_stdfile != $arvar($stdfile)} {
	set arvar($stdfile) $var_stdfile
	set changed 1
    }
    if {$var_nncfile != $arvar($nncfile)} {
	set arvar($nncfile) $var_nncfile
	set changed 1
    }
    if {$var_nncinputs != $arvar($nncinputs)} {
	set arvar($nncinputs) $var_nncinputs
	set changed 1
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
