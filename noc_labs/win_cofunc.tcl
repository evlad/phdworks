package provide win_cofunc 1.0

#package require files_loc

#package require win_textedit
package require win_trfunc
package require Tk


# Take given template filename, extract and return the whole
# description in form of tagged list (good for array representation):
# { options {0.5 2}
#   file deadzone
#   initial {1 2 3}
#   title_label "Extendened human-readable name of the function"
#   options_descr "Arbitrary multiline description text about options"
#   initial_descr "Arbitrary multiline description text about initial vector"
# }
proc CuFuncParseTemplateFile {filepath} {
    puts "template=$filepath"
    if {![file exists $filepath]} {
	error "Template file $filepath was not found!"
    }
    # The first custom function encountered in parsed output (not in
    # file!) is solved as custom function template.
    foreach {name definition} [CoFuncParseFile $filepath] {
	if {[lindex $definition 0] == "CustomFunction"} {
	    return [lindex $definition 1]
	}
    }
    error "Failed to find custom function definition in $filepath!"
}


# Combined function file (.cof) is an array of INI-like sections.  One
# of them is [CombinedFunction main].  It lists all active functions
# in their order and optional time range.  Rest sections may be
# [TransferFunction] or [CustomFunction].  They should contain all
# active functions.

# So, internal representation is a list of parsed sections:
# { "main" {"CombinedFunction" {combined function description}}
#   "name1" {"CustomFunction" {custom function description}}
#   ...
#   "nameN" {"TransferFunction" {transfer function description}}
# }

#proc CoFuncEditFile {p filePath} {

# Parse content of given file and return tagged list with all sections
# listed.
proc CoFuncParseFile {filePath} {
    if [ catch {open $filePath} fd ] {
	error "Failed to open $filePath: $fd"
    }
    set coftext [split [read $fd] \n]
    set headLineFields [split [lindex $coftext 0]]
    close $fd

    puts $headLineFields
    if {[lindex $headLineFields 0] != ";NeuCon" ||
	[lindex $headLineFields 1] != "combined" ||
	[lindex $headLineFields 2] != "function"} {
	error "Bad .cof file identification line"
    }
    set cofVersion [lindex $headLineFields 3]

    set sections {}

    set iniSection {}
    set sectionType {}
    set sectionName {}
    foreach line [lrange $coftext 1 end] {
	# let's find start of section []
	if [regexp {^\[\s*([^\s]+)\s+([^\s]+)\s*\]} $line all type name] {
	    # [$type $name]
	    if {$iniSection != {}} {
		# let's process previous section
		#puts $iniSection
		#puts "END SECTION"
		set s [CoFuncParseSection $sectionType $sectionName $iniSection]
		lappend sections $sectionName [list $sectionType "$s"]
		set iniSection {}
	    }
	    set sectionType $type
	    set sectionName $name
	    #puts "BEGIN SECTION: type=$type name=$name"
	    lappend iniSection "$line"
	} else {
	    # any other line
	    if {$iniSection != {}} {
		lappend iniSection "$line"
	    }
	    # else
	    #   skip lines before 1st section
	}
    }
    # let's process the last section
    #puts $iniSection
    #puts "END SECTION"
    set s [CoFuncParseSection $sectionType $sectionName $iniSection]
    lappend sections $sectionName [list $sectionType "$s"]
    return $sections
}

# Parse text of the section started from [type name].
# Return internal representation for given type of object.
proc CoFuncParseSection {type name stext} {
    switch -exact $type {
	CombinedFunction {
	    return [CoFuncLoadConfig $stext]
	}
	TransferFunction {
	    # Read general description of the transfer
	    # function object as names of parameters.
	    set descr [TrFuncParseDescr $stext]
	    #puts "descr: $descr"
	    array set trf {}
	    # Read exact definition of the transfer
	    # function object as array of parameters.
	    TrFuncLoadConfig trf $descr $stext
	    #puts "config: [array get trf]"
	    return [list descr $descr config [array get trf]]
	}
	CustomFunction {
	    return [CuFuncLoadConfig $stext]
	}
    }
}


