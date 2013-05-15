pkg_mkIndex .
lappend auto_path .

package require Tk

package require win_trfunc
package require win_cofunc


# Set text representation of tranfer function parameters in given
# widget.
proc TrFuncSetParamsText {w config} {
    array set n2v $config
    foreach n [lsort -ascii [array names n2v] ] {
	lappend text "$n=$n2v($n)"
    }
    $w configure -text $text
}


# Call transfer function parameters editor for parameters located in
# array $configvar.  Transfer function description is in $descr.
# Optionally, parameters may be displayed as text in $parwidget.
proc TrFuncChangeParameters {w configvar descrvar {parwidget {}}} {
    global $configvar $descrvar
    set descr [set $descrvar]
    #puts "descr before: [set $descrvar]"
    #puts "config before: [array get $configvar]"
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
    #puts "type=$tftype"

    # Let's parse descripton
    set descr [TrFuncParseTemplate $tftype]
    if {$typewidget != {}} {
	$typewidget configure -text [lindex $descr 2]
    }

    global $configvar $descrvar
    set $descrvar $descr

    #puts "descr=$descr"

    # Let's extract default parameters
    set filePath [TrFuncTemplatePath [lindex $descr 0]]
    array set params {}
    set fd [open $filePath]
    set ftext [split [read $fd] \n]
    close $fd

    # Reset array of parameters by new values
    array unset $configvar

    # Assign new config parameters
    TrFuncLoadConfig $configvar $descr $ftext
    #puts "config: [array get $configvar]"

    # Optionally show parameters
    if {$parwidget != {}} {
	TrFuncSetParamsText $parwidget [array get $configvar]
    }

    # Call parameters change dialog
    TrFuncChangeParameters $w $configvar $descrvar $parwidget
}


# Create table for combined function editor
proc CoFuncEditorTableCreate {g} {
    frame $g
    # Headline
    grid [label $g.sel_hl -text "Выбор"] \
	[label $g.name_hl -text "Имя"] \
	[label $g.type_hl -text "Тип"] \
	[label $g.params_hl -text "Параметры"] \
	[label $g.from_hl -text "От"] \
	[label $g.to_hl -text "До"]
}

# Set number of rows
proc CoFuncEditorTableSetRows {g num} {
    # Remove extra rows
    set maxRowIndex -1
    set removedIndeces {}
    foreach s [grid slaves $g] {
	if [regexp {_([0-9]+)$} $s all i] {
	    if {$i >= $num} {
		# Remove visual items itself...
		destroy $s
		lappend removedIndeces $i
	    } elseif {$i > $maxRowIndex} {
		set maxRowIndex $i
	    }
	}
    }
    # ...and related variables too
    foreach i [lsort -unique $removedIndeces] {
	foreach suffix {_sel _name _from _to _ftype _descr} {
	    global $g.var_${i}${suffix}
	    if [info exist $g.var_${i}${suffix}] {
		unset $g.var_${i}${suffix}
	    }
	}
	foreach suffix {_config} {
	    global $g.var_${i}${suffix}
	    if [info exist $g.var_${i}${suffix}] {
		array unset $g.var_${i}${suffix}
	    }
	}
    }

    global $g.var_cof_count
    set $g.var_cof_count $num

    # If maximum number of rows found among slave is equal to expected
    # number then it is nothing to do
    if {$maxRowIndex + 1 == $num} {
	return
    }
    # Otherwise create new rows
    incr maxRowIndex
    for {set i $maxRowIndex} {$i < $num} {incr i} {
	global $g.var_${i}_sel $g.var_${i}_name \
	    $g.var_${i}_from $g.var_${i}_to

	checkbutton $g.sel_${i} -text "" -variable $g.var_${i}_sel
	entry $g.name_${i} -textvariable $g.var_${i}_name \
	    -width 16 -relief sunken
	button $g.type_${i} -text "No type" -relief flat -pady 0
	button $g.params_${i} -relief flat -pady 0
	entry $g.from_${i} -textvariable $g.var_${i}_from \
	    -width 6 -relief sunken
	entry $g.to_${i} -textvariable $g.var_${i}_to \
	    -width 6 -relief sunken

	grid $g.sel_${i} $g.name_${i} $g.type_${i} $g.params_${i} \
	    $g.from_${i} $g.to_${i}
    }
}


