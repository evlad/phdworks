set grid
set logscale xy
set terminal postscript portrait monochrome "Helvetica" 8

#cd 'nno_1+3_1'

# NNO: 1+3;1
cd '../nno_1+3_1'
#set title "NNO: 1+3;1 / n=500 / 5 samples / U(z)=z/(z-0.5)"
set output '../mse_1+3_1_n500_Uc.ps'
load '../s5mse500.plt'

pause -1

# NNO: 1+3;4;1
cd '../nno_1+3_41'
#set title "NNO: 1+3;4;1 / n=500 / 5 samples / U(z)=z/(z-0.5)"
set output '../mse_1+3_41_n500_Uc.ps'
load '../s5mse500.plt'

pause -1

# NNO: 1+3;7;3;1
cd '../nno_1+3_731'
#set title "NNO: 1+3;7;3;1 / n=500 / 5 samples / U(z)=z/(z-0.5)"
set output '../mse_1+3_731_n500_Uc.ps'
load '../s5mse500.plt'
