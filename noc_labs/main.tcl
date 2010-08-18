#!/bin/sh
# \
exec wish "$0" ${1+"$@"}

#package require Plotchart

set w ""
#catch {destroy .}
#toplevel $w
wm title . "Main menu of laboratory works"
wm iconname . "Lab menu"
#positionWindow $w

array set widgetFont {
    main   {Freesans 11}
    bold   {Helvetica 12 bold}
    title  {Helvetica 18 bold}
    status {Helvetica 10}
    vars   {Helvetica 14}
}

set font $widgetFont(main)

button $w.lab1 -text "Лабораторная работа №1\n\
Нейросетевая имитация линейного регулятора" -font $font
button $w.lab2 -text "Лабораторная работа №2\n\
Построение нейросетевой модели объекта управления" -font $font
button $w.lab3 -text "Лабораторная работа №3\n\
Синтез нейросетевого оптимального регулятора" -font $font
button $w.lab4 -text "Лабораторная работа №4\n\
Нейросетевое управление нестационарным объектом" -font $font
button $w.quit -text "Выход" -font $font \
    -command { exit }

pack $w.lab1 $w.lab2 $w.lab3 $w.lab4 -fill x -side top -expand yes -pady 2
pack $w.quit -side top -expand yes -pady 2
