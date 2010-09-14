package require Plotchart

# Plot file to given plotchart
proc GrSeriesPlotFile {pc filepath} {
    set fd [open $filepath r]
    # read all lines
    set contents [split [read -nonewline $fd] \n]
    close $fd
    # find number of columns
    set nlines [llength $contents]
    set ncolumns [llength [lindex $contents 0] ]
    puts "nlines=$nlines, ncolumns=ncolumns"
    set min 1
    set max 0
    set i 0
    # find min, max and step
    foreach line $contents {
	foreach value $line {
	    if { $min > $max } {
		# The first entry
		set min $value
		set max $value
	    } else {
		# The next entries
		if { $value < $min } {
		    set min $value
		}
		if { $value > $max } {
		    set max $value
		}
	    }
	}
	incr i
    }
    puts "min=$min, max=$max"
    if { [expr {$min - $max} < 0.0001] } {
	set step 1.0
    } else {
	set step [expr pow(10, round(log10($min - $max)))]
    }
    puts "step=$step"
    # draw
    set arg 0
    foreach line $contents {
	incr i
    }
}

proc ReadSeries {filepath} {
    if [ catch {open $filepath r} fd ] {
	puts stderr "Failed to open $filepath: $fd"
	return
    }
    # read all lines
    set contents [split [read -nonewline $fd] \n]
    close $fd

    # let's find number of columns in the file
    set line0 [lindex $contents 0]
    set tail $line0
    set numCol 0
    # parse first numeric field and get the rest part of line
    #puts "$tail"
    #while { [regexp {(\-?\d+(\.\d*)?([eE][+-]?\d+)?)\s+(.*)$} $tail match ] }
    while { [regexp {\s*(\-?\d+(\.\d*)?([eE][+-]?\d+)?)(.*)$} $tail match \
		 fpnum frac exp rest] } {
	set resData($numCol) {}
	incr numCol
	set tail $rest
	puts "$numCol: fpnum=$fpnum frac=$frac exp=$exp rest=\"$rest\""
	#if [ expr $numCol > 10 ] {
	#    break
	#}
    }
    puts "number of columns: $numCol"
    set numRow 0
    foreach line $contents {
	set tail $line
	set iCol 0
	#puts "row=$numRow: $tail"
	while { [regexp {\s*(\-?\d+(\.\d*)?([eE][+-]?\d+)?)(.*)$} $tail match \
		     fpnum frac exp rest] } {
	    if { $iCol < $numCol } {
		lappend resData($iCol) [expr 1.0 * $fpnum]
	    }
	    #puts "col=$iCol"
	    incr iCol
	    set tail $rest
	}
	while { $iCol < $numCol } {
	    # Fill absent values
	    lappend resData($iCol) [expr 0.0]
	    incr iCol
	}
	incr numRow
    }
    puts "number of rows: $numRow ([array names resData])"
    set resList {}
    for {set iCol 0} {$iCol < $numCol} {incr iCol} {
	lappend resList "$resData($iCol)"
    }
    return $resList
}

proc GrSeriesWindow {w title filepath} {
    #set dataByColumns = ReadSeries $filepath
}

set res [ReadSeries r.dat]
#puts "$res"
