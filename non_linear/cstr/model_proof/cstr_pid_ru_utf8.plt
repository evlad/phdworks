# -*-coding: utf-8;-*-
set grid
set title "Динамика реактора при ПИД управлении"
set xlabel "Время, мин."
#set ylabel "Температура продуктов реакции, K"
set ylabel "Т, K"
#set y2label "Поток охладителя, м3/мин"
set y2label "u, м3/мин"
set y2tics
set term tkcanvas
set output 'cstr_pid_ru_utf8.tcl'
plot [0:500] [352:366] [0:500] [0:0.14] 'steps.dat' t "Уставка" w l, \
     'pid_ny.dat' t "Результат" w l, \
     'pid_u.dat' axes x1y2 t "Управление" linewidth 2 w l
# Drawing in Tcl/Tk
# wish
# % source cstr_pid_ru_utf8.tcl
# % canvas .c
# % pack .c
# % gnuplot .c
