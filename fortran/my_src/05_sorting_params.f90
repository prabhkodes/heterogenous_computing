! Expand the “list_tools” module so that it contains two constants (parameters), “ascending” and
! “descending”, both are of type logical and have the value .true. and .false., respectively. Now
! add to the “is_sorted()” function an optional argument so that the direction of the order can be
! indicated. Do this in such a fashion that the program from 04 remains functional without
! modification, yet uses the same module. The main program shall differ from the version in
! section 04 only by explicitly requesting the sort order to check for (ascending).


! -- INSTRUCTIONS --
! Handles real data and explicitly requests ascending sort order using module parameters.
! Compile Module: gfortran -c list_tools.f90
! Compile Main: gfortran -o 05_sorting_params.x 05_sorting_params.f90 list_tools.o
! Run Using: ./05_sorting_params.x < ../data/d2_1.dat

program floating_nums_checksum
    use list_tools
    implicit none
    
    integer :: N, i
    real(4), allocatable :: arr(:)
    real(4) :: proposed_sum, sum
    real(4), parameter :: tolerance = 1.0e-5
    
    sum = 0.0
    read(*, *) N
    allocate(arr(N))

    read(*, *) (arr(i), i = 1, N)

    do i = 1, N
        sum = sum + arr(i)
    end do

    read(*, *) proposed_sum
    
    if (abs(proposed_sum - sum) / proposed_sum > tolerance) then
        print*, "Checksum FAILED"
        stop 1
    end if

    if (is_sorted(arr, ascending)) then
        print *, "Array is sorted (explicitly checked for ascending)"
    else
        print *, "Array is NOT sorted"
    end if
    
    deallocate(arr)
end program floating_nums_checksum