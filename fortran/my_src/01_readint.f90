! Write a program that can read in a list of integer numbers into an array from a provided file,
! reading from standard input (channel 5 or *) via i/o redirection. The files have filenames of the
! pattern “d1_#.dat” and the following format: the first line has a single integer number signaling
! the length of the array; then the array elements follow which are spread over multiple lines, and
! finally a single number on the final line containing the sum of all elements, which should be used
! to check whether the reading was done correctly. The program should read the first line, then
! allocate sufficient storage and read in the array data and finally read and store the “checksum”.
! It shall output the length of the array and whether the checksum matches or not. If the
! checksum does not match, both, the expected and the computed values should be printed as
! well for easier debugging.

! -- INSTRUCTIONS --
! the program will prompt you to give an input file via cli like this :
! Compile Using: gfortran -o 01_readint.x 01_readint.f90
! Run Using: ./01_readint.x < ../data/d1_1.dat

program load_into_arrays
    implicit none
    
    integer :: N, i, computed_sum, expected_checksum
    integer, allocatable :: arr(:)
    
    read(*, *) N
    
    allocate(arr(N))
    
    read(*, *) (arr(i), i = 1, N)
    
    read(*, *) expected_checksum
    
    computed_sum = 0
    do i = 1, N
        computed_sum = computed_sum + arr(i)
    end do
    
    print *, "Array length:", N
    
    if (computed_sum == expected_checksum) then
        print *, "Checksum match: SUCCESS"
    else
        print *, "Checksum match: FAILED"
        print *, "Expected checksum:", expected_checksum
        print *, "Computed sum:     ", computed_sum
    end if
    
    deallocate(arr)
    
end program load_into_arrays

