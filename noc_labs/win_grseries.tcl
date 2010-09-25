package require Plotchart

proc PlotSine {c} {
    set s [::Plotchart::createXYPlot $c {5.0 25.0 5.0} {-1.5 1.5 0.25}]
    $s dataconfig series1 -colour "red"
    set xd 0.1
    set xold 0.0
    for { set i 0 } { $i < 200 } { incr i } {
	set xnew [expr {$xold+$xd}]
	set ynew [expr {sin($xnew)}]
	$s plot series1 $xnew $ynew
	set xold $xnew
    }
}

# Calculate grid step by simple procedure
proc GrSeriesGridStep {min max} {
    return [ expr pow(10, int(log10(abs($max - $min)))) ]
}

# Take on input minimum and maximum values on input as well as grid
# step.  Changes grid step to reasonable value (to have at least 4
# grid lines) and changes minimum and maximum values accordingly to
# place them at grid point.  Ticks for grid are calculated too.
proc GrSeriesAxis {minIn maxIn gridIn minOut maxOut gridOut ticksOut} {
    upvar $minOut min  $maxOut max  $gridOut grid  $ticksOut ticks

    #puts "min=$minIn max=$maxIn grid=$gridIn -> [expr int(abs($maxIn - $minIn) / $grid)]"
    set grid $gridIn
    if { [expr int(abs($maxIn - $minIn) / $grid)] < 4 } {
	set grid [expr $grid * 0.5]
    }
    if { [expr int(abs($maxIn - $minIn) / $grid)] < 4 } {
	set grid [expr $grid * 0.5]
    }
    
    set min [expr {$grid * int($minIn / $grid)}]
    if { $min > $minIn } {
	set min [expr $min - $grid]
    }
    set max [expr {$grid * int($maxIn / $grid)}]
    if { $max < $maxIn } {
	set max [expr $max + $grid]
    }
    #puts "mm: $minIn .. $maxIn -> $min .. $max"
    set ticks {}
    for { set i 0 } { [expr $i * $grid + $min] <= $max } { incr i } {
	set tick [expr $i * $grid + $min]
	if { $min <= $tick && $tick <= $max } {
	    lappend ticks $tick
	}
    }
}

