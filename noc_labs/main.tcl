package require Tk

set w ""
wm title . "Main menu of laboratory works"
wm iconname . "Labs main menu"

package require files_loc
package require universal
package require win_dcsloop
package require win_dcontrp
package require win_dplantid
package require win_dcontrf
#package require win_series

set ScriptsDir [file join [SystemDir] scripts]
#set ScriptsDir {Z:\Home\nnacs-1.3b_win\noc_labs}
option readfile [file join $ScriptsDir nnacs.ad]

set menuContent {
    "dcsloop" "Моделирование системы автоматического управления"
    "dcontrp" "Обучение нейросетевого регулятора вне контура"
    "dplantid" "Обучение нейросетевой модели объекта управления"
    "dcontrf" "Обучение нейросетевого регулятора в контуре"
}

proc MenuProg1 {w label} {
    # Create or use session directory and remember it
    set prog [lindex [split "$label" \n] 0]
    set title [lindex [split "$label" \n] 1]
    set sessionDir [NewSession $w "dcsloop.par" "$title"]
    puts "Program: $prog,  session directory: [SessionDir $sessionDir]"
    if {$sessionDir != {}} {
	dcsloopCreateWindow $w "$title" "$sessionDir"
    }
}

proc MenuProg2 {w label} {
    # Create or use session directory and remember it
    set prog [lindex [split "$label" \n] 0]
    set title [lindex [split "$label" \n] 1]
    set sessionDir [NewSession $w "dcontrp.par" "$title"]
    puts "Program: $prog,  session directory: [SessionDir $sessionDir]"
    if {$sessionDir != {}} {
	dcontrpCreateWindow $w "$title" "$sessionDir"
    }
}

proc MenuProg3 {w label} {
    # Create or use session directory and remember it
    set prog [lindex [split "$label" \n] 0]
    set title [lindex [split "$label" \n] 1]
    set sessionDir [NewSession $w "dplantid.par" "$title"]
    puts "Program: $prog,  session directory: [SessionDir $sessionDir]"
    if {$sessionDir != {}} {
	dplantidCreateWindow $w "$title" "$sessionDir"
    }
}

proc MenuProg4 {w label} {
    # Create or use session directory and remember it
    set prog [lindex [split "$label" \n] 0]
    set title [lindex [split "$label" \n] 1]
    set sessionDir [NewSession $w "dcontrf.par" "$title"]
    puts "Program: $prog,  session directory: [SessionDir $sessionDir]"
    if {$sessionDir != {}} {
	dcontrfCreateWindow $w "$title" "$sessionDir"
    }
}

pack [button $w.user_button \
	  -text "Перед началом\nВыбор/создание нового пользователя" \
	  -command "NewUser \"$w\""] -fill x -side top -expand yes -pady 2

#set curUserDir "/home/user/labworks/EliseevVL"

set i 0
foreach {label title} $menuContent {
    incr i
    set text "$label\n$title"
    pack [button $w.lab${i}_button -text "$text" \
	      -command "CheckGoodEnv \"$w\" ; MenuProg$i \"$w\" \"$text\""] -fill x -side top -expand yes -pady 2
}

#incr i
#set text "Операции с рядами:\nвизуализация, анализ, изменение"
#pack [button $w.lab${i}_button -text "$text" \
#	  -command "seriesCreateWindow \"$w\" \"$text\""] \
#    -fill x -side top -expand yes -pady 2
#button $w.russian_button -text "\u0420\u0443\u0441\u0441\u043A\u0438\u0439 \u044F\u0437\u044B\u043A" \
#		  -font {Helvetica 12}
#pack $w.russian_button -fill x -side top -expand yes -pady 2
button $w.quit_button -text "Выход" -command { removeTemporalFiles ; exit }
pack $w.quit_button -side top -expand yes -pady 2

# End of file
