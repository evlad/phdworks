# Return architecture in format acceptable for DrawNeuralNetArch
proc ReadNeuralNetFile {filepath} {
    if [ catch {open $filepath r} fd ] {
	puts stderr "Failed to open $filepath: $fd"
	return
    }
    # read all lines
    set contents [split [read -nonewline $fd] \n]
    close $fd

    foreach line $contents {
	if [regexp {^\s*;} $line match] {
	    # comment - let's skip it
	    continue
	}
	if [regexp {^\s*\[\s*NeuralNet\s*[^\]]*\]} $line match] {
	    if {[info exist nnName]} {
		# error
		puts stderr "Not the only NeuralNet in file!"
		return
	    }
	    regexp {^\s*\[\s*NeuralNet\s+([^\]]*)\]} $line match nnName
	    set lineNo 0
	    continue
	}
	if {![info exist nnName]} {
	    # before [NeuralNet] anything is allowed
	    continue
	}
	# let's count lines inside the section
	incr lineNo
	switch -exact $lineNo {
	    1 {
		regexp {^\s*(\d+)\s+(\d+)} $line match nInputs nInpRep
	    }
	    2 {
		regexp {^\s*(\d+)} $line match nOutRep
	    }
	    3 {
		regexp {^\s*(\d+)} $line match nFeedback
	    }
	    4 {
		regexp {^\s*(\d+)} $line match nHidLayers
		set iHidLayer 0
		set listHidLayers {}
	    }
	    default {
		if {[info exist iHidLayer]} {
		    if {$iHidLayer < $nHidLayers} {
			regexp {^\s*(\d+)} $line match num
			lappend listHidLayers "$num tanh"
			incr iHidLayer
		    } else {
			unset iHidLayer
		    }
		}
		if {$lineNo == [expr $nHidLayers + 5]} {
		    regexp {^\s*(\w+)\s+(\d+)} $line match eOutType nOutputs
		}
	    }
	}
    }
    if {[info exist nnName] && [info exist nInputs] && [info exist nInpRep] && \
	    [info exist nOutRep] && [info exist nFeedback] && \
	    [info exist nHidLayers] && [info exist listHidLayers] && \
	    [info exist eOutType] && [info exist nOutputs]} {
	set nnArch "[expr $nInputs * $nInpRep + $nOutputs * $nOutRep] \
	    $listHidLayers"
	lappend nnArch "$nOutputs $eOutType"
	return $nnArch
    }
    puts stderr "Wrong NeuralNet format!"
    return {}
}

# nnarch = {Inputs {HidNeurons1 HidType1} {HidNeurons2 HidType2} ...
# {Outputs OutputType}}, where type is "linear" or "tanh"
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

    set inputs [lindex $nnarch 0]
    set layers [lrange $nnarch 1 end]
    set outputLayer [lindex $nnarch end]
    set inputs [lindex $nnarch 0]

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
	if {![info exist prevNum]} {
	    for {set iN 0} {$iN < $num} {incr iN} {
		set finalX [expr $x + $LayersDist]
		set finalY [expr $yL + $HalfNS + 2 * $iN * $NeuronSize]
		$c create line $HalfLD $finalY $finalX $finalY
		#$c create oval [expr $finalX - 2] [expr $finalY - 2] \
		#    [expr $finalX + 2] [expr $finalY + 2] -fill black
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
#TestDrawNeuralNetArch {8 {4 "tanh"} {1 "linear"}}
