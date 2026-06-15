! Now rename the “is_sorted()” function in “list_tools” to “is_sorted_real()” and implement a
! version for integers called “is_sorted_int()” and define an interface for “is_sorted()” so that either
! of the two functions is being called, depending on the datatype of the arguments. The programs
! from sections 04 and 05 have to remain functional without change. In addition write a variant of
! the main program from section 03 that now imports “is_sorted()” from the “list_tools” module and
! checks integer arrays for being sorted.

! -- INSTRUCTIONS --
! This program handles integer data and uses the generic 'is_sorted' interface from the module.
! Compile Module: gfortran -c list_tools.f90
! Compile Main: gfortran -o 06_int_sorted.x 06_int_sorted.f90 list_tools.o
! Run Using: ./06_int_sorted.x < ../data/d1_1.dat

program load_and_check_integers
    use list_tools
    implicit none
    
    integer :: N, i, sum, proposed_sum
    integer, allocatable :: arr(:)

    sum = 0
    read(*,*) N
    allocate(arr(N))

    read(*,*) (arr(i), i=1, N)

    do i=1, N
        sum = sum + arr(i)
    end do

    read(*,*) proposed_sum
    
    if (sum /= proposed_sum) then
        print *, "Checksum failed!"
        stop 1
    end if

    ! Using the generic interface 'is_sorted' from your module
    if (is_sorted(arr)) then
        print *, "Array is sorted (Ascending)"
    else
        print *, "Array is NOT sorted"
    end if
    
    deallocate(arr)
end program load_and_check_integers