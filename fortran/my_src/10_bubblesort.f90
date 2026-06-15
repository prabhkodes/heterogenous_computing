! Implement a bubblesort algorithm into the sorting module and create a new main program
! based on the executable from section 09 that now calls bubblesort instead. Again, record
! benchmark data provided by the executable.


! -- INSTRUCTIONS --
! Integrates sorting and list_tools to benchmark the bubble_sort algorithm.
! It validates each sort using is_sorted() and prints the time for various sizes.
!
! Compile Types:   gfortran -c list_types.f90
! Compile Tools:   gfortran -c list_tools.f90
! Compile Sort:    gfortran -c sorting.f90
! Compile Main:    gfortran -o 10_bubblesort.x 10_bubblesort.f90 list_types.o list_tools.o sorting.o
! Run Using:       ./10_bubblesort.x

program test_bubblesort
    use sorting
    implicit none
    
    ! Array sizes to test
    integer, parameter :: num_sizes = 5
    integer :: sizes(num_sizes) = [1000, 5000, 10000, 15000, 20000]
    
    real, allocatable :: array(:)
    real :: t_start, t_end, elapsed_time
    integer :: i, n

    print *, "Bubble Sort Performance Testing"
    print *, "=============================="
    print *, "Size      | Time (Seconds)"
    print *, "----------|---------------"

    do i = 1, num_sizes
        n = sizes(i)
        allocate(array(n))
        
        ! Initialize with random data
        call random_number(array)

        ! Measure performance
        call cpu_time(t_start)
        call bubble_sort(array)
        call cpu_time(t_end)
        
        elapsed_time = t_end - t_start
        
        ! Note: validation (is_sorted) occurs inside the bubble_sort subroutine in sorting.f90
        print '(I10, " | ", F10.6)', n, elapsed_time

        deallocate(array)
    end do

end program test_bubblesort