import pandas as pd
import matplotlib.pyplot as plt

# Data: Size, Type, Time (seconds)

data = [
    (500, 'unsorted', 0.000783),
    (500, 'sorted', 0.000393),
    (500, 'mostly_sorted', 0.000414),
    (1000, 'unsorted', 0.002475),
    (1000, 'sorted', 0.001298),
    (1000, 'mostly_sorted', 0.001348),
    (2000, 'unsorted', 0.008656),
    (2000, 'sorted', 0.003470),
    (2000, 'mostly_sorted', 0.003122),
    (5000, 'unsorted', 0.028447),
    (5000, 'sorted', 0.011089),
    (5000, 'mostly_sorted', 0.010453),
    (10000, 'unsorted', 0.071064),
    (10000, 'sorted', 0.036788),
    (10000, 'mostly_sorted', 0.037880),
    (20000, 'unsorted', 0.280169),
    (20000, 'sorted', 0.148082),
    (20000, 'mostly_sorted', 0.150054),
    (50000, 'unsorted', 1.841686),
    (50000, 'sorted', 0.933964),
    (50000, 'mostly_sorted', 0.990780),
    (100000, 'unsorted', 8.690641),
    (100000, 'sorted', 3.778605),
    (100000, 'mostly_sorted', 3.738749),
    (200000, 'unsorted', 50.320808),
    (200000, 'sorted', 14.875664),
    (200000, 'mostly_sorted', 14.892174)
]


# Write data to CSV
csv_file = "sorting_times.csv"
df = pd.DataFrame(data, columns=['Size', 'Type', 'Time'])
df.to_csv(csv_file, index=False)
print(f"Data written to {csv_file}")

# Plot the data
plt.figure(figsize=(10,6))
for t in df['Type'].unique():
    subset = df[df['Type'] == t]
    plt.plot(subset['Size'], subset['Time'], marker='o', label=t)

plt.xlabel("Array Size")
plt.ylabel("Time (seconds)")
plt.title("Sorting Times for Different Array Types (Method: quicksort)")
plt.xscale("log")
plt.yscale("log")
plt.legend()
plt.grid(True, which="both", ls="--", alpha=0.5)
plt.tight_layout()
plt.show()
