package provide draw_prim 1.0

package require Tk

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
    if { $minusps == "e" } {
	$c create arc $x1 $y1 $x2 $y2 -start 315 -extent 90 -style pieslice \
	    -fill black
    }
    if { $minusps == "w" } {
	$c create arc $x1 $y1 $x2 $y2 -start 135 -extent 90 -style pieslice \
	    -fill black
    }
}

proc DrawLargeBlock {c name label x y} {
    button $c.$name -text $label -padx 1m -pady 1m
    set font [option get $c.$name fontBlock ""]
    if { $font != "" } {
	$c.$name config -font $font
    }
    $c create window $x $y -window $c.$name -tags $name
}

proc DrawSmallBlock {c name label x y} {
    button $c.$name -text $label -padx 1m -pady 0
    set font [option get $c.$name fontBlock ""]
    if { $font != "" } {
	$c.$name config -font $font
    }
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
# dirflag - arrow flag for direct arrow link and 4 addition values:
# "hor" and "ver", which mean arrow should go to target point
# horizontally (vertically) the first; "horOnly" and "verOnly", which
# mean arrow should go to target point horizontally (vertically) only
# and avoiding another direction at all.
proc DrawDirection {c block1 ps1 block2 ps2 dirflag} {
    set bb1 [$c bbox $block1]
    set bb2 [$c bbox $block2]
    set p1 [BBoxSpecPoint $bb1 $ps1]
    set p2 [BBoxSpecPoint $bb2 $ps2]
    switch -exact $dirflag {
	"horOnly" {
	    DrawArrow $c [lindex $p1 0] [lindex $p1 1] \
		[lindex $p2 0] [lindex $p1 1] last
	}
	"hor" {
	    DrawArrow $c [lindex $p1 0] [lindex $p1 1] \
		[lindex $p2 0] [lindex $p1 1] middle
	    DrawArrow $c [lindex $p2 0] [lindex $p1 1] \
		[lindex $p2 0] [lindex $p2 1] middle
	}
	"verOnly" {
	    DrawArrow $c [lindex $p1 0] [lindex $p1 1] \
		[lindex $p1 0] [lindex $p2 1] last
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