# Exchange two rows (additional refresh may be needed)
proc CoFuncEditorTableRowsExchange {g i j} {
    # Exchange usual variables
    foreach suffix {_sel _name _from _to _ftype _descr} {
	global $g.var_${i}${suffix} $g.var_${j}${suffix}
	if { [info exist $g.var_${j}${suffix}] && \
	     [info exist $g.var_${i}${suffix}] } {
	    set tmp [set $g.var_${i}${suffix}]
	    set $g.var_${i}${suffix} [set $g.var_${j}${suffix}]
	    set $g.var_${j}${suffix} $tmp
	} elseif { [info exist $g.var_${j}${suffix}] } {
	    set $g.var_${i}${suffix} [set $g.var_${j}${suffix}]
	    unset $g.var_${j}${suffix}
	} elseif { [info exist $g.var_${i}${suffix}] } {
	    set $g.var_${j}${suffix} [set $g.var_${i}${suffix}]
	    unset $g.var_${i}${suffix}
	}
    }
    # Exchange arrays
    foreach suffix {_config} {
	global $g.var_${i}${suffix} $g.var_${j}${suffix}
	if { [info exist $g.var_${j}${suffix}] && \
	     [info exist $g.var_${i}${suffix}] } {
	    set tmp [array get $g.var_${i}${suffix}]
	    array unset $g.var_${i}${suffix}
	    array set $g.var_${i}${suffix} [array get $g.var_${j}${suffix}]
	    array unset $g.var_${j}${suffix}
	    array set $g.var_${j}${suffix} $tmp
	} elseif { [info exist $g.var_${j}${suffix}] } {
	    array unset $g.var_${i}${suffix}
	    array set $g.var_${i}${suffix} [array get $g.var_${j}${suffix}]
	    array unset $g.var_${j}${suffix}
	} elseif { [info exist $g.var_${i}${suffix}] } {
	    array unset $g.var_${j}${suffix}
	    array set $g.var_${j}${suffix} [array get $g.var_${i}${suffix}]
	    array unset $g.var_${i}${suffix}
	}
    }
}


# Copy the first row (i) to the last one (j) (additional refresh may
# be needed)
proc CoFuncEditorTableRowsCopy {g i j} {
    # Copy usual variables
    foreach suffix {_sel _name _from _to _ftype _descr} {
	global $g.var_${i}${suffix} $g.var_${j}${suffix}
	set exist_i [info exist $g.var_${i}${suffix}]
	set exist_j [info exist $g.var_${j}${suffix}]
	if { $exist_i } {
	    set $g.var_${j}${suffix} [set $g.var_${i}${suffix}]
	} elseif { $exist_j } {
	    unset $g.var_${j}${suffix}
	}
    }
    # Copy arrays
    foreach suffix {_config} {
	global $g.var_${i}${suffix} $g.var_${j}${suffix}
	set exist_i [info exist $g.var_${i}${suffix}]
	set exist_j [info exist $g.var_${j}${suffix}]

	if { $exist_j } {
	    array unset $g.var_${j}${suffix}
	}
	if { $exist_i } {
	    array set $g.var_${j}${suffix} [array get $g.var_${i}${suffix}]
	}
    }
}


# Move selected rows one step upward
proc CoFuncEditorTableRowsMoveUp {g} {
    upvar #0 $g.var_cof_count var_cof_count
    for {set i 1} {$i < $var_cof_count} {incr i} {
	set cur [expr $i - 1]
	upvar #0 $g.var_${cur}_sel cur_sel
	upvar #0 $g.var_${i}_sel next_sel
	if {${cur_sel} == 0 && ${next_sel} == 1} {
	    CoFuncEditorTableRowsExchange $g $cur $i
	}
    }
}


