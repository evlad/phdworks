package provide universal 1.0

package require Tk

# unlist listValue outVar0 outVar1 ...
# Implies [lindex $listValue 0] -> outVar0
#         [lindex $listValue 1] -> outVar1
# and so on.
# Returns number of assigned variables
proc unlist {listValue args} {
    set i 0
    foreach param $args {
	if { $i >= [llength $listValue] } { return $i }
	#puts "-> $param"
	upvar 1 $param outVar
	set outVar [lindex $listValue $i]
	incr i
    }
    return $i
}

# draw hint
proc hint {p text} {
    #set w $p.hintWindow
    #toplevel $w
    bind $p <Enter> "puts \"$text\""
    # Nothing
    #bind $p <Leave> "puts \"$text\""
}

# focusAndFlash --
# Error handler for entry widgets that forces the focus onto the
# widget and makes the widget flash by exchanging the foreground and
# background colours at intervals of 200ms (i.e. at approximately
# 2.5Hz).
#
# Arguments:
# W -		Name of entry widget to flash
# fg -		Initial foreground colour
# bg -		Initial background colour
# count -	Counter to control the number of times flashed
proc focusAndFlash {W fg bg {count 9}} {
    focus -force $W
    if {$count<1} {
	$W configure -foreground $fg -background $bg
    } else {
	if {$count%2} {
	    $W configure -foreground $bg -background $fg
	} else {
	    $W configure -foreground $fg -background $bg
	}
	after 200 [list focusAndFlash $W $fg $bg [expr {$count-1}]]
    }
}

# Display file selection box for listed types of files
# - w - parent widget;
# - operation - open or new;
# - filepath - predefined file path;
# - types - { {label extension} ... } (OPTIONAL).
# Return: selected file path
proc fileSelectionBox {w operation filepath {types {{"Все файлы" *}}}} {
    set initdir [file dirname $filepath]
    set initfile [file tail $filepath]
    set initext [file extension $filepath]
    if { $initext == "" } {
	# Let's use the first extension among
	set initext [lindex 0 1 $types]
	if {$initext == "*"} {
	    # No extension
	    set initext ""
	}
    } else {
	foreach {name ext} $types {
	    set i [lsearch -exact $ext $initext]
	    if { $i >= 0 } {
		set initext [lindex $ext $i]
		break
	    }
	}
    }

    if {$operation == "open"} {
	set filepath [tk_getOpenFile -filetypes $types -parent $w \
			  -initialdir $initdir -initialfile $initfile \
			  -defaultextension $initext ]
    } else {
	set filepath [tk_getSaveFile -filetypes $types -parent $w \
			  -initialdir $initdir -initialfile $initfile \
			  -defaultextension $initext ]
    }
    return $filepath
}

# Return directory for temporal files.
proc temporalDirectory {} {
    # TODO: make OS dependent!
    if {[file isdirectory /tmp]} {
	return /tmp
    }
    # Return current directory
    return .
}

# List for temporal files
set tempFileList {}

# Return temporal file with given suffix at special location.
proc temporalFileName {suffix} {
    global tempFileList
    set tempFileCounter [llength $tempFileList]
    incr tempFileCounter
    set fileName [file join [temporalDirectory] neucon_[pid]_${tempFileCounter}$suffix]
    lappend tempFileList $fileName
    return $fileName
}


# Remove all temporal file names at the end of program.
proc removeTemporalFiles {} {
    global tempFileList
    foreach fileName $tempFileList {
	file delete -force $fileName
    }
    set tempFileList {}
}

# Taken from Welch book
proc Scrolled_Listbox {f args} {
    listbox$f.list \
	-xscrollcommand [list Scroll_Set $f.xscroll \
			     [list grid $f.xscroll -row 1 -column 0 \
				  -sticky we]] \
	-yscrollcommand [list Scroll_Set $f.yscroll \
			     [list grid $f.yscroll -row 0 -column 1 \
				  -sticky ns]]
    eval { $f.listconfigure } $args
    scrollbar $f.xscroll -orient horizontal \
	-command [list $f.list xview]
    scrollbar $f.yscroll -orient vertical \
	-command [list $f.list yview]
    grid $f.list -sticky news
    grid rowconfigure $f0 -weight 1
    grid columnconfigure $f0 -weight 1
    return $f.list
}

# Taken from Welch book
proc Scroll_Set {scrollbar geoCmd offset size} {
    if {$offset !=0.0 || $size != 1.0} {
	eval $geoCmd ;# Make sure it is visible
    }
    $scrollbar set $offset $size
}

# Taken from Welch book
proc Scrolled_Listbox {f args} {
    frame $f
    listbox $f.list \
	-xscrollcommand [list Scroll_Set $f.xscroll \
			     [list grid $f.xscroll -row 1 -column 0 \
				  -sticky we]] \
	-yscrollcommand [list Scroll_Set $f.yscroll \
			     [list grid $f.yscroll -row 0 -column 1 \
				  -sticky ns]]
    eval { $f.list configure } $args
    scrollbar $f.xscroll -orient horizontal \
	-command [list $f.list xview]
    scrollbar $f.yscroll -orient vertical \
	-command [list $f.list yview]
    grid $f.list -sticky news
    grid rowconfigure $f 0 -weight 1
    grid columnconfigure $f 0 -weight 1
    return $f.list
}
