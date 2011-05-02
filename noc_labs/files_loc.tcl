package provide files_loc 1.0

# Name of the undefined session directory
set undefSession "undefined"

# Strip absolute path to the relative one if possible.
# Examples:
# basedir="/home/evlad/noc_labs/1"
# abspath="/home/evlad/noc_labs/2/u.dat" => relpath="../2/u.dat"
proc RelPath {basedir abspath} {
    set bdparts [file split [file normalize $basedir]]
    set apparts [file split [file normalize $abspath]]
    set rpparts {}
    set i 0
    # Skip common head
    while {[lindex $apparts $i] == [lindex $bdparts $i]} {
	incr i
    }
    # All rest base dir parts should be replaced by ".."
    foreach bd [lrange $bdparts $i end] {
	lappend rpparts ".."
    }
    # Then all absolute path parts should be appended
    foreach ap [lrange $apparts $i end] {
	lappend rpparts $ap
    }
    return [eval file join $rpparts]
}

# Create or select new user directory
proc NewUser {w {user ""}} {
    set basedir [UserBaseDir]
    global curUserDir
    if {$user != ""} {
	set curUserDir [file join $basedir $user]
    } else {
	set curUserDir [tk_chooseDirectory \
			    -initialdir $basedir -title "Choose user directory"]
    }
    if {$curUserDir eq "" || [file isfile $curUserDir]} {
	return ""
    }
    if {![file exists $curUserDir]} {
	file mkdir $curUserDir
    }
    # Create standard new session directory
    global undefSession
    set newSessionDir [file join $curUserDir $undefSession]
    if {![file exists $newSessionDir]} {
	file mkdir $newSessionDir
    }
    return $curUserDir
}

# Check environment conditions before starting lab works
proc CheckGoodEnv {w} {
    global curUserDir
    if {![info exists curUserDir] || ![file isdirectory $curUserDir]} {
	error "Current user is not defined"
    }
}

# Return base directory of user data
proc UserBaseDir {} {
    global env
    if {![info exists env(NOCLABUSERDIR)]} {
	# Not defined special place -> let's use the default one
	set dir [file join $env(HOME) noc_labs]
    } else {
	set dir $env(NOCLABUSERDIR)
    }
    file mkdir $dir
    return $dir
}

# Return system directory
proc SystemDir {} {
    global env
    if {![info exists env(NOCLABSYSDIR)]} {
	# Not defined special place -> let's use the default one
	set dir "$env(HOME)[file separator]nocsystem"
    } else {
	set dir $env(NOCLABSYSDIR)
    }
    puts "System directory is expected at $dir"
    #file mkdir $dir
    return $dir
}

# Return directory path to the given session directory
proc SessionDir {s} {
    global curUserDir
    if {$curUserDir eq "" || ![file isdirectory $curUserDir]} {
	error "Current user is not defined"
    }
    set sessionDir [file join $curUserDir $s]
    if {![file exists $sessionDir]} {
	file mkdir $sessionDir
    } elseif {![file isdirectory $sessionDir]} {
	error "Session is not a directory"
    }
    return $sessionDir
}

# Return directory path to the data directory
proc WorkDataDir {} {
    set wdd [file join [SystemDir] labworks]
    file mkdir $wdd
    return $wdd
}

# Return directory path to the template directory
proc TemplateDir {} {
    set td [file join [SystemDir] templates]
    return $td
}
