import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

def plot_performance():
    raw_data = [
        {
            "Label": "N=4 | Procs=16 | Size=20'000",
            "Communication": "1.20622e+06ms", 
            "Compute": "1.2291e+06ms", 
            "INIT fields with Halo": "172057ms"
        },
        {
            "Label": "N=10 | Procs=40 | Size=20000",
            "Communication": "847447ms", 
            "Compute": "844236ms", 
            "INIT fields with Halo": "69529.6ms"
        },
        {
            "Label": "N=1 | Procs=4 | Size=20000",
            "Communication": "1.05381e+06ms", 
            "Compute": "5.07197e+06ms", 
            "INIT fields with Halo": "684792ms"
        }
    ]

    df = pd.DataFrame(raw_data)


    data_cols = [col for col in df.columns if col != 'Label']

    for col in data_cols:

        df[col] = df[col].astype(str).str.replace('ms', '').str.strip().astype(float)


    df['Total_Time'] = df[data_cols].sum(axis=1)
    

    df = df.sort_values(by='Total_Time', ascending=False)
    

    df = df.drop(columns=['Total_Time'])


    fig, ax = plt.subplots(figsize=(14, 8))


    colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd']
    

    df.plot(
        x='Label', 
        kind='bar', 
        stacked=True, 
        ax=ax, 
        width=0.6, 
        colormap='viridis', 
        edgecolor='black',
        linewidth=0.5
    )


    plt.title('Execution Time Breakdown by Function (Sorted by Total Time)', fontsize=16, pad=20)
    plt.xlabel('Configuration (Nodes | Procs | Size)', fontsize=12, labelpad=10)
    plt.ylabel('Time (ms)', fontsize=12)


    plt.xticks(rotation=45, ha='right', fontsize=10)
    

    ax.set_axisbelow(True)
    ax.grid(axis='y', linestyle='--', alpha=0.7)


    plt.legend(title='Function', bbox_to_anchor=(1.05, 1), loc='upper left')


    plt.tight_layout()


    plt.savefig('performance_plot.png')
    print("Plot saved as 'performance_plot.png'")

if __name__ == "__main__":
    plot_performance()