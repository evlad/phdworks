#

# Oval for adding or subtracting signals depending minusps.
# It may be "none" for adding and "n", "s", "w", "e" for subtracting
# from given direction.
proc DrawGather {c name x y minusps} {
    set hsize 10
    set x1 [expr [$c canvasx $x] - $hsize]
    set y1 [expr [$c canvasy $y] - $hsize]
    set x2 [expr [$c canvasx $x] + $hsize]
    set y2 [expr [$c canvasy $y] + $hsize]
    $c create oval $x1 $y1 $x2 $y2 -tags $name
    if { $minusps == "n" } {
	$c create arc $x1 $y1 $x2 $y2 -start 45 -extent 90 -style pieslice \
	    -fill black
    } else {
	$c create arc $x1 $y1 $x2 $y2 -start 45 -extent 90 -style pieslice
    }
    if { $minusps == "s" } {
	$c create arc $x1 $y1 $x2 $y2 -start 225 -extent 90 -style pieslice \
	    -fill black
    } else {
	$c create arc $x1 $y1 $x2 $y2 -start 225 -extent 90 -style pieslice
    }
    if { $minusps == "w" } {
	$c create arc $x1 $y1 $x2 $y2 -start 315 -extent 90 -style pieslice \
	    -fill black
    }
    if { $minusps == "e" } {
	$c create arc $x1 $y1 $x2 $y2 -start 135 -extent 90 -style pieslice \
	    -fill black
    }
}

proc DrawLargeBlock {c name label x y} {
    button $c.$name -text $label -padx 1m -pady 1m -font {Freesans 11}
    $c create window $x $y -window $c.$name -tags $name
}

proc DrawSmallBlock {c name label x y} {
    button $c.$name -text $label -padx 0 -pady 0
    $c create window $x $y -window $c.$name -tags $name
}

# Convert given bounding box to point specification:
#  n - north (center of the top side)
#  s - north (center of the bottom side)
#  w - west (center of the left side)
#  e - east (center of the right side)
#  nw, ne, sw, se - corners are also available
# Returns {x y}
proc BBoxSpecPoint {bb ps} {
    set xw [lindex $bb 0]
    set yn [lindex $bb 1]
    set xe [lindex $bb 2]
    set ys [lindex $bb 3]
    if { $ps == "n" || $ps == "nw" || $ps == "ne" } {
	set y $yn
    } elseif { $ps == "s" || $ps == "sw" || $ps == "se" } {
	set y $ys
    }
    if { $ps == "w" || $ps == "nw" || $ps == "sw" } {
	set x $xw
    } elseif { $ps == "e" || $ps == "ne" || $ps == "se" } {
	set x $xe
    }

    if { $ps == "n" || $ps == "s" } {
	    set x [expr ($xw + $xe) / 2]
    }
    if { $ps == "w" || $ps == "e" } {
	set y [expr ($yn + $ys) / 2]
    }
    return [list $x $y]
}

# ps1, ps2 - point specification.  May be "n", "s", "w", "e" as well
# as "[ns][we]".
# dirflag - arrow flag for direct arrow link and two addition values:
# "hor" and "ver", which means arrow should go to target point
# horizontally (vertically) the first.
proc DrawDirection {c block1 ps1 block2 ps2 dirflag} {
    set bb1 [$c bbox $block1]
    set bb2 [$c bbox $block2]
    set p1 [BBoxSpecPoint $bb1 $ps1]
    set p2 [BBoxSpecPoint $bb2 $ps2]
    switch -exact $dirflag {
	"hor" {
	    DrawArrow $c [lindex $p1 0] [lindex $p1 1] \
		[lindex $p2 0] [lindex $p1 1] middle
	    DrawArrow $c [lindex $p2 0] [lindex $p1 1] \
		[lindex $p2 0] [lindex $p2 1] middle
	}
	"ver" {
	    DrawArrow $c [lindex $p1 0] [lindex $p1 1] \
		[lindex $p1 0] [lindex $p2 1] middle
	    DrawArrow $c [lindex $p1 0] [lindex $p2 1] \
		[lindex $p2 0] [lindex $p2 1] middle
	}
	default {
	    DrawArrow $c [lindex $p1 0] [lindex $p1 1] \
		[lindex $p2 0] [lindex $p2 1] $dirflag
	}
    }
}

# arrflag - may be "none", "first", "last" and "middle"
proc DrawArrow {c x1 y1 x2 y2 arrflag} {
    if { $arrflag == "middle" } {
	$c create line $x1 $y1 $x2 $y2 -arrow none
	set midx [expr ([$c canvasx $x1] + [$c canvasx $x2]) / 2 ]
	set midy [expr ([$c canvasy $y1] + [$c canvasy $y2]) / 2 ]
	$c create line $x1 $y1 $midx $midy -arrow last
    } else {
	$c create line $x1 $y1 $x2 $y2 -arrow $arrflag
    }
}

proc Run {pb} {
    puts "TODO: Run dcsloop"
    #catch {[exec dcsloop dcsloop.par >/dev/null 2>dcsloop.err]} errCode
}

proc DrawPanel {w} {

    frame $w.controls
    pack $w.controls -side bottom -fill x -pady 2m
    button $w.controls.run -text "Run" -command "Run $w"
    button $w.controls.series -text "Series"
    button $w.controls.close -text "Close" -command "destroy ."
    pack $w.controls.run $w.controls.series \
	 $w.controls.close -side left -expand 1

    frame $w.frame
    pack $w.frame -side top -fill both -expand yes
    set c $w.frame.c

    canvas $c -width 14c -height 7c -relief sunken -borderwidth 2 \
	-background white
    pack $c -side top -fill both -expand yes

    DrawLargeBlock $c reference "Уставка" 1.8c 4c
    DrawSmallBlock $c checkpoint_r "r" 3.5c 4c
    DrawGather $c cerr 4.5c 4c "s"
    DrawSmallBlock $c checkpoint_e "e" 5.3c 4c
    DrawLargeBlock $c controller "Регулятор" 7c 4c
    DrawSmallBlock $c checkpoint_u "u" 8.7c 4c
    DrawLargeBlock $c plant "Объект" 10.3c 4c
    DrawGather $c nadd 12c 4c "none"
    DrawLargeBlock $c noise "Помеха" 12c 1.7c
    DrawSmallBlock $c checkpoint_n "n" 12c 3c
    DrawSmallBlock $c checkpoint_y "y" 12c 5.3c

    DrawDirection $c reference "e" checkpoint_r "w" last
    DrawDirection $c checkpoint_r "e" cerr "w" last
    DrawDirection $c cerr "e" checkpoint_e "w" last
    DrawDirection $c checkpoint_e "e" controller "w" last
    DrawDirection $c controller "e" checkpoint_u "w" last
    DrawDirection $c checkpoint_u "e" plant "w" last
    DrawDirection $c plant "e" nadd "w" last

    DrawDirection $c noise "s" checkpoint_n "n" last
    DrawDirection $c checkpoint_n "s" nadd "n" last
    DrawDirection $c nadd "s" checkpoint_y "n" last

    DrawDirection $c checkpoint_y "w" cerr "s" hor

#    DrawArrow $c 6c 5c 9c 5c middle
#    DrawArrow $c 9c 5c 11c 5c last
#    DrawArrow $c 11c 2c 11c 5c last
}

DrawPanel ""
