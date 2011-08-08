package provide win_nntpar 1.0

package require Tk
package require universal

# Create dialog window with NN training parameters.
# - p - parent widget;
# - arref - name of global array variable where to store settings
#           under nex tnames:
# -- finish_on_value - stop training when test MSE reaches the value;
# -- finish_on_decrease - stop training when MSE test decrease becomes
#           less than given value;
# -- finish_on_grow - stop training if test MSE starts growing;
# -- finish_max_epoch - stop training if given epochs are over;
# -- eta - learning rate for hidden neurons;
# -- eta_output - learning rate for output neurons;
# -- alpha - momentum;
proc NNTeacherParWindow {p arref} {
    upvar $arref arvar

    set w $p.nntpar
    catch {destroy $w}
    toplevel $w
    wm title $w "NN training parameters"

    global $w.parvalue
    array set pardescr {
	finish_on_value "Нижняя граница ошибки на тестовой выборке"
	finish_on_decrease "Нижняя граница изменения ошибки на тестовой выборке"
	finish_on_grow "Предельное количество эпох с ростом тестовой ошибки"
	finish_max_epoch "Предельное количество эпох обучения"
	eta "Скорость обучения скрытых нейронов"
	eta_output "Скорость обучения выходных нейронов"
	alpha "Коэффициент инерции обучения (моментум)"
    }

    # Make local copy
    foreach par [array names pardescr] {
	if {[info exists arvar($par)]} {
	    set $w.parvalue($par) $arvar($par)
	} else {
	    set $w.parvalue($par) {}
	}
    }

    set f $w.p
    frame $f

    label $f.learn_title -text "Параметры обучения"
    grid $f.learn_title
    grid $f.learn_title -row 0 -column 0 -columnspan 2

    foreach par {eta eta_output alpha} {
	label $f.label_$par -text $pardescr($par) -anchor w
	entry $f.entry_$par -textvariable $w.parvalue($par) -width 10
	grid $f.label_$par $f.entry_$par -sticky nw
    }

    label $f.stop_title -text "Параметры останова"
    grid $f.stop_title
    grid $f.stop_title -row 4 -column 0 -columnspan 2

    foreach par {finish_max_epoch finish_on_grow
	finish_on_value finish_on_decrease} {
	label $f.label_$par -text $pardescr($par) -anchor w
	entry $f.entry_$par -textvariable $w.parvalue($par) -width 10
	grid $f.label_$par $f.entry_$par -sticky nw
    }

    pack $f -side top

    frame $w.buttons
    pack $w.buttons -side bottom -fill x -pady 2m

    button $w.buttons.ok -text "OK" \
	-command "set $w.applyChanges 1 ; destroy $w"
    button $w.buttons.cancel -text "Отмена" -command "destroy $w"
    pack $w.buttons.ok $w.buttons.cancel -side left -expand 1

    global $w.applyChanges
    set $w.applyChanges 0

    tkwait window $w

    set changed 0
    if {[set $w.applyChanges]} {
	puts "win_nntpar: apply changes"

	# Return changed values back
	foreach par [array names pardescr] {
	    if {[info exists arvar($par)]} {
		if {$arvar($par) != [set $w.parvalue($par)]} {
		    set arvar($par) [set $w.parvalue($par)]
		    set changed 1
		}
	    } elseif {[set $w.parvalue($par)] != {}} {
		set arvar($par) [set $w.parvalue($par)]
		set changed 1
	    }
	}
    }
    if {$changed == 0} {
	puts "win_nntpar: no changes"
    }
    return $changed
}
