package provide win_rtseries 1.0

package require Tk
package require Plotchart
#package require universal
#package require win_grseries


# c - canvas to plot at;
# title - window title;
# rtreader - procedure to take one more time sample of data;
# rtparam - named parameters (startLen,deltaTime,...)
# rtseries - list of runtime series: {{"Label" GetValue}...}
proc RtSeriesWindow {c title rtreader rtparam rtseries} {
    array set par $rtparam
    set s [::Plotchart::createXYPlot $c {1.0 200.0 50.0} {0.0 1.5 0.5}]
    # Palette a'la Gnuplot
    set colors {red green blue magenta cyan yellow black brown grey violet}
    set j 0
    foreach rts $rtseries {
	$s dataconfig series$j -colour [lindex $colors $j]
	$s legend series$j [lindex $rts 0]
	incr j
    }

    set dt 1
    set tprev 0.0
    set i 0
    while {{} != [set input [$rtreader]]} {
	set tcur [expr {$tprev + $dt}]
	update
	after 50
	set j 0
	foreach rts $rtseries {
	    set getvalue [lindex $rts 1]
	    set val [$getvalue $j [lindex $rts 0] $input]
	    if {$val != {}} {
		$s plot series$j $tcur $val
	    }
	    incr j
	}
	incr i
	set tprev $tcur
    }
    # reader returned {} or break occured
}


# parindex - parameter index (0,1,2...);
# parname - parameter's name (label);
# input - result of the reader;
proc RtSeriesTestGetValue {parindex parname input} {
    return [lindex $input $parname]
}

# Return: list of input data
proc RtSeriesTestReader {} {
    gets stdin line
    return [split $line]
}

proc RtSeriesTest {} {
    canvas .c -width 400 -height 250
    pack .c
    
    set fname "testdata/nncp_trace.dat"
    set series {
	{5 RtSeriesTestGetValue}
	{6 RtSeriesTestGetValue}
    }
    RtSeriesWindow .c "RtSeriesTest" RtSeriesTestReader {} $series
    puts Finish
}

#wish win_rtseries.tcl <testdata/nncp_trace.dat
#RtSeriesTest
