# Transfer function implementation
package provide trfunc 1.0

package require Tk
package require files_loc
package require universal

# ; idname: 
# ; label: Bla-bla-bla
# ; label: Bla-bla-bla
# ; label: Bla-bla-bla
# [type idname_N]
# ...
# ... pos ... ; key
# ...
#

# idname.tf contains template for the object.  Also, idname.ppm
# contains visual representation of the trfunc for the user.

# Object description must contain:
# idname - how to distinguish this object among other of this type
# type - type of the function 
# label - how to title the object
# {key pos ...} - the position of the value in the line with key

# For example,
# {pid1 TransferFunc "ПИД регулятор (Kp Ki Kd)" {{Kp 0} {Ki 0} {Kd 0}}}

# Take file path, find keywords in it, extracts the whole description
# and return it.
proc TrFuncParseFile {filepath} {
    if [ catch {open $filepath} fdtmpl ] {
	puts stderr "Failed to open $filepath: $fdtmpl"
	return
    }
    set tmpl [split [read $fdtmpl] \n]
    close $fdtmpl

    # Empty description
    set descr {{} {} {} {}}
    lset descr 0 $idname

    foreach line $tmpl {
	# Let's exclude empty items to get fields
	set fields {}
	foreach f [split $line] {
	    if {$f != {}} {
		lappend fields $f
	    }
	}
	if {[lindex $fields 0] != ";"} continue
	switch -- [lindex $fields 1] {
	    #idname: { lset descr 0 [lindex $fields 2] }
	    type: { lset descr 1 [lindex $fields 2] }
	    label: { lset descr 2 [concat [lrange $fields 2 end]] }
	    key_pos: { lset descr 3 [lrange $fields 2 end] }
	}
    }
    return $descr
}


# Take given name, find the template, extracts the whole description
# and return it.
proc TrFuncParseTemplate {idname} {
    return TrFuncParseFile [file join [TemplateDir] "$idname.tf"]
}


# Save object to given file descriptor.
# - this - object internal data (array with keys);
# - descr - object description;
# - fd - file descriptor to output (.tf or .cof format);
# - tmpl - contents of the template file (optional).
proc TrFuncSaveConfig {thisvar descr fd {tmpl {}}} {
    upvar $thisvar this
    set idname [lindex $descr 0]
    set type [lindex $descr 1]
    set label [lindex $descr 2]
    set key_pos [lindex $descr 3]

    # Take template
    if {$tmpl == {}} {
	set filepath [file join [TemplateDir] "$idname.tf"]
	if [ catch {open $filepath} fdtmpl ] {
	    puts stderr "Failed to open $filepath: $fdtmpl"
	    return
	}
	set tmpl [split [read $fdtmpl] \n]
	close $fdtmpl
    }

    # It's suggested:
    #puts $fd ";NeuCon transfer 1.0"
    #puts $fd "\[$type $idname\]"
    foreach line $tmpl {
	#puts "Line: $line"
	# Let's exclude empty items to get fields
	set fields {}
	foreach f [split $line] {
	    if {$f != {}} {
		lappend fields $f
	    }
	}
	#puts "Fields: $fields"
	# Let's try to find key in the line
	foreach {key pos} $key_pos {
	    # Key is the last field when the previous is ;
	    if {[lindex $fields end-1] == ";" && \
		    [lindex $fields end] == $key && \
		    $this($key) != {}} {
		lset fields $pos $this($key)
		puts "$key=$this($key)"
		break
	    }
	}
	# Let's produce output line
	puts $fd [join $fields]
    }
}

# Load object from given text taken from file.
# - this - object internal data (array with keys) - result;
# - descr - object description;
# - ftext - file contents to parse (.tf or .cof format).
proc TrFuncLoadConfig {thisvar descr ftext} {
    upvar $thisvar this
    set idname [lindex $descr 0]
    set type [lindex $descr 1]
    set label [lindex $descr 2]
    set key_pos [lindex $descr 3]

    foreach line $ftext {
	# Let's exclude empty items to get fields
	set fields {}
	foreach f [split $line] {
	    if {$f != {}} {
		lappend fields $f
	    }
	}
	# Let's try to find key in the line
	foreach {key pos} $key_pos {
	    # Key is the last field when the previous is ;
	    if {[lindex $fields end-1] == ";" && \
		    [lindex $fields end] == $key} {
		set this($key) [lindex $fields $pos]
		puts "[lindex $fields $pos] ==> $key=$this($key)"
		break
	    }
	}
    }
}

# Display parameters of the object
# - p - parent widget
# - thisvar - name of the array in calling context to list name=value pairs
# - descr - description of the function: name, type, label, parameters
# Returns: 1 - if there were changes; 0 - there were not changes in
# parameters
proc TrFuncEditor {p thisvar descr} {
    set w $p.tfeditor
    catch {destroy $w}
    toplevel $w

    upvar $thisvar this
    set idname [lindex $descr 0]
    set type [lindex $descr 1]
    set label [lindex $descr 2]
    set key_pos [lindex $descr 3]

    wm title $w "$idname paramters"

    frame $w.common
    label $w.common.main_label -text $label -anchor w
    pack $w.common.main_label
    pack $w.common -side top

    frame $w.parameters
    # This variable consist of all operations to store state of dialog
    set save_all_vars $w.save_all_vars
    global $save_all_vars
    set $save_all_vars ""
    foreach {key pos} $key_pos {
	label $w.parameters.label_$key -text $key
	set e $w.parameters.value_$key
	# This variable is global
	set evar $w.var_$key
	global $evar
	set $evar $this($key)
	entry $e -width 12 -validate focus -vcmd {string is double %P}
	$e insert 0 $this($key)
	set $save_all_vars "set $evar \[$e get\] ; [set $save_all_vars]"
	$e configure -invalidcommand "focusAndFlash %W [$e cget -fg] [$e cget -bg]"
	grid $w.parameters.label_$key $e
    }
    pack $w.parameters -side top

    frame $w.buttons
    pack $w.buttons -side bottom -fill x -pady 2m
    button $w.buttons.ok -text "OK" -command "[set $save_all_vars] destroy $w"
    button $w.buttons.cancel -text "Cancel" -command "destroy $w"

    pack $w.buttons.ok $w.buttons.cancel -side left -expand 1

    tkwait window $w

    # Assign stored state
    set changed 0
    foreach {key pos} $key_pos {
	set evar $w.var_$key
	global $evar
	if {$this($key) != [set $evar]} {
	    set this($key) [set $evar]
	    puts "$key=$this($key)"
	    set changed 1
	}
    }
    return $changed
}

# Let's list all different functions defined in templates
# - p - parent widget
#

# End of file
