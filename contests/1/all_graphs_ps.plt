set terminal postscript landscape monochrome

cd 'harm0.2'
set title "Harmonic reference signal (amplitude=0.2)\nControl MSE versus frequency"
set output 'mse_freq.ps'
load '../mse_vs_freq.plt'
cd '../harm0.5'
set title "Harmonic reference signal (amplitude=0.5)\nControl MSE versus frequency"
set output 'mse_freq.ps'
load '../mse_vs_freq.plt'
cd '../harm1.0'
set title "Harmonic reference signal (amplitude=1.0)\nControl MSE versus frequency"
set output 'mse_freq.ps'
load '../mse_vs_freq.plt'
cd '../harm2.0'
set title "Harmonic reference signal (amplitude=2.0)\nControl MSE versus frequency"
set output 'mse_freq.ps'
load '../mse_vs_freq.plt'
cd '../harm5.0'
set title "Harmonic reference signal (amplitude=5.0)\nControl MSE versus frequency"
set output 'mse_freq.ps'
load '../mse_vs_freq.plt'
