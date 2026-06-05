# plot_cumulative_grouped_colors.gp
F = "combined.dat"

set datafile separator whitespace
set datafile commentschars "#"
set style data histograms
set style histogram rowstacked
set style fill solid 1.0 border -1
set boxwidth 0.9
set style increment user    # don't auto-cycle

# --- lock colors per function ---
C1 = "#1f77b4"   # DGEMM
C2 = "#ff7f0e"   # MPI AllGather
C3 = "#2ca02c"   # Extract B
C4 = "#9467bd"   # INIT A,B
C5 = "#7f7f7f"   # Write C

set grid ytics lc rgb "#cccccc"
set key outside top center horizontal samplen 2 spacing 1.0 font ",12"
set title "Matrix Multiplication for N*N where N=22,400" font ",18"

set tics nomirror out
set xlabel "Nodes"
set ylabel "Time (µs)"
set format y "%.0f"

# margins to avoid label clipping
set term pngcairo size 2000,1100 font ",14"
set bmargin 12
set rmargin 18
set offsets graph 0,0.06,0,0
set xtics rotate by -30 font ",12"

set output "strong_scaling.png"

# Columns:
# 1 Label | 2 RPN | 3 MPI | 4 OMP | 5..9 times in ms
XTICFMT = sprintf("rpn=%%d|mpi=%%d|omp=%%d")

plot \
  newhistogram "N=1", \
    F index 0 using ($5*1000):xtic(sprintf(XTICFMT,$2,$3,$4)) title "DGEMM"        lc rgb C1, \
    "" index 0 using ($6*1000)                                title "MPI AllGather" lc rgb C2, \
    "" index 0 using ($7*1000)                                title "Extract B"     lc rgb C3, \
    "" index 0 using ($8*1000)                                title "INIT A,B"      lc rgb C4, \
    "" index 0 using ($9*1000)                                title "Write C"       lc rgb C5, \
  newhistogram "N=2", \
    F index 1 using ($5*1000):xtic(sprintf(XTICFMT,$2,$3,$4)) notitle lc rgb C1, \
    "" index 1 using ($6*1000)                                notitle lc rgb C2, \
    "" index 1 using ($7*1000)                                notitle lc rgb C3, \
    "" index 1 using ($8*1000)                                notitle lc rgb C4, \
    "" index 1 using ($9*1000)                                notitle lc rgb C5, \
  newhistogram "N=4", \
    F index 2 using ($5*1000):xtic(sprintf(XTICFMT,$2,$3,$4)) notitle lc rgb C1, \
    "" index 2 using ($6*1000)                                notitle lc rgb C2, \
    "" index 2 using ($7*1000)                                notitle lc rgb C3, \
    "" index 2 using ($8*1000)                                notitle lc rgb C4, \
    "" index 2 using ($9*1000)                                notitle lc rgb C5, \
  newhistogram "N=8", \
    F index 3 using ($5*1000):xtic(sprintf(XTICFMT,$2,$3,$4)) notitle lc rgb C1, \
    "" index 3 using ($6*1000)                                notitle lc rgb C2, \
    "" index 3 using ($7*1000)                                notitle lc rgb C3, \
    "" index 3 using ($8*1000)                                notitle lc rgb C4, \
    "" index 3 using ($9*1000)                                notitle lc rgb C5, \
  newhistogram "N=10", \
    F index 4 using ($5*1000):xtic(sprintf(XTICFMT,$2,$3,$4)) notitle lc rgb C1, \
    "" index 4 using ($6*1000)                                notitle lc rgb C2, \
    "" index 4 using ($7*1000)                                notitle lc rgb C3, \
    "" index 4 using ($8*1000)                                notitle lc rgb C4, \
    "" index 4 using ($9*1000)                                notitle lc rgb C5, \
  newhistogram "N=16", \
    F index 5 using ($5*1000):xtic(sprintf(XTICFMT,$2,$3,$4)) notitle lc rgb C1, \
    "" index 5 using ($6*1000)                                notitle lc rgb C2, \
    "" index 5 using ($7*1000)                                notitle lc rgb C3, \
    "" index 5 using ($8*1000)                                notitle lc rgb C4, \
    "" index 5 using ($9*1000)                                notitle lc rgb C5

unset output
