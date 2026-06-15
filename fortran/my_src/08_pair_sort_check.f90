! Now put the definition of the derived type “pair” info a new module “list_types”. Import this
! module into “list_tools” and write a variant of “is_sorted()” for the pair type. This function shall
! have a second optional argument, a logical indicating whether the check should be performed
! on the key or the value of the pair. For that two new constants, “bykey” and “byvalue” shall be
! added to the module as well. Finally write a main program, similar to that from section 06 that
! will read the pair data files and perform the sorted check. Test data files if they are ordered by
! ascending value and descending keys.

! -- INSTRUCTIONS --
! Reads pair data and checks if they are sorted by value (ascending) and keys (descending).
! Compile Types:  gfortran -c list_types.f90
! Compile Tools:  gfortran -c list_tools.f90
! Compile Main:   gfortran -o 08_pair_check.x 08_pair_sort_check.f90 list_types.o list_tools.o
! Run Using:      ./pair_check.x < ../data/d3_1.dat

program pair_sort_check
    use list_tools
    implicit none
    
    integer :: N, i
    type(pair), allocatable :: arr(:)
    real(4) :: proposed_sum, computed_sum
    real(4), parameter :: tolerance = 1.0e-5
    
    read(*, *) N
    allocate(arr(N))
    read(*, *) (arr(i)%key, arr(i)%val, i = 1, N)
    read(*, *) proposed_sum

    ! 1. Check if sorted by Ascending Value
    if (is_sorted(arr, ascending, byvalue)) then
        print *, "The pairs are sorted by Value (Ascending)."
    else
        print *, "The pairs are NOT sorted by Value (Ascending)."
    end if

    ! 2. Check if sorted by Descending Key
    if (is_sorted(arr, descending, bykey)) then
        print *, "The pairs are sorted by Key (Descending)."
    else
        print *, "The pairs are NOT sorted by Key (Descending)."
    end if
    
    deallocate(arr)
end program pair_sort_check