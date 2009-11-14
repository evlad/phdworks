cut -d ' ' -f 4 <cerr_trace5.dat >/tmp/cerr_trace_0.5_eta.tsv
cut -d ' ' -f 4 <cerr_trace9.dat >/tmp/cerr_trace_0.4_eta.tsv
cut -d ' ' -f 4 <cerr_trace6.dat >/tmp/cerr_trace_0.3_eta.tsv
cut -d ' ' -f 4 <cerr_trace10.dat >/tmp/cerr_trace_0.2_eta.tsv
cut -d ' ' -f 4 <cerr_trace7.dat >/tmp/cerr_trace_0.1_eta.tsv
cut -d ' ' -f 4 <cerr_trace1.dat >/tmp/cerr_trace_0.05_eta.tsv
cut -d ' ' -f 4 <cerr_trace2.dat >/tmp/cerr_trace_0.01_eta.tsv

paste /tmp/cerr_trace_0.5_eta.tsv /tmp/cerr_trace_0.4_eta.tsv \
    /tmp/cerr_trace_0.3_eta.tsv /tmp/cerr_trace_0.2_eta.tsv \
    /tmp/cerr_trace_0.1_eta.tsv /tmp/cerr_trace_0.05_eta.tsv \
    /tmp/cerr_trace_0.01_eta.tsv \
    >cerr_traces_eta.tsv
