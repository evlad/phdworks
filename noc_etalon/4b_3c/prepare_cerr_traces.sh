cut -d ' ' -f 4 <cerr_trace9.dat >/tmp/cerr_trace_1_auf.tsv
cut -d ' ' -f 4 <cerr_trace10.dat >/tmp/cerr_trace_2_auf.tsv
cut -d ' ' -f 4 <cerr_trace11.dat >/tmp/cerr_trace_5_auf.tsv
cut -d ' ' -f 4 <cerr_trace1.dat >/tmp/cerr_trace_10_auf.tsv
cut -d ' ' -f 4 <cerr_trace2.dat >/tmp/cerr_trace_30_auf.tsv
cut -d ' ' -f 4 <cerr_trace4.dat >/tmp/cerr_trace_70_auf.tsv
cut -d ' ' -f 4 <cerr_trace8.dat >/tmp/cerr_trace_150_auf.tsv

paste /tmp/cerr_trace_1_auf.tsv /tmp/cerr_trace_2_auf.tsv \
    /tmp/cerr_trace_5_auf.tsv /tmp/cerr_trace_10_auf.tsv \
    /tmp/cerr_trace_30_auf.tsv /tmp/cerr_trace_70_auf.tsv \
    /tmp/cerr_trace_150_auf.tsv \
    >cerr_traces_auf.tsv
