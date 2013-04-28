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
proc TrFuncChangeParameters {w configvar descrvar {parwidget {}}} {
    global $configvar $descrvar
    set descr [set $descrvar]
    puts "descr before: [set $descrvar]"
    puts "config before: [array get $configvar]"
    if {[TrFuncEditor $w $configvar $descr]} {
	puts "config after: [array get $configvar]"
    }
    if {$parwidget != {}} {
	TrFuncSetParamsText $parwidget [array get $configvar]
    }
}

# Call transfer function type changer which leads to parameters changer.
proc TrFuncChangeType {w configvar descrvar {parwidget {}}  {typewidget {}}} {
    set tftype [TrFuncSelect $w]
    if {$tftype == {}} {
	# Cancel
	return
    }
    puts "type=$tftype"

    # Let's parse descripton
    set descr [TrFuncParseTemplate $tftype]
    if {$typewidget != {}} {
	$typewidget configure -text [lindex $descr 2]
    }

    # Let's extract default parameters and put them into config array
    global $configvar $descrvar

    puts "descr=$descr"
    set $descrvar $descr

    # Reset array of parameters by new values
    array unset $configvar
    # Set new default parameters
    array set $configvar [lindex $descr 3]
    if {$parwidget != {}} {
	TrFuncSetParamsText $parwidget [array get $configvar]
    }
    TrFuncChangeParameters $w $configvar $descrvar $parwidget
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

    # The variable stores list of {name ftype} pairs in raw list:
    # {plant1 TransferFunction plant2 CustomFunction ...}
    # It is used to locate all contents of combined function
    global $w.var_root_list
    foreach {name typeRange} [lindex $cof($combined) 1] {
	puts "name=$name"
	if { ! [info exists cof($name)]} {
	    set ftype {}
	} else {
	    set ftype [lindex $typeRange 0]
	    set fparams [lindex $cof($name) 1]
	}
	lappend $w.var_root_list $name $ftype

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
	global $g.var_${name}_name $g.var_${name}_config $g.var_${name}_descr
	set $g.var_${name}_sel 0
	set $g.var_${name}_name "$name"
	set $g.var_${name}_from [lindex $typeRange 1]
	set $g.var_${name}_to [lindex $typeRange 2]

	checkbutton $g.sel_${name} -text "" -variable $g.var_${name}_sel
	#label $g.name_${name} -text "$name"
	entry $g.name_${name} -textvariable $g.var_${name}_name \
	    -width 16 -relief sunken
	button $g.type_${name} -text $type -relief flat -pady 0
	button $g.params_${name} -relief flat -pady 0
	switch -exact $ftype {
	    TransferFunction {
		array set $g.var_${name}_config $trfunc(config)
		puts "\$trfunc(config): $trfunc(config)"
		set $g.var_${name}_descr $trfunc(descr)
		puts "\$trfunc(descr): $trfunc(descr)"
		TrFuncSetParamsText $g.params_${name} $trfunc(config)
		$g.params_${name} configure -command \
		    "TrFuncChangeParameters $w $g.var_${name}_config $g.var_${name}_descr $g.params_${name}"
		#"if {\[TrFuncEditor $w $g.var_${name}_config \"$trfunc(descr)\"\]} { TrFuncSetParamsText $g.params_${name} \[array get $g.var_${name}_config\] }"
#
		$g.type_${name} configure -command \
		    "TrFuncChangeType $w $g.var_${name}_config $g.var_${name}_descr $g.params_${name} $g.type_${name}"
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
	    $g.from_${name} $g.to_${name} -sticky nw -pady 2
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
    button $b.schema -text "Схема" \
	-command "CoFuncEditorSaveFile $w new_test.cof"
    button $b.cancel -text "Отмена" -command "destroy $w"

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
    #grid $b.probe -row 1 -column 0 -sticky news
    #pack $b.probe 
    pack $b.ok $b.schema $b.probe $b.cancel -side left -expand 1

    pack $b -side right

    tkwait window $w

    # Scan global $g.var_${name}_config to take changed parameters


    set changed 1
    return $changed
}

proc CoFuncEditorSaveFile {w filePath} {
    global $w.var_root_list
    set g $w.grid

    # Prepare root combined function
    foreach {name ftype} [set $w.var_root_list] {
	upvar #0 $g.var_${name}_from from
	upvar #0 $g.var_${name}_to to
	lappend funcList $name [list $ftype $from $to]
    }
    lappend cofSections "main" [list "CombinedFunction" $funcList]

    # Prepare other functions
    foreach {name ftype} [set $w.var_root_list] {
	switch -exact $ftype {
	    TransferFunction {
		upvar #0 $g.var_${name}_descr descr
		global $g.var_${name}_config
		set config [array get $g.var_${name}_config]
		set trfunc {}
		lappend trfunc descr $descr
		lappend trfunc config $config
		lappend cofSections $name [list "TransferFunction" $trfunc]
	    }
	    CustomFunction {
		#array set cufunc $fparams
		#set type $cufunc(file)
		#set params $cufunc(options)
		#set initial $cufunc(initial)
	    }
	    default {
		#set type "Неизвестен"
		#set params "Неизвестны"
	    }
	}
    }

    puts $cofSections
    CoFuncComposeFile $filePath $cofSections
}

proc CoFuncTest {} {
    global NullDev
    global tcl_platform
    global env
    global SystemDirPath

    if {$tcl_platform(platform) == "windows"} {
	set NullDev "NUL"
    } else {
	set NullDev "/dev/null"
    }

    # Let's find system directory
    if {![info exists env(NNACSSYSDIR)]} {
	# Not defined special place -> let's use the default one
	if {$tcl_platform(platform) == "windows"} {
	    set SystemDirPath {C:\Program Files\NNACS}
	} else {
	    set SystemDirPath [file join $env(HOME) nnacs]
	}
    } else {
	set SystemDirPath $env(NNACSSYSDIR)
    }
#    global SystemDirPath

    # Let's find scripts
    #set scriptsdir [file join $SystemDirPath scripts]
    #puts "Script directory: $scriptsdir"
    #pkg_mkIndex $scriptsdir
    #lappend auto_path $scriptsdir
    encoding system utf-8

    array set cof [CoFuncParseFile testdata/test.cof]
    #foreach n [array names cof] {
    #  puts "$n: $cof($n)"
    #}
    CoFuncEditor {} cof
}