proc GrSeriesPlot {c} {
    global $c.props
    upvar 0 $c.props props

    puts "GrSeriesPlot $c"
    set dataSeries $props(dataSeries)

    set props(xmin) 0
    set props(xmax) 0
    set xstep 1.0

    for { set iS 0 } { $iS < [llength $dataSeries] } { incr iS } {
	# find argument range
	if { $props(xmax) < [llength [lindex $dataSeries $iS 0]] } {
	    set props(xmax) [llength [lindex $dataSeries $iS 0]]
	}
	# find value range
	if { [llength [lindex $dataSeries $iS]] > 1 && \
		 [llength [lindex $dataSeries $iS 1]] >= 2 } {
	    # there is a predefined {min max} pair
	    if { [info exists props(ymin)] } {
		if { [lindex $dataSeries $iS 1 0] < $props(ymin) } {
		    set props(ymin) [lindex $dataSeries $iS 1 0]
		}
	    } else {
		set props(ymin) [lindex $dataSeries $iS 1 0]
	    }
	    if { [info exists props(ymax)] } {
		if { [lindex $dataSeries $iS 1 1] > $props(ymax) } {
		    set props(ymax) [lindex $dataSeries $iS 1 1]
		}
	    } else {
		set props(ymax) [lindex $dataSeries $iS 1 1]
	    }
	} else {
	    # no predefined {min max}, so let's scan the whole series
	    if { ! [info exists props(ymin)] } {
		set props(ymin) [lindex $dataSeries $iS 0 0]
	    }
	    if { ! [info exists props(ymax)] } {
		set props(ymax) [lindex $dataSeries $iS 0 0]
	    }
	    foreach y [lindex $dataSeries $iS 0] {
		if { $y < $props(ymin) } {
		    set props(ymin) $y
		}
		if { $y > $props(ymax) } {
		    set props(ymax) $y
		}
	    }
	}
    }
    puts "x: $props(xmin) $props(xmax)"
    puts "y: $props(ymin) $props(ymax)"

    set xgrid [GrSeriesGridStep $props(xmin) $props(xmax)]
    set ygrid [GrSeriesGridStep $props(ymin) $props(ymax)]
    puts "xgrid: $xgrid"
    puts "ygrid: $ygrid"
    set xticks {}
    GrSeriesAxis $props(xmin) $props(xmax) $xgrid xmin xmax xgrid xticks
    set yticks {}
    GrSeriesAxis $props(ymin) $props(ymax) $ygrid ymin ymax ygrid yticks

    # ticks to grid nodes
    set xgrid_matrix {}
    set ygrid_matrix {}
    foreach y $yticks {
	lappend xgrid_matrix $xticks
	set yrow {}
	foreach x $xticks {
	    lappend yrow $y
	}
	lappend ygrid_matrix $yrow
    }
    #puts ${xgrid_matrix}
    #puts ${ygrid_matrix}

    global $c.bDrawLegend $c.bDrawGrid
    upvar 0 $c.bDrawLegend bDrawLegend $c.bDrawGrid bDrawGrid

    set pixwidth [winfo width $c]
    set colors {red green blue magenta cyan yellow black brown grey violet}
    set s [::Plotchart::createXYPlot $c \
	       [list $props(xmin) $props(xmax) $xgrid] \
	       [list $ymin $ymax $ygrid]]
    if { $bDrawGrid } {
	$s grid ${xgrid_matrix} ${ygrid_matrix}
    }
    for { set iS 0 } { $iS < [llength $dataSeries] } { incr iS } {
	# Draw series iS
	set iColor [expr {$iS % [llength $colors]}]
	$s dataconfig series$iS -colour [lindex $colors $iColor]
	if { $bDrawLegend } {
	    $s legend series$iS [lindex $dataSeries $iS 2 0]
	}

	# considering the screen has ~1000 pixels it's not wise to
	# draw too much data points
	set iStep [expr int([llength [lindex $dataSeries $iS 0]] / $pixwidth) - 1]
	if { $iStep <= 0 } {
	    set iStep 1
	}
	#puts "iSeries=$iS -> plotting step $iStep"
	for { set x $props(xmin); set i 0 } \
	    { $i < [llength [lindex $dataSeries $iS 0]] } \
	    { set x [expr {$props(xmin) + $i * $xstep}]; incr i $iStep } {
		$s plot series$iS $x [lindex $dataSeries $iS 0 $i]
	    }
    }
}

proc GrSeriesDoPlot {c} {
    # Clean up the contents (see also the note below!)
    $c delete all

    # (Re)draw
    GrSeriesPlot $c
}

proc GrSeriesDoResize {c} {
    global GrSeriesDoResize_redo
    # To avoid redrawing the plot many times during resizing,
    # cancel the callback, until the last one is left.
    if { [info exists GrSeriesDoResize_redo] } {
        after cancel ${GrSeriesDoResize_redo}
    }
    set redo [after 50 "GrSeriesDoPlot $c"]
}

