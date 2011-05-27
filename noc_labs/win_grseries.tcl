package provide win_grseries 1.0

package require Tk
package require Plotchart
package require data_file
package require universal

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

# Returns xmin xmax ymin ymax
proc GrSeriesMinMax {dataSeries} {
    set xmin 0
    set xmax 0
    for { set iS 0 } { $iS < [llength $dataSeries] } { incr iS } {
	# find argument range
	if { $xmax < [llength [lindex $dataSeries $iS 0]] } {
	    set xmax [llength [lindex $dataSeries $iS 0]]
	}
	# find value range
	if { [llength [lindex $dataSeries $iS]] > 1 && \
		 [llength [lindex $dataSeries $iS 1]] >= 2 } {
	    # there is a predefined {min max} pair
	    if { [info exists ymin] } {
		if { [lindex $dataSeries $iS 1 0] < $ymin } {
		    set ymin [lindex $dataSeries $iS 1 0]
		}
	    } else {
		set ymin [lindex $dataSeries $iS 1 0]
	    }
	    if { [info exists ymax] } {
		if { [lindex $dataSeries $iS 1 1] > $ymax } {
		    set ymax [lindex $dataSeries $iS 1 1]
		}
	    } else {
		set ymax [lindex $dataSeries $iS 1 1]
	    }
	} else {
	    # no predefined {min max}, so let's scan the whole series
	    if { ! [info exists ymin] } {
		set ymin [lindex $dataSeries $iS 0 0]
	    }
	    if { ! [info exists ymax] } {
		set ymax [lindex $dataSeries $iS 0 0]
	    }
	    foreach y [lindex $dataSeries $iS 0] {
		if { $y < $ymin } {
		    set ymin $y
		}
		if { $y > $ymax } {
		    set ymax $y
		}
	    }
	}
    }
    return [list $xmin $xmax $ymin $ymax]
}

proc GrSeriesPlot {c} {
    global $c.props
    upvar #0 $c.props props

    #puts "GrSeriesPlot $c"

    if { ! [info exists props(dataSeries)] } return
    set dataSeries $props(dataSeries)

    puts "Number of series: [llength $dataSeries]"
    if {[llength $dataSeries] == 0 } return

    # xmin,xmax,ymin,ymax - outer bounding box of data series
    # $c.view_* - view area

    unlist [GrSeriesMinMax $dataSeries] xmin xmax ymin ymax

    #puts "outer x: $xmin $xmax"
    #puts "outer y: $ymin $ymax"

    # Store bounds of view area
    foreach v {xmin xmax ymin ymax} {
	global $c.view_$v
	if {![info exists $c.view_$v] || [set $c.view_$v] == {}} {
	    #puts "assign: set $c.view_$v \$$v"
	    eval set $c.view_$v \$$v
	}
    }

    #puts "view x: $xmin $xmax"
    #puts "view y: $ymin $ymax"

    # Copy xmin,xmax,ymin,ymax to props since they are needed to make
    # ZoomAll action
    foreach v {xmin xmax ymin ymax} {
	eval set props($v) \$$v
    }

    #eval set ${v}grid [GrSeriesGridStep \$$c.view_${v}min \$$c.view_${v}max]
    set xgrid [GrSeriesGridStep [set $c.view_xmin] [set $c.view_xmax]]
    set ygrid [GrSeriesGridStep [set $c.view_ymin] [set $c.view_ymax]]

    #puts "xgrid: $xgrid"
    #puts "ygrid: $ygrid"
    set xticks {}
    set yticks {}
    GrSeriesAxis [set $c.view_xmin] [set $c.view_xmax] $xgrid \
	xmin xmax xgrid xticks
    GrSeriesAxis [set $c.view_ymin] [set $c.view_ymax] $ygrid \
	ymin ymax ygrid yticks

    # Store slightly changed view limits back
    foreach v {xmin xmax ymin ymax} {
	eval set \$c.view_$v \$$v
    }

    #puts "plot x: $xmin $xmax"
    #puts "plot y: $ymin $ymax"

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
    upvar #0 $c.bDrawLegend bDrawLegend $c.bDrawGrid bDrawGrid

    set pixwidth [winfo width $c]
    # Palette a'la Gnuplot
    set colors {red green blue magenta cyan yellow black brown grey violet}
    set s [::Plotchart::createXYPlot $c \
	       [list $xmin $xmax $xgrid] \
	       [list $ymin $ymax $ygrid]]
    # $xmin $xmax
    if { $bDrawGrid } {
	$s grid ${xgrid_matrix} ${ygrid_matrix}
    }
    set xstep 1.0
    for { set iS 0 } { $iS < [llength $dataSeries] } { incr iS } {
	# Draw series iS
	set iColor [expr {$iS % [llength $colors]}]
	$s dataconfig series$iS -colour [lindex $colors $iColor]
	if { $bDrawLegend } {
	    $s legend series$iS [lindex $dataSeries $iS 2 0]
	}

	# considering the screen has limited number of pixels it's not
	# wise to draw too much data points
	set iStep [expr int([llength [lindex $dataSeries $iS 0]] / $pixwidth) - 1]
	if { $iStep <= 0 } {
	    set iStep 1
	}
	#puts "iSeries=$iS -> plotting step $iStep"
	for { set x $props(xmin); set i $props(xmin) } \
	    { $i < [llength [lindex $dataSeries $iS 0]] } \
	    { set x [expr {$props(xmin) + $i * $xstep}]; incr i $iStep } {
		$s plot series$iS $x [lindex $dataSeries $iS 0 $i]
	    }
    }
}

