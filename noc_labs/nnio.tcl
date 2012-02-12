package provide nnio 1.0

# Return default structure which can be used as array.
proc NNDefault {} {
    return {
	nHidLayers 0
	nHidNeurons {}
	nInputsNumber 1
	nInputsRepeat 1
	nOutputsRepeat 0
	nFeedbackDepth 0
	nOutNeurons 1
	eLastActFunc "linear"
	vInputDelays {0}
	vOutputDelays {0}
	vInputScaler {{-1 1}}
	vOutputScaler {{-1 1}}
	mWeight {{0.01}}
	vBias {{0.0}}
    }
}

# Return architecture in format acceptable for DrawNeuralNetArch
proc NNReadFile {filepath} {
    if [ catch {open $filepath r} fd ] {
	error "Failed to open $filepath: $fd"
	return
    }
    # default
    array set nnar [NNDefault]

    # read all lines
    set contents [split [read -nonewline $fd] \n]
    close $fd

    foreach line $contents {
	if [regexp {^\s*;} $line match] {
	    # comment - let's skip it
	    continue
	}
	if [regexp {^\s*\[\s*NeuralNet\s*[^\]]*\]} $line match] {
	    if {[info exists nnName]} {
		# error
		puts stderr "Not the only NeuralNet in file!"
		return
	    }
	    regexp {^\s*\[\s*NeuralNet\s+([^\]]*)\]} $line match nnName
	    set lineNo 0
	    continue
	}
	if {![info exists nnName]} {
	    # before [NeuralNet] anything is allowed
	    continue
	}
	# let's count lines inside the section
	incr lineNo
	switch -exact $lineNo {
	    1 {
		regexp {^\s*(\d+)\s+(\d+)} $line match nInputs nInpRep
		set nnar(nInputsNumber) $nInputs
		set nnar(nInputsRepeat) $nInpRep
		set nInputDelays $nInpRep
		set nnar(vInputDelays) {}
		set nInputScalers [expr $nInputs * $nInpRep]
		set nnar(vInputScaler) {}
		set nLayerInputs [expr $nInputs * $nInpRep]
	    }
	    2 {
		regexp {^\s*(\d+)} $line match nOutRep
		set nnar(nOutputsRepeat) $nOutRep
		set nOutputDelays $nOutRep
		set nnar(vOutputDelays) {}
	    }
	    3 {
		regexp {^\s*(\d+)} $line match nFeedback
		set nnar(nFeedbackDepth) $nFeedback
	    }
	    4 {
		regexp {^\s*(\d+)} $line match nHidLayers
		set iLayer 0
		set listHidLayers {}
		set nnar(nHidLayers) $nHidLayers
		set nnar(nHidNeurons) {}

		set nWeights 0
		set nBiases 0
		set readWeights {}
		set readBiases {}

		set iC {}
		set iI {}
		set nnar(mWeight) {}
		set nnar(vBias) {}
	    }
	    default {
		if {[incr nHidLayers -1] >= 0} {
		    regexp {^\s*(\d+)} $line match num
		    lappend listHidLayers "$num tanh"
		    lappend nnar(nHidNeurons) $num
		    # Count total number of weights and biases
		    incr nWeights [expr $nLayerInputs * $num]
		    incr nBiases $num
		    # Remember plan to read values
		    for {set i 0} {$i < $num} {incr i} {
			lappend readWeights $iLayer $i $nLayerInputs
		    }
		    incr iLayer
		    # Next layer will have current layer's neurons as input
		    set nLayerInputs $num
		} elseif {![info exists eOutType] && ![info exists nOutputs]} {
		    regexp {^\s*(\w+)\s+(\d+)} $line match eOutType nOutputs
		    set nnar(nOutNeurons) $nOutputs
		    set nnar(eLastActFunc) $eOutType
		    set nOutputScalers [expr $nOutputs * $nOutRep]
		    set nnar(vOutputScaler) {}

		    if {$nnar(nHidLayers) > 0} {
			incr nWeights [expr $nOutputScalers * \
					   [lindex $nnar(nHidNeurons) 0]]
			# Remember plan to read values
			set newReadWeights {}
			foreach {iL iN nLinputs} $readWeights {
			    if {$iL == 0} {
				lappend newReadWeights $iL $iN \
				    [expr $nLinputs + $nOutputScalers]
			    } else {
				lappend newReadWeights $iL $iN $nLinputs
			    }
			}
			set readWeights $newReadWeights
		    }
		    incr nWeights [expr $nOutputScalers * \
					   [lindex $nnar(nHidNeurons) end]]
		    incr nBiases $nOutputScalers
		    #puts "total: $nWeights weights, $nBiases biases"
		    # Remember plan to read values
		    for {set i 0} {$i < $nOutputs} {incr i} {
			lappend readWeights $iLayer $i $nLayerInputs
		    }
		    #puts "plan to read weights: $readWeights"
		} elseif {[incr nInputDelays -1] >= 0} {
		    regexp {^\s*(\d+)} $line match delay
		    lappend nnar(vInputDelays) $delay
		} elseif {[incr nOutputDelays -1] >= 0} {
		    regexp {^\s*(\d+)} $line match delay
		    lappend nnar(vOutputDelays) $delay
		} elseif {$nBiases > 0 || $nWeights > 0} {
		    regexp {^\s*([^\s;]+)} $line match value
		    # TODO: read mWeight and vBias according to readWeights
		    if {$iC == {}} {
			set iC 0
			set mWeight {}
			set curBias {}
		    }
		    set iL [lindex $readWeights [expr 3 * $iC + 0]]
		    set iN [lindex $readWeights [expr 3 * $iC + 1]]
		    set nI [lindex $readWeights [expr 3 * $iC + 2]]
		    if {$iI == {}} {
			set iI 0
			set curWeights {}
		    }
		    if {$curBias != {} && $iN == 0 && $iI == 0} {
			lappend nnar(vBias) $curBias
			set curBias {}
		    }
		    if {$iI == 0} {
			lappend curBias $value
			incr nBiases -1
			if {$nBiases == 0} {
			    lappend nnar(vBias) $curBias
			    set curBias {}
			}
		    } elseif {$iI <= $nI} {
			lappend curWeights $value
			incr nWeights -1
		    }
		    incr iI
		    if {$iI > $nI} {
			#puts "$iL $iN: $curBias / $curWeights"
			lappend mWeight $curWeights
			set iI {}
			incr iC
		    }
		} elseif {[incr nInputScalers -1] >= 0} {
		    if {[regexp {^\s*([^\s;]+)\s+([^\s;]+)} $line match min max]} {
			lappend nnar(vInputScaler) [list $min $max]
		    } else {
			# Failed to read input scaler properly:
			puts stderr "Wrong NeuralNet format: failed to read input scaler"
			lappend nnar(vInputScaler) [list -1 1]
		    }
		} elseif {[incr nOutputScalers -1] >= 0} {
		    if {[regexp {^\s*([^\s;]+)\s+([^\s;]+)} $line match min max]} {
			lappend nnar(vOutputScaler) [list $min $max]
		    } else {
			# Failed to read output scaler properly:
			puts stderr "Wrong NeuralNet format: failed to read output scaler"
			lappend nnar(vOutputScaler) [list -1 1]
		    }
		}
	    }
	}
    }
    set iC 0
    foreach {iL iN dummy} $readWeights {
	set w [lindex $mWeight $iC]
	#puts "$iL $iN, put weights $w"
	incr iC
	if {$iN == 0} {
	    set nnar(mWeight) [linsert $nnar(mWeight) $iL [list $w]]
	} else {
	    set nnar(mWeight) [lreplace $nnar(mWeight) $iL $iL \
				   [linsert [lindex $nnar(mWeight) $iL] $iN $w]]
	}
    }
    if {[info exists nnName] && [info exists nInputs] && \
	    [info exists nInpRep] && \
	    [info exists nOutRep] && [info exists nFeedback] && \
	    [info exists nHidLayers] && [info exists listHidLayers] && \
	    [info exists eOutType] && [info exists nOutputs]} {
	return [array get nnar]
    }
    puts stderr "Wrong NeuralNet format!"
    return
}

proc NNTest {} {
    NNReadFile testdata/test.nn
}
