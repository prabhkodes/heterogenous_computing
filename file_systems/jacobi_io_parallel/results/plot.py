import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import re
import io

def generate_performance_plot():
    # --- 1. Full Dataset from Conversation History ---
    data = """
Label                                             PRINT COMM INIT MEMORY_IO SOLVE_AND_SWAP
"N=1 | rpn=8  | omp=14 | print=500"                  500             5743200 24712   3753970         35425600
"N=1 | rpn=8  | omp=14 | print=2000"                 2000            5115560 24734   1143190         34541300
"N=1 | rpn=4  | omp=28 | print=500"                  500             4224980 47876   3929930         39566200
"N=1 | rpn=28 | omp=4  | print=500"                  500             8267750 8221    4554370         32796600
"N=1 | rpn=28 | omp=4  | print=2000"                 2000            6628190 8010    1314400         32766200
"N=1 | rpn=56 | omp=2  | print=500"                  500             6945380 4085    5188330         32190300
"N=1 | rpn=2  | omp=56 | print=500"                  500             1770240 94825   2265030         84954500
"N=2 | rpn=28 | omp=4  | print=500"                  500             5330280 3935    5592810         16283900
"N=2 | rpn=4  | omp=28 | print=500"                  500             3965330 24096   3924730         20317700
"N=2 | rpn=8  | omp=14 | print=500"                  500             5604450 12183   4041640         18487000
"N=2 | rpn=56 | omp=2  | print=500"                  500            41725700 2173    4552020         16248900
"N=2 | rpn=2  | omp=56 | print=500"                  500             2175970 47294   3668930         40010600
"N=8 | rpn=2  | omp=56 | print=500"                  500             1224500 12184   3059740          5126350
"N=8 | rpn=2  | omp=56 | print=2000"                 2000            1219690 11965   1991320          5162200
"N=8 | rpn=56 | omp=2  | print=500"                  500             1634830 617     6071380          3999250
"N=8 | rpn=56 | omp=2  | print=2000"                 2000            1627480 604     2151390          4004490
"N=8 | rpn=28 | omp=4  | print=500"                  500             1738320 1042    4222490          4054800
"N=8 | rpn=4  | omp=28 | print=500"                  500             1433600 6034    2972590          4693670
"N=8 | rpn=4  | omp=28 | print=1000"                 1000            1400260 6079    3746630          4721570
"N=8 | rpn=4  | omp=28 | print=2000"                 2000            1475220 6118    2051830          4741070
"N=8 | rpn=8  | omp=14 | print=500"                  500             1514660 3179    3155380          4359120
"N=8 | rpn=8  | omp=14 | print=1000"                 1000            1522490 3086    2555010          4369440
"N=8 | rpn=8  | omp=14 | print=2000"                 2000            1529130 3121    1410550          4383580
"N=10 | rpn=8  | omp=14 | print=500"                 500             1346030 2486    5374050         3502460
"N=10 | rpn=8  | omp=14 | print=1000"                1000            14097700 2526    3024230         3598440
"N=10 | rpn=8  | omp=14 | print=2000"                2000            1394770 2543    1471690         3510570
"N=10 | rpn=28 | omp=4  | print=500"                 500             1503180 839     6835130         3264290
"N=10 | rpn=28 | omp=4  | print=1000"                1000            1527310 835     3514370         3261020
"N=10 | rpn=28 | omp=4  | print=2000"                2000            1436960 832     1995070         3251500
"""

    # --- 2. Robust parsing (don’t touch data string) ---
    # Parse: "Label" + PRINT + COMM + INIT + MEMORY_IO + SOLVE_AND_SWAP
    pat = re.compile(
        r'^"(?P<Label>[^"]+)"\s+'
        r'(?P<PRINT>\d+)\s+'
        r'(?P<COMM>\d+)\s+'
        r'(?P<INIT>\d+)\s+'
        r'(?P<MEMORY_IO>\d+)\s+'
        r'(?P<SOLVE_AND_SWAP>\d+)\s*$'
    )
    rows = []
    for line in io.StringIO(data):
        s = line.strip()
        if not s or s.startswith('Label'):
            continue
        m = pat.match(s)
        if m:
            rows.append(m.groupdict())
    if not rows:
        raise RuntimeError("No valid data rows parsed. Check input format.")

    df = pd.DataFrame(rows)
    # Numeric types
    for c in ['PRINT', 'COMM', 'INIT', 'MEMORY_IO', 'SOLVE_AND_SWAP']:
        df[c] = pd.to_numeric(df[c], errors='coerce')

    # --- 3. Feature extraction from Label ---
    df['N']   = df['Label'].str.extract(r'N=(\d+)', expand=False).astype(int)
    df['rpn'] = df['Label'].str.extract(r'rpn=(\d+)', expand=False).astype(int)
    df['omp'] = df['Label'].str.extract(r'omp=(\d+)', expand=False).astype(int)

    df['X_Label'] = df.apply(
    lambda row: f"N={row['N']}|rpn={row['rpn']}|omp={row['omp']}|print={row['PRINT']}",
    axis=1
)

    # --- 4. Prepare for stacked plot & file output ---
    # Draw MEMORY_IO last so it sits on top
    latency_components = ['COMM', 'INIT', 'SOLVE_AND_SWAP', 'MEMORY_IO']

    for col in latency_components:
        df[f'{col}_ms'] = df[col] / 1000.0  # us → ms

    df_sorted = df.sort_values(by=['N', 'rpn', 'omp', 'PRINT']).reset_index(drop=True)

    # --- 5. Write CSV ---
    output_filename = 'processed_latency_data.csv'
    csv_cols = ['N', 'rpn', 'omp', 'PRINT', 'X_Label'] + [f'{c}_ms' for c in latency_components]
    df_sorted[csv_cols].to_csv(output_filename, index=False)
    print(f"✅ Processed data saved to: {output_filename}")

    # --- 6. Plotting (Stacked Bar Chart) ---
    x_labels = df_sorted['X_Label']
    x = np.arange(len(x_labels))
    bottom_values = np.zeros(len(x))

    plt.style.use('seaborn-v0_8-whitegrid')
    plt.figure(figsize=(22, 12))
    colors = plt.cm.get_cmap('tab10', len(latency_components))

    for i, component in enumerate(latency_components):
        cur = df_sorted[f'{component}_ms'].to_numpy()
        plt.bar(
            x, cur, bottom=bottom_values,
            label=component.replace('_', ' ').title(),
            color=colors(i),
            edgecolor='black',
            linewidth=0.5,
            hatch='///' if component == 'MEMORY_IO' else None  # make MEMORY_IO pop
        )
        bottom_values += cur

    plt.ylabel('Latency (ms)', fontsize=14)
    plt.xlabel('Configuration (Nodes=N | Ranks/Node=RPN | MPI_Ranks=MPI | OMP Threads=T | Print Interval=P)', fontsize=14)
    plt.title('Function-Wise Latency Split for Grid (N*N) where N = 5,000 ', fontsize=18, pad=20)
    plt.xticks(x, x_labels, rotation=90, fontsize=10)
    plt.yticks(fontsize=12)
    plt.legend(title='Latency Component', fontsize=12, title_fontsize=14, loc='upper right')
    plt.grid(axis='y', linestyle='--', alpha=0.5)
    plt.tight_layout()

    plot_filename = 'latency_split_stacked_bar_chart_full.png'
    plt.savefig(plot_filename)
    print(f"✅ Plot saved to: {plot_filename}")

if __name__ == '__main__':
    generate_performance_plot()
