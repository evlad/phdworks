package require Tk

set w ""
wm title . "Main menu of laboratory works"
wm iconname . "Labs main menu"

package require files_loc
package require universal
package require win_dcsloop

set ScriptsDir [file join [SystemDir] scripts]
option readfile [file join $ScriptsDir nnacs.ad]

set menuContent {
    "dcsloop" "Моделирование системы автоматического управления"
}

proc MenuLab1 {w label} {
    # Create or use session directory and remember it
    set title [lindex [split "$label" \n] 1]
    set sessionDir [NewSession $w dcsloop.par "$title"]
    if {$sessionDir != {}} {
	dcsloopCreateWindow $w "$title" $sessionDir
    }
}

pack [button $w.user_button \
	  -text "Перед началом\nВыбор/создание нового пользователя" \
	  -command "NewUser \"$w\""] -fill x -side top -expand yes -pady 2

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
