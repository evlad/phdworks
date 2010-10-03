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

option readfile noc_labs.ad

#    main   {Freesans 11}
array set widgetFont {
    main   "-*-helvetica-*-r-*-*-14-*-*-*-*-*-koi8-*"
    bold   {Helvetica 12 bold}
    title  {Helvetica 18 bold}
    status {Helvetica 10}
    vars   {Helvetica 14}
}

#set font $widgetFont(main)

button $w.lab1 -text "Лабораторная работа №1\n\
Нейросетевая имитация линейного регулятора"
button $w.lab2 -text "Лабораторная работа №2\n\
Построение нейросетевой модели объекта управления"
button $w.lab3 -text "Лабораторная работа №3\n\
Синтез нейросетевого оптимального регулятора"
button $w.lab4 -text "Лабораторная работа №4\n\
Нейросетевое управление нестационарным объектом"
button $w.quit -text "Выход" -command { exit }

pack $w.lab1 $w.lab2 $w.lab3 $w.lab4 -fill x -side top -expand yes -pady 2
pack $w.quit -side top -expand yes -pady 2
