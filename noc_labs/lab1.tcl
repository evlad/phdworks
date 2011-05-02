package require win_textedit

source ctrlsysloop.tcl
source win_checkpnt.tcl

proc MenuLab1 {p t} {
    set w "$p.lab1_menu"

    # Don't create lab menu twice
    if {[winfo exists $w]} return

    toplevel $w
    wm title $w "Menu of lab #1"
    wm iconname $w "Lab#1 menu"
    #positionWindow $w

    set menuContent {
	"Шаг №1" "Сбор данных в исходном контуре управления" Lab1Step1
	"Шаг №2" "Формирование обучающей и контрольной выборки" Lab1Step2
	"Шаг №3" "Выбор архитектуры нейронной сети регулятора" Lab1Step3
	"Шаг №4" "Обучение нейронной сети регулятора" Lab1Step4
	"Шаг №5" "Проверка нейросетевого регулятора в контуре управления" Lab1Step5
    }
    
    label $w.headline -text "$t" -foreground blue -background white
    set headlineFont [option get $w.headline headlineFont ""]
    if { $headlineFont != "" } {
	$w.headline config -font $headlineFont
    }
    pack $w.headline -fill x -side top -expand yes -pady 2

    set i 0
    foreach {label title cmd} $menuContent {
	incr i
	set text "$label\n$title"
	pack [button $w.step${i}_button -text "$text" \
		  -command "$cmd $w \"$t\n$text\""] \
	    -fill x -side top -expand yes -pady 2
    }
    button $w.close_button -text "Закрыть" -command "destroy $w"
    pack $w.close_button -side top -expand yes -pady 2
}

proc Lab1Step1 {p t} {
    set w "$p.step1"

    # Don't create the window twice
    if {[winfo exists $w]} return

    toplevel $w
    wm title $w "Lab#1 Step 1"
    wm iconname $w "Step 1.1"

    # Draw control system loop panel
    frame $w.controls
    pack $w.controls -side bottom -fill x -pady 2m
    button $w.controls.params -text "Параметры" -command "puts \"Params $w\""
    button $w.controls.run -text "Запустить" -command "puts \"Run $w\""
    button $w.controls.series -text "Графики" -command "puts \"Series $w\""
    button $w.controls.close -text "Закрыть" -command "destroy $w"
    pack $w.controls.params $w.controls.run $w.controls.series \
	 $w.controls.close -side left -expand 1

    frame $w.frame
    pack $w.frame -side top -fill both -expand yes
    set c $w.frame.c

    canvas $c -width 14c -height 7c -relief sunken -borderwidth 2 \
	-background white
    pack $c -side top -fill both -expand yes

    set textFont [option get $c fontLargeBlock ""]
    $c create text 0.5c 0.5c -text "$t" -justify left -anchor nw \
	-fill DarkGreen -font "$textFont"

    # Draw control system loop schema
    DrawPanel $c

    foreach cp {checkpoint_r checkpoint_u checkpoint_n checkpoint_e \
		    checkpoint_y} {
	global $cp
	eval set \$cp "[WorkDataDir][file separator]$cp.dat"
	$c.$cp config -command "CheckPntWindow $w $cp $cp"
    }

    # Connect callbacks with visual parameters settings
    # (reference+noise, modelling length) including selection of tf
    # Prepare template parameters file
    # Provide its name for editing by $w.controls.params
    # At $w.controls.run replaces several parameters by preset values
    # During the run display progress bar
    # After the run gather files and be ready to draw series
    # Drawing series may be tuned on and off in custom manner
}

proc Lab1Step2 {p t} {
    puts "Step 1.2 - N/A"
}
proc Lab1Step3 {p t} {
    puts "Step 1.3 - N/A"
}
proc Lab1Step4 {p t} {
    puts "Step 1.4 - N/A"
}
proc Lab1Step5 {p t} {
    puts "Step 1.5 - N/A"
}
