#

#set font "-*-helvetica-*-r-*-*-14-*-*-*-*-*-koi8-*"

source draw_prim.tcl

#proc Run {pb} {
#    puts "TODO: Run dcsloop"
#    #catch {[exec dcsloop dcsloop.par >/dev/null 2>dcsloop.err]} errCode
#}

proc DrawPanel {c} {
    DrawLargeBlock $c reference "Уставка" 1.8c 4c
    DrawSmallBlock $c checkpoint_r "r" 3.5c 4c
    DrawGather $c cerr 4.5c 4c "s"
    DrawSmallBlock $c checkpoint_e "e" 5.4c 4c
    DrawLargeBlock $c controller "Регулятор" 7.1c 4c
    DrawSmallBlock $c checkpoint_u "u" 8.8c 4c
    DrawLargeBlock $c plant "Объект" 10.4c 4c
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

proc TestPanel {c} {
    option readfile noc_labs.ad

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

    DrawPanel $c
}

#TestPanel ""
