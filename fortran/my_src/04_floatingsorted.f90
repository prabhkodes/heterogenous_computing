! Now write a program similar to the one from section 03, which handles real numbers instead of
! integers and also the “is_sorted()” function is provided in a separate file as part of a “list_tools”
! module.

! -- INSTRUCTIONS --
! Handles real data and uses the 'list_tools' module with a generic interface.
! Compile Module: gfortran -c list_tools.f90
! Compile Main: gfortran -o 04_floatingsorted.x 04_floatingsorted.f90 list_tools.o
! Run Using: ./04_floatingsorted.x < ../data/d2_1.dat

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

    ! Now is_sorted is a function, so it works in this IF block
    if (is_sorted(arr)) then
        print *, "Array is sorted"
    else
        print *, "Array not sorted"
    end if
    
    deallocate(arr)
end program floating_nums_checksum