# Transfer function implementation
package provide trfunc 1.0

package require Tk
package require files_loc
package require universal
package require win_grseries

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
	    idname: { lset descr 0 [lindex $fields 2] }
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
    return [TrFuncParseFile [file join [TemplateDir] "$idname.tf"]]
}


# Copy given template to pointed file.
proc TrFuncUseTemplate {idname filePath} {
    file copy -force [file join [TemplateDir] "$idname.tf"] $filePath
}


# Save to temporal file given variables and return the file path.
proc TrFuncSaveToTemporal {thisvar descr} {
    upvar $thisvar this
    set idname [lindex $descr 0]
    set type [lindex $descr 1]
    set label [lindex $descr 2]
    set key_pos [lindex $descr 3]
    set fileName [temporalFileName .tf]
    TrFuncUseTemplate $idname $fileName

    array set dummy {}
    set fd [open $fileName]
    set ftext [split [read $fd] \n]
    close $fd
    set headLineFields [split [lindex $ftext 0]]
    set fd [open $fileName "w"]
    if {[lindex $headLineFields 0] != ";NeuCon" &&
	[lindex $headLineFields 1] != "transfer" } {
	puts $fd ";NeuCon transfer 1.0"
	puts $fd "\[$type $idname\]"
    }
    TrFuncSaveConfig this $descr $fd $ftext
    flush $fd
    close $fd
    return $fileName
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


# Display response of the transfer function stored in given file to
# the given probe signal.
proc TrFuncProbe {w trFilePath probe} {
    if {![file exists $trFilePath]} {
	puts stderr "File '$trFilePath' does not exist"
	return
    }

    # Prepare probe signal
    set len0 10
    set len1 90
    set len [expr $len0 + $len1]
    set nameInput [file join [file dirname $trFilePath] probe_$probe.dat]
    set nameOutput [file join [file dirname $trFilePath] response_$probe.dat]
    if [catch {open $nameInput w} fdInput] {
	puts stderr "Failed to create $nameInput"
	return
    }
    switch -glob $probe {
	sin_* {
	    #regexp {[a-z]*\((\d+)\)} $probe all period
	    regexp {[a-z]*_(\d+)} $probe all period
	    unset all
	}
    }
    for { set i 0 } { $i <= $len } {incr i } {
	switch -glob $probe {
	    step {
		if { $i < $len0 } {
		    puts $fdInput "0"
		} else {
		    puts $fdInput "1"
		}
	    }
	    pulse {
		if { $i != $len0 } {
		    puts $fdInput "0"
		} else {
		    puts $fdInput "1"
		}
	    }
	    sin_* {
		puts $fdInput [expr {sin(3.1415926*2*$i/$period)}]
	    }
	}
    }
    close $fdInput

    # Execute probing procedure
    set cwd [pwd]
    cd [temporalDirectory]
    set rc [catch { exec dtf $trFilePath $nameInput $nameOutput } dummy]
    cd $cwd
    puts "rc=$rc; dummy=$dummy"
    if { $rc == 0 } {
	# Plot results
	GrSeriesAddSeries $w "[lindex [GrSeriesReadFile $nameInput] 0]" "$probe"
  	GrSeriesAddSeries $w "[lindex [GrSeriesReadFile $nameOutput] 0]" "f($probe)"
	GrSeriesWindow $w "Series plot"
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

    wm title $w "$idname parameters"

    frame $w.common
    label $w.common.main_label -text $label -anchor w
    pack $w.common.main_label

    # Let's find image to illustrate the function
    foreach ext {gif ppm pgm} {
	set imgfile [file join [TemplateDir] "$idname.$ext"]
	puts "check for $imgfile"
	if {[file exists $imgfile]} {
	    set img [image create photo -file $imgfile]
	    label $w.common.image -image $img
	    pack $w.common.image -side top -padx 3 -pady 3
	    break
	}
    }
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
    button $w.buttons.cancel -text "Отмена" -command "destroy $w"

    set m $w.buttons.probe.m
    menubutton $w.buttons.probe -text "Отклик" -underline 0 \
	-direction below -menu $m -relief raised
    menu $m -tearoff 0
    foreach probesignal {pulse step sin_4 sin_10 sin_20} {
	$m add command -label $probesignal \
	    -command "TrFuncProbe $w [TrFuncSaveToTemporal this $descr] $probesignal"
    }
    grid $w.buttons.probe -row 1 -column 0 -sticky n


    pack $w.buttons.ok $w.buttons.probe $w.buttons.cancel -side left -expand 1

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


proc TrFuncSelectOk {w} {
    global trfunc_selected
    set cursel [$w.common.funclist curselection]
    if {$cursel != {}} {
	set trfunc_selected [$w.common.funclist get $cursel]
    }
    destroy $w
}


# Let's list all different functions defined in templates and allow
# user to select one of them.
# - p - parent widget
# Returns: idname of selected function.
proc TrFuncSelect {p} {
    set w $p.tfselect
    catch {destroy $w}
    toplevel $w

    set width 0
    set height 0
    array set label2idname {}
    foreach trf [glob -directory [TemplateDir] -nocomplain *.tf] {
	set descr [TrFuncParseFile $trf]
	if {{{} {} {} {}} != $descr} {
	    puts "$trf - ok"
	    # Proper template must contain idname, label, type and key_pos
	    set idname [lindex $descr 0]
	    set type [lindex $descr 1]
	    set label [lindex $descr 2]
	    set key_pos [lindex $descr 3]
	    incr height
	    set len [string length $label]
	    if {$width < $len} {
		set width $len
	    }
	    set label2idname($label) $idname
	} else {
	    puts "$trf - bad template"
	}
    }

    # List item which is selected
    global trfunc_selected
    set trfunc_selected {}

    wm title $w "Function selection"

    frame $w.common
    label $w.common.title -text "Выберите тип функции" -anchor w
    listbox $w.common.funclist -width $width -height $height \
	-selectmode single
    foreach trflabel [lsort [array names label2idname]] {
	$w.common.funclist insert end $trflabel
    }
    $w.common.funclist activate 0
    pack $w.common.title $w.common.funclist -side top
    pack $w.common -side top

    frame $w.buttons
    pack $w.buttons -side bottom -fill x -pady 2m
    button $w.buttons.ok -text "OK" -command "TrFuncSelectOk $w"
    button $w.buttons.cancel -text "Отмена" -command "destroy $w"

    pack $w.buttons.ok $w.buttons.cancel -side left -expand 1

    tkwait window $w

    if {$trfunc_selected == {}} {
	return {}
    }
    return $label2idname($trfunc_selected)
}


# End of file
