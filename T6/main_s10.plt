set grid
set logscale xy
set terminal postscript enhanced "Helvetica" 8

#cd 'nno_1+3_1'

# NNO: 1+3;1
cd '../nno_1+3_1'
#set title "NNO: 1+3;1 / n=50 / 10 samples"
set output '../mse_1+3_1_n50_Uw.ps'
load '../s10mse50.plt'
#set title "NNO: 1+3;1 / n=100 / 10 samples"
set output '../mse_1+3_1_n100_Uw.ps'
load '../s10mse100.plt'
#set title "NNO: 1+3;1 / n=250 / 10 samples"
set output '../mse_1+3_1_n250_Uw.ps'
load '../s10mse250.plt'
#set title "NNO: 1+3;1 / n=500 / 10 samples"
set output '../mse_1+3_1_n500_Uw.ps'
load '../s10mse500.plt'

# NNO: 1+3;4;1
cd '../nno_1+3_41'
#set title "NNO: 1+3;4;1 / n=50 / 10 samples"
set output '../mse_1+3_41_n50_Uw.ps'
load '../s10mse50.plt'
#set title "NNO: 1+3;4;1 / n=100 / 10 samples"
set output '../mse_1+3_41_n100_Uw.ps'
load '../s10mse100.plt'
#set title "NNO: 1+3;4;1 / n=250 / 10 samples"
set output '../mse_1+3_41_n250_Uw.ps'
load '../s10mse250.plt'
#set title "NNO: 1+3;4;1 / n=500 / 10 samples"
set output '../mse_1+3_41_n500_Uw.ps'
load '../s10mse500.plt'

# NNO: 1+3;7;3;1
cd '../nno_1+3_731'
#set title "NNO: 1+3;7;3;1 / n=50 / 10 samples"
set output '../mse_1+3_731_n50_Uw.ps'
load '../s10mse50.plt'
#set title "NNO: 1+3;7;3;1 / n=100 / 10 samples"
set output '../mse_1+3_731_n100_Uw.ps'
load '../s10mse100.plt'
#set title "NNO: 1+3;7;3;1 / n=250 / 10 samples"
set output '../mse_1+3_731_n250_Uw.ps'
load '../s10mse250.plt'
#set title "NNO: 1+3;7;3;1 / n=500 / 10 samples"
set output '../mse_1+3_731_n500_Uw.ps'
load '../s10mse500.plt'
