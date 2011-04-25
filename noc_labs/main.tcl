#!/bin/sh
# \
exec wish "$0" ${1+"$@"}

set w ""
#catch {destroy .}
#toplevel $w
wm title . "Main menu of laboratory works"
wm iconname . "Labs main menu"
#positionWindow $w

option readfile noc_labs.ad

source files_loc.tcl
source lab1.tcl

set menuContent {
  "Лабораторная работа №1" "Нейросетевая имитация линейного регулятора"
  "Лабораторная работа №2" "Построение нейросетевой модели объекта управления"
  "Лабораторная работа №3" "Синтез нейросетевого оптимального регулятора"
  "Лабораторная работа №4" "Нейросетевое управление нестационарным объектом"
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

button $w.quit_button -text "Выход" -command { exit }
pack $w.quit_button -side top -expand yes -pady 2

# End of file
