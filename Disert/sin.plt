set isosamples 30
set hidden3d
sin1(x,y)=(x<2*pi && y<2*pi)?sin(x):0
splot [x=0:4*pi] [y=0:4*pi] sin1(x,y)
