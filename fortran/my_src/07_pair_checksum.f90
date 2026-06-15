! Write a program similar to the programs of sections 01 and 02 that can read in pairs of numbers
! as key-value pairs, where the key is integer and the value a real number. The corresponding
! data files have names “d3_#.dat” and the format is similar to previous cases: one line with the
! number of items (i.e. pairs), then the integer-real pairs, and then a single line with the
! checksum, that is is the sum of all real values. To implement this create a derived type “pair”
! with two entries: an integer “key” and a real “val” and store the data from the files in an array of
! this derived type.

! -- INSTRUCTIONS --
! This program reads a count N, then N pairs of (Integer, Real), and verifies a checksum.
! Compile Using: gfortran -o 07_pair_checksum.x 07_pair_checksum.f90
! Run Using: ./07_pair_checksum.x < ../data/d3_1.dat

program pair_checksum
    implicit none

    type :: pair
        integer :: key
        real(4) :: val
    end type pair

    integer :: N, i
    type(pair), allocatable :: arr(:)
    real(4) :: proposed_sum, computed_sum
    real(4), parameter :: tolerance = 1.0e-5
    
    computed_sum = 0.0

    read(*, *) N
    print*, "Number of pairs:", N

    allocate(arr(N))

    read(*, *) (arr(i)%key, arr(i)%val, i = 1, N)

    read(*, *) proposed_sum

    do i = 1, N
        computed_sum = computed_sum + arr(i)%val
    end do

    print*, "Calculated Sum:", computed_sum
    print*, "Proposed Sum:  ", proposed_sum

    if (abs(proposed_sum - computed_sum) / proposed_sum > tolerance) then
        print*, "Checksum Verification: FAILED"
        print*, "Relative Error:", abs(proposed_sum - computed_sum) / proposed_sum
        stop 1
    else
        print*, "Checksum Verification: SUCCESS"
    end if
    
    deallocate(arr)

end program pair_checksum