# Force external redraw
proc GrSeriesRedraw {p} {
    set c $p.grseries.graphics.c
    GrSeriesDoPlot $c
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

# Add series in format {data} or {{data}{min max}{name}}
proc GrSeriesAddSeries {p series {name ""}} {
    if {[llength $series] == 0} return

    #puts "series: $series"
    #puts "name: $name"

    set c $p.grseries.graphics.c

    global $c.props
    upvar #0 $c.props props

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
	#puts "[list $ymin $ymax] $name"
	set minmax [list $ymin $ymax]
	lappend props(dataSeries) "[list $series] [list $minmax] $name"
	#puts "[lindex $props(dataSeries) end]"
    }
}

proc GrSeriesViewAll {c args} {
    global $c.props
    upvar #0 $c.props props
    set dim $args
    if { $dim == {} } {
	set dim {x y}
    }
    foreach v $dim {
	eval puts \"${v} range: \$props(${v}min) \$props(${v}max)\"
	global $c.view_${v}min
	global $c.view_${v}max
	set $c.view_${v}min $props(${v}min)
	set $c.view_${v}max $props(${v}max)
    }
    #GrSeriesDoPlot $c
}

proc GrSeriesDestroy {c} {
    global $c.props
    array unset $c.props

    foreach v {xmin xmax ymin ymax} {
	global $c.view_$v
	unset $c.view_$v
    }

    global $c.bDrawLegend $c.bDrawGrid
    unset $c.bDrawLegend $c.bDrawGrid
}

# w - widget
# c - canvas to screenshot
# workDir - where to store file
# type - image type to store
proc GrSeriesScreenshot {w c workDir type} {
    # Calculate next free number, considering file names have format
    # ${rootName}##.*, where ## - two digits
    set rootName "grplot"
    set ls [glob -nocomplain -tails -directory $workDir -types f "$rootName\[0-9\]\[0-9\].*"]
    set lastName [lindex [lsort $ls] end]
    if {$lastName == ""} {
	set nextNum 0
    } elseif {[regexp "^${rootName}(..)\..*\$" $lastName rest lastNum]} {
	scan $lastNum "%d" nextNum
	incr nextNum
    } else {
	set nextNum 0
    }

    # Let's compose path
    set rootPath [file join $workDir [format "%s%02d" $rootName $nextNum]]
    switch $type {
	postscript {
	    set filePath "$rootPath.ps"
	    # Margins one the page (mm)
	    set xmar 20
	    set ymar 20
	    $c postscript -colormode color -file $filePath \
		-pagewidth [expr 297 - $xmar].m \
		-pageheight [expr 210 - $ymar].m
	}
	jpeg {
	    set filePath "$rootPath.jpg"
	    set img [image create photo -format window -data $c]
	    $img write -format $type $filePath
	}
	default {
	    # type and file name extension are the same
	    set filePath "$rootPath.$type"
	    set img [image create photo -format window -data $c]
	    $img write -format $type $filePath
	}
    }
    tk_messageBox -parent $w -icon info -type ok -title "Screenshot competed" \
	-message  "Снимок сохранен в файл\n$filePath"
}

proc GrSeriesAddFile {p workDir {filePath ""}} {
    set w $p.grseries
    if {$filePath != ""} {
	if {![file exists $filePath]} {
	    error "Failed to open $filePath"
	    return
	}
    } else {
	set dataFileTypes {
	    {"Файлы данных" {.dat}}
	    {"Все файлы" *}
	}
	set filePath [fileSelectionBox $w open [file join $workDir ""] $dataFileTypes]
	if {$filePath == ""} {
	    # User cancel
	    return
	}
    }
    set wholeData [GrSeriesReadFile $filePath]
    set label [SessionRelPath $workDir $filePath]
    GrSeriesAddSeries $p "[lindex $wholeData 0]" $label
    GrSeriesRedraw $p
}


