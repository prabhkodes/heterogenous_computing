! Use the provided quicksort implementation to build a corresponding test and benchmark
! executable for quicksort. As noted in the lecture, the choice of the pivot element is arbitrary as
! far as the algorithm itself is concerned, but it can have a significant impact on the performance
! of quicksort. In the sorting.f90 file is a commented out alternative strategy for choosing the pivot
! element. Use this as well and collect benchmark data for both variants of quicksort. Since this
! implementation of quicksort uses recursions, it may use large amounts of stack space, thus you
! may need to increase the available stack size using ‘ulimit -s unlimited’ to avoid crashes.

! -- INSTRUCTIONS --
! Benchmarks two variants of Quicksort: Standard (Last Element Pivot) and Alternative.
! NOTE: Run 'ulimit -s unlimited' in your terminal before execution to avoid stack overflow.
!
! Compile Types:   gfortran -c list_types.f90
! Compile Tools:   gfortran -c list_tools.f90
! Compile Sort:    gfortran -c sorting.f90
! Compile Main:    gfortran -o 12_quicksort.x 12_quicksort.f90 list_types.o list_tools.o sorting.o
! Run Using:       ulimit -s unlimited && ./12_quicksort.x

program test_quicksort
    use sorting
    implicit none
    
    integer, parameter :: num_sizes = 5
    integer :: sizes(num_sizes) = [10000, 100000, 250000, 500000, 1000000]
    
    real, allocatable :: array(:), copy(:)
    real :: t_start, t_end
    integer :: i, n

    print *, "Quicksort Performance Testing (Standard vs Alt Pivot)"
    print *, "====================================================="
    print *, "Size       | Standard (s) | Alternative (s)"
    print *, "-----------|--------------|----------------"

    do i = 1, num_sizes
        n = sizes(i)
        allocate(array(n), copy(n))
        call random_number(array)
        copy = array ! Keep exact same data for fair comparison

        ! Measure Standard Quicksort
        call cpu_time(t_start)
        call quicksort(array)
        call cpu_time(t_end)
        write(*, '(I10, " | ", F12.6)', advance='no') n, t_end - t_start

        ! Measure Alternative Quicksort
        call cpu_time(t_start)
        call quicksort_alt(copy)
        call cpu_time(t_end)
        write(*, '(" | ", F12.6)') t_end - t_start

        deallocate(array, copy)
    end do

end program test_quicksort