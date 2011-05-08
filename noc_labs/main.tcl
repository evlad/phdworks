#
#!/bin/sh
# \
#exec wish "$0" ${1+"$@"}

package require Tk

set w ""
#catch {destroy .}
#toplevel $w
wm title . "Main menu of laboratory works"
wm iconname . "Labs main menu"
#positionWindow $w

option readfile noc_labs.ad

pkg_mkIndex .
lappend auto_path .

package require files_loc
package require universal
package require win_dcsloop

#source lab1.tcl

set menuContent {
    "dcsloop" "Моделирование системы автоматического управления"
}

proc MenuLab1 {w title} {
    dcsloopCreateWindow $w $title
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