proc GrSeriesCheckPresence {p} {
    set w $p.grseries
    if {[catch {$w cget -menu} rc]} {
	# It's not a toplevel or does not exist
	return 0
    } else {
	# There is a toplevel with such name
	return 1
    }
}

# p - parent widget
# title - window title
# path - first data file or working directory
proc GrSeriesWindow {p title {path ""}} {
    #set dataByColumns = ReadSeries $filepath
    set w $p.grseries
    catch {destroy $w}
    toplevel $w
    wm title $w $title

    # Determine work directory for screenshots
    if {$path == ""} {
	set workDir [pwd]
	set filepath $path
    } elseif {[file isdirectory $path]} {
	set workDir $path
	set filepath ""
    } else {
	set workDir [file dirname $path]
	set filepath $path
    }

    set c $w.graphics.c
    frame $w.graphics
    grid [canvas $c -background white -width 600 -height 300] -sticky news
    grid columnconfigure $w.graphics 0 -weight 1
    grid rowconfigure $w.graphics 0 -weight 1
    pack $w.graphics -expand yes -fill both -side top

    global $c.props
    upvar #0 $c.props props
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

    set m $w.buttons.print.m
    menubutton $w.buttons.print -text "Снимок экрана" \
	-direction below -menu $m -relief raised
    menu $m -tearoff 0
    set imgfmts {postscript gif}
    if {0 == [catch {package require Img} res]} {
	# It's possible to use wide variety of image formats
	lappend imgfmts png jpeg bmp
    }
    foreach imgfmt $imgfmts {
	$m add command -label $imgfmt \
	    -command "GrSeriesScreenshot $w $c $workDir $imgfmt"
    }

    set m $w.buttons.curves.m
    menubutton $w.buttons.curves -text "Ряды" \
	-direction below -menu $m -relief raised
    menu $m -tearoff 0
    $m add command -label "Добавить..." \
	-command "GrSeriesAddFile $p $workDir"

    set o $w.buttons.options
    frame $o
    checkbutton $o.grid -text "Сетка" \
	-variable $c.bDrawGrid -command "GrSeriesDoPlot $c"
    checkbutton $o.legend -text "Легенда" \
	-variable $c.bDrawLegend -command "GrSeriesDoPlot $c"
    global xmin xmax ymin ymax
    button $o.xlabel -text "X:" -command "GrSeriesViewAll $c x" -pady 0
    button $o.ylabel -text "Y:" -command "GrSeriesViewAll $c y" -pady 0
    foreach v {xmin xmax ymin ymax} {
	global $c.view_$v
	#upvar 0 $c.view_$v view_$v
	entry $o.$v -textvariable $c.view_$v -width 8 -relief sunken
    }
    hint $o.xlabel "Press to set the whole X range"
    hint $o.ylabel "Press to set the whole Y range"

    # after entries to make exact focus order by Tab/Shift-Tab
    button $w.buttons.redraw -text "Обновить" -command "GrSeriesDoPlot $c"
    button $w.buttons.close -text "Закрыть" \
	-command "GrSeriesDestroy $c ; destroy $w"

    grid $o.grid $o.xlabel $o.xmin $o.xmax -sticky w
    grid $o.legend $o.ylabel $o.ymin $o.ymax -sticky w

    pack $w.buttons.print $w.buttons.curves $o $w.buttons.redraw \
	$w.buttons.close -side left -expand 1
}

proc GrSeriesTest {} {
    #GrSeriesWindow "" "Series plot" testdata/sine1k.dat
    #GrSeriesWindow "" "Series plot"
    # testdata/r.dat

    set xd 1
    set xold 0.0
    set func {}
    for { set i 0 } { $i < 1000 } { incr i } {
	set xnew [expr {$xold+$xd}]
	set ynew [expr {0.7*sin(0.02*$xnew)+pow(cos(0.01*$xnew), 2)}]
	#set ynew $xnew
	lappend func $ynew
	set xold $xnew
    }

    set wholeData [GrSeriesReadFile testdata/r.dat]
    GrSeriesAddSeries "" "[lindex $wholeData 0]" "Var1"
    GrSeriesAddSeries "" "[lindex $wholeData 3]" "Var4"
    GrSeriesAddSeries "" "[lindex $wholeData 5]" "Var6"
    #GrSeriesAddSeries "" "[lindex [GrSeriesReadFile testdata/sine1k.dat] 0]" "Синус"
    #GrSeriesAddSeries "" "$func" "Func"
    GrSeriesWindow "" "Series plot"
    # testdata/r.dat
    #puts [GrSeriesReadFile testdata/test.dat]
}
