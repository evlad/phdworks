package provide files_loc 1.0

package require universal

# Name of the undefined session directory
set undefSession "undefined"

# Strip absolute path to the relative one if possible.
# Examples:
# basedir="/home/evlad/noc_labs/1"
# abspath="/home/evlad/noc_labs/2/u.dat"
# => relpath="../2/u.dat"
# basedir="/home/evlad/noc_labs/1"
# abspath="u.dat"
# => relpath="u.dat"
proc RelPath {basedir abspath} {
    # Do not normalize implicitly current directory location
    if {[file split $abspath] == $abspath} {
	return $abspath
    }
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


# Relative path to the given session dir.
proc SessionRelPath {sessionDir abspath} {
    return [RelPath [SessionDir $sessionDir] $abspath]
}


# Return the shortest absolute path.
proc AbsPath {basedir relpath} {
    return [file join $basedir [RelPath $basedir $relpath]]
}


# Absolute path to the given session dir.
proc SessionAbsPath {sessionDir relpath} {
    return [AbsPath [SessionDir $sessionDir] $relpath]
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
    #puts "System directory is expected at $dir"
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


proc NewSessionOk {w l} {
    global curSessionDir
    # Here the first the digits (or the first word) must be taken
    set curSessionDir [$l get [$l curselection]]
    if {$curSessionDir != {}} {
	destroy $w
    }
}

# Create or select session directory of given type (markfile should present)
proc NewSession {p markfile} {
    global curUserDir curSessionDir

    if {[catch {glob -tails -directory $curUserDir -types d \
		    "\[0-9\]\[0-9\]\[0-9\]"} sessionList]} {
	set curSessionDir NEW
	set lastNum "000"
    } else {
	set lastNum [lindex [lsort $sessionList] end]

	# Let's allow user to select session
	set matchedSessionList {}
	foreach sessionDir $sessionList {
	    if {[file exists [file join $curUserDir $sessionDir $markfile]]} {
		lappend matchedSessionList $sessionDir
		# It's possible to append comments too
	    }
	}
	set sessionList [lsort $matchedSessionList]
	if {$sessionList == {}} {
	    set curSessionDir NEW
	} else {
	    # There are matched sessions
	    set w $p.selectSession

	    # Don't create the window twice
	    if {[winfo exists $w]} return

	    toplevel $w
	    wm title $w "Select session"
	    wm iconname $w "Select"

	    global curSessionDir
	    set curSessionDir {}

	    label $w.title -text "Выберите сеанс"
	    pack $w.title -side top -fill x

	    frame $w.list
	    set l [Scrolled_Listbox $w.list.sessions -width 20 -height 5 \
		       -selectmode single]
	    foreach it  $sessionList {
		$l insert end $it
	    }
	    # Select and show the last item
	    $l selection set end
	    $l yview moveto 1.0

	    pack $w.list.sessions -side left -expand true -fill both
	    pack $w.list -side top -fill x -pady 2m

	    frame $w.buttons
	    pack $w.buttons -side bottom -fill x -pady 2m
	    button $w.buttons.ok -text "OK" -command "NewSessionOk $w $l"
	    button $w.buttons.new -text "Новый" -command "set curSessionDir NEW ; destroy $w"
	    button $w.buttons.cancel -text "Отмена" -command "destroy $w"
	    pack $w.buttons.ok $w.buttons.new $w.buttons.cancel -side left -expand 1
	    bind $l <Double-1> "NewSessionOk $w $l"

	    tkwait window $w

	    if {$curSessionDir == {}} {
		return {}
	    }
	}
    }
    puts "curSessionDir=$curSessionDir"
    if {$curSessionDir == "NEW"} {
	scan $lastNum "%d" lastNum
	set curSessionDir [format "%03d" [incr lastNum]]
    }
    puts "==> curSessionDir=$curSessionDir"
    return $curSessionDir
}