# Move selected rows one step downward
proc CoFuncEditorTableRowsMoveDown {g} {
    upvar #0 $g.var_cof_count var_cof_count
    for {set i [expr $var_cof_count - 1]} {$i > 0} {incr i -1} {
	set cur [expr $i - 1]
	upvar #0 $g.var_${cur}_sel cur_sel
	upvar #0 $g.var_${i}_sel next_sel
	if {${cur_sel} == 1 && ${next_sel} == 0} {
	    CoFuncEditorTableRowsExchange $g $i $cur
	}
    }
}


# Generate new function name (among mentioned in $g.var_${i}_name)
# g - reference to all cof variables
# template - name used as a template for new one
proc CoFuncEditorNewName {g template} {
    upvar #0 $g.var_cof_count var_cof_count
    set maxNum 0
    # Find the maximum numeric suffix for all mentioned names
    for {set i 0} {$i < $var_cof_count} {incr i} {
	upvar #0 $g.var_${i}_name name
	if [regexp {[0-9]+$} $name numSuffix] {
	    if {$maxNum < $numSuffix} {
		set maxNum $numSuffix
	    }
	}
    }
    # Return the next one
    return "[string trimright $template 0123456789][expr $maxNum + 1]"
}


# Add new row
proc CoFuncEditorTableAddRow {w} {
    set g $w.grid
    upvar #0 $g.var_cof_count var_cof_count
    CoFuncEditorTableSetRows $g [expr $var_cof_count + 1]
    puts "CoFuncEditorTableAddRow: var_cof_count=$var_cof_count"

    set i [expr $var_cof_count - 1]
    global $g.var_${i}_sel $g.var_${i}_name \
	$g.var_${i}_ftype $g.var_${i}_from $g.var_${i}_to \
	$g.var_${i}_config $g.var_${i}_descr

    set $g.var_${i}_sel 0
    if {$i == 0} {
	# Use "Function#" template
	set $g.var_${i}_name [CoFuncEditorNewName $g "Function"]
    } else {
	# Use previous function name as a template
	set j [expr $i - 1]
	global $g.var_${j}_name
	set $g.var_${i}_name [CoFuncEditorNewName $g [set $g.var_${j}_name]]
    }
    set $g.var_${i}_from 0
    set $g.var_${i}_to -1
    set $g.var_${i}_ftype TransferFunction

    switch -exact [set $g.var_${i}_ftype] {
	TransferFunction {
	    array unset $g.var_${i}_config
	    set $g.var_${i}_descr [TrFuncParseTemplate "gain"]
	    TrFuncChangeType $w $g.var_${i}_config $g.var_${i}_descr $g.params_${i} $g.type_${i}
	}
	CustomFunction {
	    puts "N/A"
	    #array set $g.var_${j}_config [array get $g.var_${i}_config]
	}
    }
}


# Add new row as a copy of the last row
proc CoFuncEditorTableDupLastRow {w} {
    set g $w.grid
    upvar #0 $g.var_cof_count var_cof_count
    CoFuncEditorTableSetRows $g [expr $var_cof_count + 1]

    # Copy the last row content
    for {set i [expr $var_cof_count - 2]} \
	{$i <= [expr $var_cof_count - 1]} {incr i} {
	    global $g.var_${i}_sel $g.var_${i}_name \
		$g.var_${i}_ftype $g.var_${i}_from $g.var_${i}_to \
		$g.var_${i}_config $g.var_${i}_descr
	}

    set i [expr $var_cof_count - 2]
    set j [expr $var_cof_count - 1]

    set $g.var_${j}_sel 0
    set $g.var_${j}_name [CoFuncEditorNewName $g [set $g.var_${i}_name]]
    set $g.var_${j}_from [set $g.var_${i}_from]
    set $g.var_${j}_to [set $g.var_${i}_to]
    set $g.var_${j}_ftype [set $g.var_${i}_ftype]

    switch -exact [set $g.var_${i}_ftype] {
	TransferFunction {
	    array set $g.var_${j}_config [array get $g.var_${i}_config]
	    set $g.var_${j}_descr [set $g.var_${i}_descr]
	}
	CustomFunction {
	    array set $g.var_${j}_config [array get $g.var_${i}_config]
	}
    }
}


