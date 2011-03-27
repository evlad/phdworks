# -*-coding: koi8-r;-*-
# To produce data:
# $ ./test_nnc_origsys.sh e5r1_95 learn
# $ ./test_nnc_origsys.sh ../model_proof/pid.cof learn
# Good import of EPS into pdfLaTeX with cyrillic labels
set encoding koi8r
set grid
set xlabel "Время, мин"
set ylabel "Температура, K"
#set title "Сравнение ПИД регулятора и его нейросетевого имитатора в контуре"
set terminal postscript eps enhanced nofontfiles monochrome
set output "cstr_pid_vs_nnc_inloop_rus.eps"
plot [0:2000] [352:366] 'r_learn.dat' t "Уставка" w l, \
     'pid_ny_learn.dat' t "ПИД" w l, \
     'nnc_ny_learn_e5r1_95.dat' t "НС-Р" w l
#pause -1
