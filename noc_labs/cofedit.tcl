pkg_mkIndex .
lappend auto_path .

package require Tk

package require win_trfunc
package require win_cofunc


# Set text representation of tranfer function parameters in given
# widget.
proc TrFuncSetParamsText {w config} {
    set text {}
    foreach {n v} $config {
	lappend text "$n=$v"
    }
    $w configure -text $text
}


# Call transfer function parameters editor for parameters located in
# array $configvar.  Transfer function description is in $descr.
# Optionally, parameters may be displayed as text in $parwidget.
proc TrFuncChangeParameters {w configvar descr {parwidget {}}} {
    global $configvar
    puts "before: [array get $configvar]"
    if {[TrFuncEditor $w $configvar $descr]} {
	global $configvar
	puts "after: [array get $configvar]"
    }
    if {$parwidget != {}} {
	TrFuncSetParamsText $parwidget [array get $configvar]
    }
}


# Call transfer function type changer which leads to parameters changer.
proc TrFuncChangeType {w configvar descr {parwidget {}}  {typewidget {}}} {
    set tftype [TrFuncTypeSelect $w]
    if {$tftype == {}} {
	# Cancel
	return
    }

    # Let's parse descripton
    set descr [TrFuncParseTemplate $tftype]
    if {$typewidget != {}} {
	$typewidget configure -text [lindex $descr 2]
    }

    # Let's extract default parameters and put them into config array
    global $configvar
    # Reset array of parameters by new values
    array set $configvar [TrFuncGetDefaultConfig $tftype]
    TrFuncChangeParameters $w $configvar $descr $parwidget
}


# Display combined function editor window.
# - p - parent widget;
# - thisvar - name of the array with parameters if the function
# Returns: 1 - if there were changes; 0 - there were no changes in
# parameters.
proc CoFuncEditor {p thisvar} {
    # Make a local copy of combined function
    upvar $thisvar this
    array set cof [array get this]

    # Let's find the root combined function - list of other functions
    set combined {}
    foreach n [array names cof] {
	set type [lindex $cof($n) 0]
	puts "name=$n, type=$type"
	if {"CombinedFunction" == $type} {
	    lappend combined $n
	}
    }
    if {$combined == {}} {
	error "No combined function entry was found"
	return 0
    }
    if {[llength $combined] > 1} {
	error "More than one combined function was found"
	return 0
    }
    puts "root combined function: $combined"

    set w $p.cofeditor
    catch {destroy $w}
    toplevel $w

    wm title $w "Combined function"

    #frame $w.title

    set g $w.grid
    frame $g
    # Headline
    grid [label $g.hl_sel -text "Выбор"] \
	[label $g.hl_name -text "Имя"] \
	[label $g.hl_type -text "Тип"] \
	[label $g.hl_params -text "Параметры"] \
	[label $g.hl_from -text "От"] \
	[label $g.hl_to -text "До"]

    foreach {name descr} [lindex $cof($combined) 1] {
	puts "name=$name"
	if { ! [info exists cof($name)]} {
	    set ftype {}
	} else {
	    set ftype [lindex $descr 0]
	    set fparams [lindex $cof($name) 1]
	}

	switch -exact $ftype {
	    TransferFunction {
		array set trfunc $fparams
		set type [lindex $trfunc(descr) 2]
		set params {}
	    }
	    CustomFunction {
		array set cufunc $fparams
		set type $cufunc(file)
		set params $cufunc(options)
		set initial $cufunc(initial)
	    }
	    default {
		set type "Неизвестен"
		set params "Неизвестны"
	    }
	}

	global $g.var_${name}_sel $g.var_${name}_from $g.var_${name}_to
	set $g.var_${name}_sel 0
	set $g.var_${name}_from [lindex $descr 1]
	set $g.var_${name}_to [lindex $descr 2]

	checkbutton $g.sel_${name} -text "" -variable $g.var_${name}_sel
	label $g.name_${name} -text "$name"
	button $g.type_${name} -text $type -relief flat
	button $g.params_${name} -relief flat
	switch -exact $ftype {
	    TransferFunction {
		global $g.var_${name}_config
		array set $g.var_${name}_config $trfunc(config)
		TrFuncSetParamsText $g.params_${name} $trfunc(config)
		$g.params_${name} configure -command \
		    "TrFuncChangeParameters $w $g.var_${name}_config \"$trfunc(descr)\" $g.params_${name}"
		#"if {\[TrFuncEditor $w $g.var_${name}_config \"$trfunc(descr)\"\]} { TrFuncSetParamsText $g.params_${name} \[array get $g.var_${name}_config\] }"
#
		$g.type_${name} configure -command \
		    "TrFuncChangeType $w $g.var_${name}_config \"$trfunc(descr)\" $g.params_${name} $g.type_${name}"
#		    "set tftype \[TrFuncTypeSelect $w\] ; puts \"new type: \$tftype\""
#
	    }
	    CustomFunction {
#		array set cufunc $fparams
#		set type $cufunc(file)
#		set params $cufunc(options)
#		set initial $cufunc(initial)
	    }
	    default {
		$g.params_${name} configure -text $params
	    }
	}

	entry $g.from_${name} -textvariable $g.var_${name}_from \
	    -width 6 -relief sunken
	entry $g.to_${name} -textvariable $g.var_${name}_to \
	    -width 6 -relief sunken

	grid $g.sel_${name} $g.name_${name} $g.type_${name} $g.params_${name} \
	    $g.from_${name} $g.to_${name} -sticky nw
    }
    pack $g -side top -fill both -expand 1

    set a $w.actions
    frame $a

    button $a.append -text "Добавить"
    button $a.insert -text "Вставить"
    button $a.delete -text "Удалить"
    button $a.up -text "Вверх"
    button $a.down -text "Вниз"

    pack $a.append $a.insert $a.delete $a.up $a.down -side left -expand 1
    pack $a -side top

    set b $w.buttons
    frame $b

    button $b.ok -text "OK"
    button $b.schema -text "Схема"
    button $b.cancel -text "Отмена"

    set m $b.probe.m
    menubutton $b.probe -text "Отклик" \
	-padx [$b.ok cget -padx] -pady [$b.ok cget -pady] \
	-direction below -menu $m -relief raised
    menu $m -tearoff 0
    foreach probesignal {pulse step sin_4 sin_10 sin_20} {
	$m add command -label $probesignal
# \
#	    -command "TrFuncProbeTemporal $w [list $descr] $probesignal"
    }
    grid $b.probe -row 1 -column 0 -sticky news
    pack $b.ok $b.schema $b.probe $b.cancel -side left -expand 1

    pack $b -side right

    tkwait window $w

    # Scan global $g.var_${name}_config to take changed parameters


    set changed 1
    return $changed
}

proc CoFuncTest {} {
    array set cof [CoFuncParseFile testdata/test.cof]
    #foreach n [array names cof] {
    #  puts "$n: $cof($n)"
    #}
    CoFuncEditor {} cof
}
