! Well scaling sorting algorithms often have significant overhead and thus are less efficient for
! small arrays. Thus, the fastest generic implementations of sort algorithms are often hybrids that
! combine multiple algorithms for different problem set sizes. Implement such a hybrid sort from
! insertion sort and merge sort: rather than starting the merge with lists of length 1, do a loop over
! the data in chunks of 32 elements and sort each of them with insertion sort; then continue with
! merge sort on these pre-sorted sublists. One more time, collect timings for different data set
! sizes and degree of previous sorting.

! -- INSTRUCTIONS --
! Benchmarks Hybrid Sort (Insertion + Merge).
! Tests performance on Random vs. Partially Sorted data.
!
! Compile Types:   gfortran -c list_types.f90
! Compile Tools:   gfortran -c list_tools.f90
! Compile Sort:    gfortran -c sorting.f90
! Compile Main:    gfortran -o 14_hybridsort.x 14_hybridsort.f90 list_types.o list_tools.o sorting.o
! Run Using:       ./14_hybridsort.x

program test_hybridsort
    use sorting
    implicit none
    
    integer, parameter :: num_sizes = 4
    integer :: sizes(num_sizes) = [100000, 250000, 500000, 1000000]
    real, allocatable :: array(:)
    real :: t_start, t_end
    integer :: i, n, j

    print *, "Hybrid Sort Performance Testing"
    print *, "==============================="
    print *, "Size       | Random (s) | Partially Sorted (s)"
    print *, "-----------|------------|---------------------"

    do i = 1, num_sizes
        n = sizes(i)
        allocate(array(n))
        
        ! Test 1: Random Data
        call random_number(array)
        call cpu_time(t_start)
        call hybrid_sort(array)
        call cpu_time(t_end)
        write(*, '(I10, " | ", F10.6)', advance='no') n, t_end - t_start

        ! Test 2: Partially Sorted Data (Sort first 50% then shuffle slightly)
        call random_number(array)
        call hybrid_sort(array(1:n/2)) 
        call cpu_time(t_start)
        call hybrid_sort(array)
        call cpu_time(t_end)
        write(*, '(" | ", F20.6)') t_end - t_start

        deallocate(array)
    end do

end program test_hybridsort