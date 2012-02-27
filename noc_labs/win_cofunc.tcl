package provide win_cofunc 1.0

#package require files_loc

#package require win_textedit
package require win_trfunc
package require Tk


# Take given name, find the template, extract and return the whole
# description in form of tagged list (good for array representation):
# { options {0.5 2}
#   file deadzone
#   initial {1 2 3}
#   title_label "Extendened human-readable name of the function"
#   options_descr "Arbitrary multiline description text about options"
#   initial_descr "Arbitrary multiline description text about initial vector"
# }
proc CuFuncParseTemplate {idname} {
    set filepath [file join [TemplateDir] "$idname.cof"]
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


# To test:
#CoFuncParseFile testdata/test.cof

# Print test results:
#array set cof [CoFuncParseFile testdata/test.cof]
#foreach n [array names cof] {
#  puts "$n: $cof($n)"
#}

# End of file