# Load combined object from given text taken from file.
# - this - object internal data (array with keys) - result;
# - ftext - file contents to parse (.cof format, CombinedFunction).
# Example of ftext contents:
#  [CombinedFunction main]
#  TransferFunction Plant1 0 5000
#  TransferFunction Plant2 5000 -1
#  CustomFunction DeadZone1
# Result is a list of next format:
#  { Plant1 {TransferFunction 0 5000}
#    Plant2 {TransferFunction 5000 -1}
#    DeadZone1 {CustomFunction 0 -1}
#  }
proc CoFuncLoadConfig {ftext} {
    set colist {}
    # Scan line-by-line skipping the 1st one (it's [type name] for sure).
    foreach line [lrange $ftext 1 end] {
	# let's skip empty lines
	if {[regexp {^\s*$} $line]} {
	    continue
	}
	# let's skip comments
	if {[regexp {^\s*;} $line all]} {
	    continue
	}
	# let's parse as space separated fields
	if {[regexp {^\s*([^\s]+)\s+([^\s]+)\s+(-?[0-9]+)\s+(-?[0-9]+)\s*} \
		 $line all type name tbegin tend]} {
	    lappend colist $name [list $type $tbegin $tend]
	} elseif {[regexp {^\s*([^\s]+)\s+([^\s]+)\s*} $line all type name]} {
	    lappend colist $name [list $type 0 -1]
	} else {
	    puts "CoFuncLoadConfig: can not parse line \"$line\""
	}
    }
    return $colist
}


# Load custom object from given text taken from file.
# - this - object internal data (array with keys) - result;
# - ftext - file contents to parse (.cof format, CustomFunction).
# Example of ftext contents:
#  [CustomFunction DeadZone1]
#  ; title_label: Extendened human-readable name of the function
#  ;              .so/.dll depending the OS
#  file    deadzone
#  ;HalfWidth Gain
#  ; options_descr: Arbitrary multiline description text about options
#  options 0.5 2
#  ; initial_descr: Arbitrary multiline description text about initial vector
#  ;Dummy initial (deadzone object skips this vector)
#  initial 1 2 3
# Result is a list of next format:
#  { options {0.5 2}
#    file deadzone
#    initial {1 2 3}
#    title_label "Extendened human-readable name of the function"
#    options_descr "Arbitrary multiline description text about options"
#    initial_descr "Arbitrary multiline description text about initial vector"
#  }
proc CuFuncLoadConfig {ftext} {
    array set cupar {}
    # Scan line-by-line skipping the 1st one (it's [type name] for sure).
    foreach line [lrange $ftext 1 end] {
	# let's skip empty lines
	if {[regexp {^\s*$} $line]} {
	    continue
	}
	# let's parse comments with keywords and skip rest of them
	if {[regexp {^\s*;\s*([^\s]+)\s+(.*)$} $line match keyword value]} {
	    switch -exact -- $keyword {
		title_label: {
		    set cupar(title_label) "$value"
		}
		options_descr: {
		    if {[info exists cupar(options_descr)]} {
			set cupar(options_descr) "$cupar(options_descr)\n$value"
		    } else {
			set cupar(options_descr) "$value"
		    }
		}
		initial_descr: {
		    if {[info exists cupar(initial_descr)]} {
			set cupar(initial_descr) "$cupar(initial_descr)\n$value"
		    } else {
			set cupar(initial_descr) "$value"
		    }
		}
	    }
	    continue
	}
	# let's parse as not empty space separated fields
	set fields {}
	foreach f [split $line] {
	    if {$f != {}} {
		lappend fields $f
	    }
	}
	switch -exact [lindex $fields 0] {
	    file {
		set cupar(file) [lindex $fields 1]
		set cupar(options) {}
		set cupar(initial) {}
	    }
	    options {
		lappend cupar(options) [lrange $fields 1 end]
	    }
	    initial {
		lappend cupar(initial) [lrange $fields 1 end]
	    }
	    default {
		puts "CuFuncLoadConfig: can not parse line \"$line\""
	    }
	}
    }
    return [array get cupar]
}


proc CuFuncTypeSelectOk {w} {
    global cufunc_selected
    set cursel [$w.common.funclist curselection]
    if {$cursel != {}} {
	set cufunc_selected [$w.common.funclist get $cursel]
    }
    destroy $w
}