# Remove selected rows
proc CoFuncEditorTableDeleteRows {w} {
    set g $w.grid
    upvar #0 $g.var_cof_count var_cof_count

    # Count selected rows
    set numSelected 0
    for {set i 0} {$i < $var_cof_count} {incr i} {
	global $g.var_${i}_sel
	if [set $g.var_${i}_sel] {
	    incr numSelected
	}
    }

    if {$numSelected == 0} {
	return
    }

    # Move all rows selected to remove downward
    for {set i 0} {$i < $var_cof_count} {incr i} {
	CoFuncEditorTableRowsMoveDown $g
    }

    # Set less rows
    CoFuncEditorTableSetRows $g [expr $var_cof_count - $numSelected]

    puts "CoFuncEditorTableDeleteRows: var_cof_count=$var_cof_count"
}


# Convert cof array (passed by $this reference) to list of global
# variables with names based on $w.  Returns number of imported
# functions.
proc CoFuncEditorImport {w thisvar} {
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

    # The variable stores list of {name ftype} pairs in raw list:
    # {plant1 TransferFunction plant2 CustomFunction ...}
    # It is used to locate all contents of combined function
    #upvar #0 $w.var_cof_count var_cof_count
    #set var_cof_count 0
    set g $w.grid
    set i 0
    foreach {name typeRange} [lindex $cof($combined) 1] {
	puts "i=$i name=$name"
	if { ! [info exists cof($name)]} {
	    set ftype {}
	} else {
	    set ftype [lindex $typeRange 0]
	    set fparams [lindex $cof($name) 1]
	}
	#lappend $w.var_root_list $name $ftype

	global $g.var_${i}_sel $g.var_${i}_name \
	    $g.var_${i}_ftype $g.var_${i}_from $g.var_${i}_to

	set $g.var_${i}_sel 0
	set $g.var_${i}_name "$name"
	set $g.var_${i}_from [lindex $typeRange 1]
	set $g.var_${i}_to [lindex $typeRange 2]
	set $g.var_${i}_ftype $ftype

	switch -exact $ftype {
	    TransferFunction {
		array set trfunc $fparams
		#set type [lindex $trfunc(descr) 2]
		global $g.var_${i}_config $g.var_${i}_descr
		array set $g.var_${i}_config $trfunc(config)
		#puts "\$trfunc(config): $trfunc(config)"
		set $g.var_${i}_descr $trfunc(descr)
		#puts "\$trfunc(descr): $trfunc(descr)"
	    }
	    CustomFunction {
		# Result is a list of next format:
		# set fparams { options {0.5 2}
		#               file deadzone
		#               initial {1 2 3}
		# }
		global $g.var_${i}_config
		array set $g.var_${i}_config $fparams
	    }
	}
	incr i
    }
    return $i
}


# Convert list of global variables with names based on $w to cof array
# (passed by $this reference).  Returns number of exported functions.
proc CoFuncEditorExport {w thisvar} {
    # Make a local copy of combined function
    upvar $thisvar this
    array set cof [array get this]

    global $w.var_root_list

    puts "CoFuncEditorExport: N/A"
}


# Refresh GUI from list of global variables to widget.
proc CoFuncEditorRefresh {w} {
    set g $w.grid
    upvar #0 $g.var_cof_count var_cof_count
    for {set i 0} {$i < $var_cof_count} {incr i} {
	upvar #0 $g.var_${i}_ftype ftype

	# Define variables depending function type
	switch -exact $ftype {
	    TransferFunction {
		upvar #0 $g.var_${i}_descr descr
		set type [lindex $descr 2]
		$g.type_${i} configure -text $type

		global $g.var_${i}_config
		set config [array get $g.var_${i}_config]
		TrFuncSetParamsText $g.params_${i} $config

		$g.params_${i} configure -command \
		    "TrFuncChangeParameters $w $g.var_${i}_config $g.var_${i}_descr $g.params_${i}"
		$g.type_${i} configure -command \
		    "TrFuncChangeType $w $g.var_${i}_config $g.var_${i}_descr $g.params_${i} $g.type_${i}"
	    }
	    CustomFunction {
		global $g.var_${i}_config
		array set cufparams [array get $g.var_${i}_config]
		$g.type_${i} configure -text "$cufparams(file)"
		$g.params_${i} configure -text "$cufparams(options)"

		$g.params_${i} configure -command \
		    "puts N/A"
		$g.type_${i} configure -command \
		    "puts N/A"
	    }
	    default {
		$g.type_${i} configure -text "Неизвестен" -command {}
		$g.params_${i} configure -text "Неизвестны" -command {}
	    }
	}
    }
}


