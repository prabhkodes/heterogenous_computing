! Write a program, similar to the one from section 01, where you add a function “is_sorted()” in
! the same source file to test if the array elements are sorted in ascending order. This function
! shall take the integer array as argument and return a logical as result. After reading the data,
! call the function and output a line of text indicating whether the array is sorted or not.

! -- INSTRUCTIONS --
! This program reads integer data and uses a logical function to check if the array is sorted.
! Compile Using: gfortran -o 03_sortedcheck.x 03_sortedcheck.f90
! Run Using: ./03_sortedcheck.x < ../data/d1_1.dat

program load_and_check_arrays
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

    if (is_sorted(arr, N)) then
        print *, "The array is sorted in ascending order."
    else
        print *, "The array is NOT sorted."
    end if
    
contains

    function is_sorted(arr, N) result(sorted)
        integer, intent(in) :: N
        integer, intent(in) :: arr(N)
        logical :: sorted
        integer :: i

        sorted = .true.
        do i = 2, N
            if (arr(i-1) > arr(i)) then
                sorted = .false.
                return
            end if
        end do
    end function is_sorted
    
end program load_and_check_arrays