! Now implement a merge sort algorithm. Implement a “bottom up” version, so you can most
! easily avoid recursions and conveniently implement the next task in section 14. As before,
! collect benchmark data for later analysis and discussion.

! -- INSTRUCTIONS --
! Benchmarks the iterative Bottom-Up Merge Sort algorithm.
! It validates the sort using is_sorted() and prints the time for various sizes.
!
! Compile Types:   gfortran -c list_types.f90
! Compile Tools:   gfortran -c list_tools.f90
! Compile Sort:    gfortran -c sorting.f90
! Compile Main:    gfortran -o 13_mergesort.x 13_mergesort.f90 list_types.o list_tools.o sorting.o
! Run Using:       ./13_mergesort.x

program test_mergesort
    use sorting
    implicit none
    
    integer, parameter :: num_sizes = 5
    integer :: sizes(num_sizes) = [10000, 100000, 250000, 500000, 1000000]
    
    real, allocatable :: array(:)
    real :: t_start, t_end
    integer :: i, n

    print *, "Merge Sort Performance Testing (Bottom-Up)"
    print *, "========================================="
    print *, "Size       | Time (Seconds)"
    print *, "-----------|---------------"

    do i = 1, num_sizes
        n = sizes(i)
        allocate(array(n))
        call random_number(array)

        call cpu_time(t_start)
        call merge_sort(array)
        call cpu_time(t_end)
        
        print '(I10, " | ", F12.6)', n, t_end - t_start

        deallocate(array)
    end do

end program test_mergesort