# Display schema of the combined function
# - p - window name of COF editor
proc CoFuncEditorDisplaySchema {p} {
    set w $p.schema
    catch {destroy $w}
    toplevel $w

    wm title $w "Combined function schema"

    set g $p.grid
    upvar #0 $g.var_cof_count var_cof_count
    for {set i 0} {$i < $var_cof_count} {incr i} {
	upvar #0 $g.var_${i}_ftype ftype

	# Define variables depending function type
	switch -exact $ftype {
	    TransferFunction {
		upvar #0 $g.var_${i}_descr descr
		set type [lindex $descr 2]
		puts "$i: descr=$descr"
	    }
	    CustomFunction {
		global $g.var_${i}_config
		array set cufparams [array get $g.var_${i}_config]
		puts "$i: type=$cufparams(file) params=$cufparams(options)"
	    }
	    default {
		puts "$i: unknown type"
	    }
	}
    }
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
    set g $w.grid

    CoFuncEditorTableCreate $g
    CoFuncEditorTableSetRows $g [CoFuncEditorImport $w this]

    pack $g -side top -fill both -expand 1

    CoFuncEditorRefresh $w

    set a $w.actions
    frame $a

    button $a.append -text "Добавить" \
	-command "CoFuncEditorTableAddRow $w ; CoFuncEditorRefresh $w"
    button $a.duplicate -text "Дублировать" \
	-command "CoFuncEditorTableDupLastRow $w ; CoFuncEditorRefresh $w"
    button $a.delete -text "Удалить" \
	-command "CoFuncEditorTableDeleteRows $w ; CoFuncEditorRefresh $w"
    button $a.up -text "Вверх" \
	-command "CoFuncEditorTableRowsMoveUp $g ; CoFuncEditorRefresh $w"
    button $a.down -text "Вниз" \
	-command "CoFuncEditorTableRowsMoveDown $g ; CoFuncEditorRefresh $w"

    pack $a.append $a.duplicate $a.delete $a.up $a.down -side left -expand 1
    pack $a -side top

    set b $w.buttons
    frame $b

    button $b.ok -text "OK" \
	-command "CoFuncEditorSaveFile $w new_test.cof"
    button $b.schema -text "Схема" \
	-command "CoFuncEditorDisplaySchema $w"
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
    set g $w.grid
    upvar #0 $g.var_cof_count var_cof_count

    # Prepare root combined function
    for {set i 0} {$i < $var_cof_count} {incr i} {
	upvar #0 $g.var_${i}_ftype ftype
	upvar #0 $g.var_${i}_name name
	upvar #0 $g.var_${i}_from from
	upvar #0 $g.var_${i}_to to
	lappend funcList $name [list $ftype $from $to]
    }
    lappend cofSections "main" [list "CombinedFunction" $funcList]


    for {set i 0} {$i < $var_cof_count} {incr i} {
	upvar #0 $g.var_${i}_ftype ftype

	# Define variables depending function type
	switch -exact $ftype {
	    TransferFunction {
		upvar #0 $g.var_${i}_name name
		upvar #0 $g.var_${i}_descr descr
		global $g.var_${i}_config
		set config [array get $g.var_${i}_config]
		set trfunc {}
		lappend trfunc descr $descr
		lappend trfunc config $config
		lappend cofSections $name [list "TransferFunction" $trfunc]
	    }
	    CustomFunction {
		upvar #0 $g.var_${i}_name name
		global $g.var_${i}_config
		array set cufparams [array get $g.var_${i}_config]

		set cufunc {}
		lappend cufunc file $cufparams(file)
		lappend cufunc options $cufparams(options)
		lappend cufunc initial $cufparams(initial)
		lappend cofSections $name [list "CustomFunction" $cufunc]
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
