! Integrate the provided files 09_simplesort.f90 and sorting.f90 into your build system from part 1.
! 09_simplesort.f90 provides a framework for testing subroutines that sort arrays of real numbers,
! and sorting.f90 provides a module containing two implementations of sorting algorithms, a very
! simple one and a quicksort implementation. Now take the swap subroutine and move it into your
! list_tools module instead. Furthermore add calls to is_sorted() from the same module after each
! sort is completed and print out a warning, if an array is not sorted. Since you validated the
! is_sorted() function with the data files in part 1, you can now validate sorting algorithms with it.
! Run the resulting executable and extract the timing information for the various problem set
! sizes.


! -- INSTRUCTIONS --
! Integrates sorting and list_tools to benchmark the simplesort algorithm.
! It validates each sort using is_sorted() and prints the time for various sizes.
!
! Compile Types:   gfortran -c list_types.f90
! Compile Tools:   gfortran -c list_tools.f90
! Compile Sort:    gfortran -c sorting.f90
! Compile Main:    gfortran -o 09_simplesort.x 09_simplesort.f90 list_types.o list_tools.o sorting.o
! Run Using:       ./09_simplesort.x

program test_simplesort
    use sorting
    implicit none
    
    ! Array sizes to test
    integer, parameter :: num_sizes = 5
    integer :: sizes(num_sizes) = [1000, 5000, 10000, 15000, 20000]
    
    real, allocatable :: array(:)
    real :: t_start, t_end, elapsed_time
    integer :: i, n

    print *, "Simplesort Performance Testing"
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
        call simplesort(array)
        call cpu_time(t_end)
        
        elapsed_time = t_end - t_start
        
        ! Note: validation (is_sorted) occurs inside the simplesort subroutine
        print '(I10, " | ", F10.6)', n, elapsed_time

        deallocate(array)
    end do

end program test_simplesort