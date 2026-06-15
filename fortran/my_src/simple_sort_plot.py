import pandas as pd
import matplotlib.pyplot as plt

# Data: Size, Type, Time (seconds)
data = [
    (500, 'unsorted', 0.000759),
    (500, 'sorted', 0.000389),
    (500, 'mostly_sorted', 0.000423),
    (1000, 'unsorted', 0.002537),
    (1000, 'sorted', 0.001544),
    (1000, 'mostly_sorted', 0.001529),
    (2000, 'unsorted', 0.008428),
    (2000, 'sorted', 0.003582),
    (2000, 'mostly_sorted', 0.003450),
    (5000, 'unsorted', 0.029124),
    (5000, 'sorted', 0.011283),
    (5000, 'mostly_sorted', 0.010652),
    (10000, 'unsorted', 0.071144),
    (10000, 'sorted', 0.037384),
    (10000, 'mostly_sorted', 0.037654),
    (20000, 'unsorted', 0.280616),
    (20000, 'sorted', 0.148905),
    (20000, 'mostly_sorted', 0.150396),
    (50000, 'unsorted', 1.835115),
    (50000, 'sorted', 0.931380),
    (50000, 'mostly_sorted', 0.934364),
    (100000, 'unsorted', 8.323883),
    (100000, 'sorted', 3.722509),
    (100000, 'mostly_sorted', 3.735289),
    (200000, 'unsorted', 51.612022),
    (200000, 'sorted', 14.951027),
    (200000, 'mostly_sorted', 15.043343)
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
plt.title("Sorting Times for Different Array Types (Method: simplesort)")
plt.xscale("log")
plt.yscale("log")
plt.legend()
plt.grid(True, which="both", ls="--", alpha=0.5)
plt.tight_layout()
plt.show()
