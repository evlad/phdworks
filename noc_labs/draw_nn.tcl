package provide draw_nn 1.0

package require Tk
package require screenshot
package require nnio

# nnarch = {{Inputs [InputLabels]} {HidNeurons1 HidType1} {HidNeurons2
# HidType2} ...  {Outputs OutputType OutputLabels}}, where type is
# "linear" or "tanh" and InputLabels or/and OutputLabels may be
# absent.
proc DrawNeuralNetArch {c nnarch} {
    set totalW [winfo width $c]
    set totalH [winfo height $c]
    if { $totalW <= 1 && $totalH <= 1} {
	# Just for tests because method above gives totalW=1 totalH=1
	set totalW [$c cget -width]
	set totalH [$c cget -height]
    }
    # Base point to shift the picture
    set x 0
    set y 2
    # To prevent neurons slightly to go out of picture
    set totalH [expr $totalH - $y * 2]

    set inputs [lindex $nnarch 0 0]
    set layers [lrange $nnarch 1 end]
    set outputLayer [lindex $nnarch end]
    set inputLabels [lindex $nnarch 0 1]
    set outputLabels [lindex $nnarch end 2]
    # Distance in pixels between end of line and label
    set labelHorOffset 3

    set MaxNeuronsInLayer $inputs
    foreach layer $layers {
	set num [lindex $layer 0]
	if {$num > $MaxNeuronsInLayer} {
	    set MaxNeuronsInLayer $num
	}
    }

    # Calculate size of neuron (and distance between them)
    if {$MaxNeuronsInLayer == 1} {
	set NeuronSize [expr int($totalH / 8)]
    } else {
	set NeuronSize [expr int($totalH / (2 * $MaxNeuronsInLayer - 1))]
    }
    set HalfNS [expr int($NeuronSize / 2)]

    # Calculate distance between layers
    set LayersDist [expr int($totalW / (2 + [llength $layers]))]
    set HalfLD [expr int($LayersDist / 2)]

    # Make new list of layers considering input one with special type
    # of nodes: dots
    set layers [linsert $layers 0 "$inputs dot"]

    # Draw lines
    set iL 0
    foreach layer $layers {
	set num [lindex $layer 0]
	set type [lindex $layer 1]
	set yL [expr $y + ($totalH - $NeuronSize * (2 * $num - 1)) / 2]
	if {![info exists prevNum]} {
	    # Inputs
	    for {set iN 0} {$iN < $num} {incr iN} {
		set finalX [expr $x + $LayersDist]
		set finalY [expr $yL + $HalfNS + 2 * $iN * $NeuronSize]
		$c create line $HalfLD $finalY $finalX $finalY
		#$c create oval [expr $finalX - 2] [expr $finalY - 2] \
		#    [expr $finalX + 2] [expr $finalY + 2] -fill black
		set label [lindex $inputLabels $iN]
		if {$label != ""} {
		    $c create text [expr $HalfLD - $labelHorOffset] $finalY \
			-justify right -anchor e -text $label
		}
	    }
	} else {
	    set yP [expr $y + ($totalH - $NeuronSize * (2 * $prevNum - 1)) / 2]
	    for {set iP 0} {$iP < $prevNum} {incr iP} {
		for {set iN 0} {$iN < $num} {incr iN} {
		    set startX [expr $x + $iL * $LayersDist]
		    set startY [expr $yP + $HalfNS + 2 * $iP * $NeuronSize]
		    set finalX [expr $x + ($iL + 1) * $LayersDist]
		    set finalY [expr $yL + $HalfNS + 2 * $iN * $NeuronSize]
		    $c create line $startX $startY $finalX $finalY
		    #$c create oval \
		#	[expr $finalX - $HalfNS] [expr $finalY - $HalfNS] \
		#	[expr $finalX + $HalfNS] [expr $finalY + $HalfNS]
		}
	    }
	}
	incr iL
	set prevNum $num
    }
    # Ouputs
    for {set iN 0} {$iN < $prevNum} {incr iN} {
	set yL [expr $y + ($totalH - $NeuronSize * (2 * $num - 1)) / 2]
	set startX [expr $x + $iL * $LayersDist]
	set startY [expr $yL + $HalfNS + 2 * $iN * $NeuronSize]
	$c create line $startX $startY [expr $startX + $HalfLD] $startY
	set label [lindex $outputLabels $iN]
	if {$label != ""} {
	    $c create text [expr $startX + $HalfLD + $labelHorOffset] $startY \
		-justify left -anchor w -text $label
	}
    }

    # Draw neurons
    unset prevNum
    set iL 0
    foreach layer $layers {
	set num [lindex $layer 0]
	set type [lindex $layer 1]
	set yL [expr $y + ($totalH - $NeuronSize * (2 * $num - 1)) / 2]
	for {set iN 0} {$iN < $num} {incr iN} {
	    set finalX [expr $x + ($iL + 1) * $LayersDist]
	    set finalY [expr $yL + $HalfNS + 2 * $iN * $NeuronSize]
	    switch -exact $type {
		dot {
		    $c create oval [expr $finalX - 2] [expr $finalY - 2] \
			[expr $finalX + 2] [expr $finalY + 2] -fill black
		}
		tanh {
		    $c create oval \
			[expr $finalX - $HalfNS] [expr $finalY - $HalfNS] \
			[expr $finalX + $HalfNS] [expr $finalY + $HalfNS] \
			-fill white
		    $c create line $finalX $finalY \
			$finalX [expr $finalY - int($HalfNS/2)] \
			[expr $finalX + int(2*$HalfNS/3)] \
			[expr $finalY - int($HalfNS/2)] \
			-smooth bezier -fill brown
		    $c create line $finalX $finalY \
			$finalX [expr $finalY + int($HalfNS/2)] \
			[expr $finalX - int(2*$HalfNS/3)] \
			[expr $finalY + int($HalfNS/2)] \
			-smooth bezier -fill brown
		}
		linear {
		    $c create oval \
			[expr $finalX - $HalfNS] [expr $finalY - $HalfNS] \
			[expr $finalX + $HalfNS] [expr $finalY + $HalfNS] \
			-fill white
		    $c create line \
			[expr $finalX - int($HalfNS/2)] \
			[expr $finalY + int($HalfNS/2)] \
			[expr $finalX + int($HalfNS/2)] \
			[expr $finalY - int($HalfNS/2)] \
			-fill blue
		}
	    }
	}
	incr iL
    }
}