# Read data series file into {{{col1}{min1
# max1}{name1}}...{{colN}{minN maxN}{nameN}}} resulting data
# structure.
proc GrSeriesReadFile {filepath} {
    if [ catch {open $filepath r} fd ] {
	puts stderr "Failed to open $filepath: $fd"
	return
    }
    # read all lines
    set contents [split [read -nonewline $fd] \n]
    close $fd

    set fname [file tail $filepath]

    # let's find number of columns in the file
    set line0 [lindex $contents 0]
    set tail $line0
    set numCol 0
    # parse first numeric field and get the rest part of line
    #puts "$tail"
    #while { [regexp {(\-?\d+(\.\d*)?([eE][+-]?\d+)?)\s+(.*)$} $tail match ] }
    set minmax {}
    while { [regexp {\s*(\-?\d+(\.\d*)?([eE][+-]?\d+)?)(.*)$} $tail match \
		 fpnum frac exp rest] } {
	set resData($numCol) {}
	incr numCol
	set tail $rest
	lappend minmax {}
	#puts "$numCol: fpnum=$fpnum frac=$frac exp=$exp rest=\"$rest\""
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
	    set fNum [expr 1.0 * $fpnum]
	    if { $iCol < $numCol } {
		lappend resData($iCol) $fNum
		if { {} == [lindex $minmax $iCol] } {
		    lset minmax $iCol "$fNum $fNum"
		} else {
		    if { $fNum < [lindex $minmax $iCol 0] } {
			lset minmax $iCol 0 $fNum
		    }
		    if { $fNum > [lindex $minmax $iCol 1] } {
			lset minmax $iCol 1 $fNum
		    }
		}
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
	lappend resList [list $resData($iCol) [lindex $minmax $iCol] \
			     $fname#$iCol ]
    }
    #puts $resList
    return $resList
}

# Add series in format {data} or {{data}{min max}{name}}
proc GrSeriesAddSeries {p series {name ""}} {
    if {[llength $series] == 0} return

    set c $p.grseries.graphics.c

    global $c.props
    upvar 0 $c.props props

    if {[llength $series] > 1 && [llength [lindex $series 0]] > 1 &&
	[llength [lindex $series 1]] >= 2} {
	# Thinking series has format {{data}{min max}...}
	lappend props(dataSeries) $series
	# Replace name if exact one is given
	if {$name != ""} {
	    lset props(dataSeries) end 2 $name
	}
    } else {
	# Simple list, so let's find min and max
	set ymin [lindex $series 0]
	set ymax [lindex $series 0]
	foreach y $series {
	    if { $y < $ymin } {
		set ymin $y
	    }
	    if { $y > $ymax } {
		set ymax $y
	    }
	}
	lappend props(dataSeries) $series "$ymin $ymax" "$name"
    }
}

proc GrSeriesWindow {p title {filepath ""}} {
    #set dataByColumns = ReadSeries $filepath
    set w $p.grseries
    catch {destroy $w}
    toplevel $w
    wm title $w $title

    set c $w.graphics.c
    frame $w.graphics
    grid [canvas $c -background white -width 600 -height 300] -sticky news
    grid columnconfigure $w.graphics 0 -weight 1
    grid rowconfigure $w.graphics 0 -weight 1
    pack $w.graphics -expand yes -fill both -side top

    global $c.props
    upvar 0 $c.props props
    if { $filepath != "" } {
	set props(dataSeries) [GrSeriesReadFile $filepath]
    }

    global $c.bDrawLegend
    set $c.bDrawLegend 1

    global $c.bDrawGrid
    set $c.bDrawGrid 1

    bind $c <Configure> "GrSeriesDoResize $c"

    frame $w.buttons
    pack $w.buttons -side bottom -fill x -pady 2m
    button $w.buttons.ok -text "OK"
    button $w.buttons.axis -text "Axis..."
#	-command "TrFuncWindowOk $w $w.file.entry globalFileName"
    button $w.buttons.cancel -text "Cancel" -command "destroy $w"

    frame $w.buttons.options
    checkbutton $w.buttons.options.grid -text "Grid" \
	-variable $c.bDrawGrid -command "GrSeriesDoPlot $c"
    checkbutton $w.buttons.options.legend -text "Legend" \
	-variable $c.bDrawLegend -command "GrSeriesDoPlot $c"
    grid $w.buttons.options.grid -sticky w
    grid $w.buttons.options.legend -sticky w

    pack $w.buttons.ok $w.buttons.axis $w.buttons.options \
	$w.buttons.cancel -side left -expand 1
}

#GrSeriesWindow "" "Series plot" testdata/sine1k.dat
GrSeriesWindow "" "Series plot" testdata/r.dat
GrSeriesAddSeries "" "[lindex [GrSeriesReadFile testdata/sine1k.dat] 0]" "Синус"
#GrSeriesWindow "" "Series plot" testdata/test.dat
#puts [GrSeriesReadFile testdata/test.dat]
