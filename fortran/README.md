# Fortran — Data Structures & Algorithms

Implementations of common data structures and sorting algorithms in Fortran. Each program is self-contained and has compile/run instructions in the opening comment.

## Sorting

- Simple sort, bubble sort, insertion sort
- Quicksort (two pivot strategies)
- Bottom-up merge sort
- Hybrid sort — insertion sort on 32-element chunks, then merge

All variants are benchmarked against the same input sizes and validated with `is_sorted()`.

## Data Structures

- Dynamic array with key lookup
- Hash table — chained buckets, uses a C hash function via `ISO_C_BINDING`
- Stack backed by array
- Stack backed by linked list
- Binary search tree — insert, lookup, in-order traversal, depth stats, rebalancing

## Build

`gfortran`. Compile instructions are at the top of each `.f90` file. A `CMakeLists.txt` is included for the full build.