proc DisplayNeuralNetArch {p title nnFilePath} {
    set w $p.display_nnarch
    catch {destroy $w}
    toplevel $w

    wm title $w $title

    button $w.close -text "Закрыть" -command "destroy $w"

    canvas $w.c -width 400 -height 200

    ScreenshotButton $w $w.print $w.c [file dirname $nnFilePath] [file tai $nnFilePath]

    pack $w.close $w.print -side bottom -expand 1
    pack $w.c -fill both -expand yes
    set nnarch [NNReadFile $nnFilePath]
    DrawNeuralNetArch $w.c [NNSimpleArch $nnarch]
}

proc TestDrawNeuralNetArch {{nnarch {6 {7 "tanh"} {4 "tanh"} {3 "linear"}}}} {
    canvas .c -width 400 -height 200
    #canvas .c -width 800 -height 500
    pack .c -fill both -expand yes
    #puts "[winfo width .c]"
    #while {[winfo width .c] == 1} {
    #    # wait
    #}
    DrawNeuralNetArch .c $nnarch
}

#TestDrawNeuralNetArch
#TestDrawNeuralNetArch [ReadNeuralNetFile testdata/test.nn]
#TestDrawNeuralNetArch {{8 {i1 i2 i3 i4 i5 i6 i7 i8}} {4 "tanh"} {1 "linear" {o1}}}
