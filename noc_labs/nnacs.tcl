#!/bin/sh
# \
exec wish "$0" ${1+"$@"}

if {$tcl_platform(platform) == "windows"} {
    set NullDev "NUL"
} else {
    set NullDev "/dev/null"
}
global NullDev

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
global SystemDirPath

# Let's find scripts
set scriptsdir [file join $SystemDirPath scripts]
puts "Script directory: $scriptsdir"
pkg_mkIndex $scriptsdir
lappend auto_path $scriptsdir
encoding system utf-8

set mainpath [file join $scriptsdir main.tcl]
if {[file exists $mainpath]} {
    source $mainpath
} else {
    error "$mainpath not found"
}

# End of file
