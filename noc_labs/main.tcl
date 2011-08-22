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

set ScriptsDir [file join [SystemDir] scripts]
option readfile [file join $ScriptsDir nnacs.ad]

set menuContent {
    "dcsloop" "Моделирование системы автоматического управления"
    "dcontrp" "Обучение нейросетевого регулятора вне контура"
    "dplantid" "Обучение нейросетевой модели объекта управления"
    "dcontrf" "Обучение нейросетевого регулятора в контуре"
}

proc MenuLab1 {w label} {
    # Create or use session directory and remember it
    set title [lindex [split "$label" \n] 1]
    set sessionDir [NewSession $w "dcsloop.par" "$title"]
    if {$sessionDir != {}} {
	dcsloopCreateWindow $w "$title" $sessionDir
    }
}

proc MenuLab2 {w label} {
    # Create or use session directory and remember it
    set title [lindex [split "$label" \n] 1]
    #set sessionDir [NewSession $w "dcontrp.par" "$title"]
    #if {$sessionDir != {}} {
	dcontrpCreateWindow $w "$title" 010
#$sessionDir
    #}
}

proc MenuLab3 {w label} {
    # Create or use session directory and remember it
    set title [lindex [split "$label" \n] 1]
    #set sessionDir [NewSession $w "dplantid.par" "$title"]
    #if {$sessionDir != {}} {
	dplantidCreateWindow $w "$title" 011
#$sessionDir
    #}
}

proc MenuLab4 {w label} {
    # Create or use session directory and remember it
    set title [lindex [split "$label" \n] 1]
    #set sessionDir [NewSession $w "dcontrf.par" "$title"]
    #if {$sessionDir != {}} {
	dcontrfCreateWindow $w "$title" 012
#$sessionDir
    #}
}

pack [button $w.user_button \
	  -text "Перед началом\nВыбор/создание нового пользователя" \
	  -command "NewUser \"$w\""] -fill x -side top -expand yes -pady 2

set curUserDir "/home/user/labworks/EliseevVL"

set i 0
foreach {label title} $menuContent {
    incr i
    set text "$label\n$title"
    pack [button $w.lab${i}_button -text "$text" \
	      -command "CheckGoodEnv \"$w\" ; MenuLab$i \"$w\" \"$text\""] -fill x -side top -expand yes -pady 2
}

button $w.quit_button -text "Выход" -command { removeTemporalFiles ; exit }
pack $w.quit_button -side top -expand yes -pady 2

# End of file