# Let's list all different custom functions defined in templates and
# allow user to select one of them.
# - p - parent widget
# Returns: idname of selected function.
proc CuFuncTypeSelect {p} {
    set w $p.cufselect
    catch {destroy $w}
    toplevel $w

    set width 0
    set height 0
    array set label2idname {}
    foreach cufpath [glob -directory [TemplateDir] -nocomplain *.cof] {
	array set cuf [CuFuncParseTemplateFile $cufpath]
	set idname $cuf(file)
	if {[info exists cuf(title_label)]} {
	    set label $cuf(title_label)
	} else {
	    set label $idname
	}
	incr height
	set len [string length $label]
	if {$width < $len} {
	    set width $len
	}
	set label2idname($label) $idname
    }

    # List item which is selected
    global cufunc_selected
    set cufunc_selected {}

    wm title $w "Function selection"

    frame $w.common
    label $w.common.title -text "Выберите тип функции" -anchor w
    listbox $w.common.funclist -width $width -height $height \
	-selectmode single
    foreach cuflabel [lsort [array names label2idname]] {
	$w.common.funclist insert end $cuflabel
    }
    $w.common.funclist activate 0
    pack $w.common.title $w.common.funclist -side top
    pack $w.common -side top

    frame $w.buttons
    pack $w.buttons -side bottom -fill x -pady 2m
    button $w.buttons.ok -text "OK" -command "CuFuncTypeSelectOk $w"
    button $w.buttons.cancel -text "Отмена" -command "destroy $w"

    pack $w.buttons.ok $w.buttons.cancel -side left -expand 1

    tkwait window $w

    if {$cufunc_selected == {}} {
	return {}
    }
    return $label2idname($cufunc_selected)
}

proc CoFuncTypeSelectOk {w} {
    global cofunc_selected
    set cursel [$w.common.funclist curselection]
    if {$cursel != {}} {
	set cofunc_selected [$w.common.funclist get $cursel]
    }
    destroy $w
}

# Let's list all different functions both linear (*.tf) and custom
# (*.cof) defined in templates and allow user to select one of them.
# - p - parent widget
# Returns: idname of selected function and its extension (tf or cof).
proc CoFuncTypeSelect {p} {
    set w $p.cofselect
    catch {destroy $w}
    toplevel $w

    set width 0
    set height 0
    array set label2idname {}
    array set label2ext {}
    foreach cofpath [glob -directory [TemplateDir] -nocomplain *.tf *.cof] {
	switch -glob -- $cofpath {
	    *.tf {
		set descr [TrFuncParseFile $cofpath]
		if {{{} {} {} {}} != $descr} {
		    set idname [lindex $descr 0]
		    set type [lindex $descr 1]
		    set label [lindex $descr 2]
		    set key_pos [lindex $descr 3]
		} else {
		    puts "$cofpath - bad template"
		}
		set label2ext($label) tf
	    }
	    *.cof {
		array set cuf [CuFuncParseTemplateFile $cofpath]
		set idname $cuf(file)
		if {[info exists cuf(title_label)]} {
		    set label $cuf(title_label)
		} else {
		    set label $idname
		}
		set label2ext($label) cof
	    }
	}
	incr height
	set len [string length $label]
	if {$width < $len} {
	    set width $len
	}
	set label2idname($label) $idname
    }

    # List item which is selected
    global cofunc_selected
    set cofunc_selected {}

    wm title $w "Function selection"

    frame $w.common
    label $w.common.title -text "Выберите тип функции" -anchor w
    listbox $w.common.funclist -width $width -height $height \
	-selectmode single
    foreach coflabel [lsort [array names label2idname]] {
	$w.common.funclist insert end $coflabel
    }
    $w.common.funclist activate 0
    pack $w.common.title $w.common.funclist -side top
    pack $w.common -side top

    frame $w.buttons
    pack $w.buttons -side bottom -fill x -pady 2m
    button $w.buttons.ok -text "OK" -command "CoFuncTypeSelectOk $w"
    button $w.buttons.cancel -text "Отмена" -command "destroy $w"

    pack $w.buttons.ok $w.buttons.cancel -side left -expand 1

    tkwait window $w

    if {$cofunc_selected == {}} {
	return {}
    }
    return [list $label2idname($cofunc_selected) $label2ext($cofunc_selected)]
}


# To test:
#CoFuncParseFile testdata/test.cof

# Print test results:
#array set cof [CoFuncParseFile testdata/test.cof]
#foreach n [array names cof] {
#  puts "$n: $cof($n)"
#}

# End of file
