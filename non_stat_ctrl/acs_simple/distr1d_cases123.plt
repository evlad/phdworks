set grid
set terminal png
set output "distr1d_cases123.png"
plot 'case1f1_graph.dat' w l, 'case1f2_graph.dat' w l, 'case2f2_graph.dat' w l, 'case3f2_graph.dat' w l
