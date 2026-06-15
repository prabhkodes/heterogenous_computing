! Write a program, similar to the one from section 01, which handles real data (i.e. 32-bit floating
! point numbers) instead of integer. The corresponding files have names following the pattern
! “d2_#.dat”. Real numbers may be provided in fixed or exponential format. Please note that
! floating point numbers may be truncated or rounded on output, so do not test for identify when
! comparing with the checksum. Rather use a relative accuracy like 10-5 or similar.


! -- INSTRUCTIONS --
! The program handles real data (32-bit floating point) and performs a checksum validation.
! Compile Using: gfortran -o 02_readfloats.x 02_readfloats.f90
! Run Using: ./02_readfloats.x < ../data/d2_1.dat

program floating_nums_checksum
    implicit none
    
    integer :: N, i
    real(4), allocatable :: arr(:)
    real(4) :: proposed_sum, sum, error
    real(4), parameter :: tolerance = 1.0e-5 
    
    sum = 0.0

    read(*, *) N
    print*, "Array Size:", N

    allocate(arr(N))

    read(*, *) (arr(i), i = 1, N)

    do i = 1, N
        sum = sum + arr(i)
    end do

    print*, "Calculated Sum:", sum

    read(*, *) proposed_sum
    print*, "Presumed Sum: ", proposed_sum

    error = abs(proposed_sum - sum)
    print*, "Absolute Error:", error

    if (abs(proposed_sum - sum) / proposed_sum > tolerance) then
        print*, "Checksum match: FAILED"
        stop 1
    else
        print*, "Checksum match: SUCCESS"
    end if
    
    deallocate(arr)

end program floating_nums_checksum