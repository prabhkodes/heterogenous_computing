program floating_nums_checksum
    use sorting
    implicit none
    integer :: N, i
    real(4), allocatable ::  arr(:)
    real(4) :: proposed_sum, sum, error
    real(4), parameter :: tolerance = 1.0d-5
    real :: time0, time1
    sum = 0

    read(*, *) N
    print*, "Size", N

    allocate(arr(N))

    read(*, *) (arr(i), i=1, N)

    do i=1, N
        sum = sum + arr(i)
    end do

    print*, "Calculated Sum", sum

    read(*, *) proposed_sum
    print*, "Proposed Sum:", proposed_sum

    error=(proposed_sum- sum)
    print*, "Error:", error

    if (abs(proposed_sum-sum) / proposed_sum > tolerance) then
        stop 1
        print*, "----Error was more than tolerance, exiting program----"
    end if

    CALL CPU_TIME(time0)
    call simplesort(arr)
    CALL CPU_TIME(time1)
    print*, "Time Elapsed for simplesort -> (s):" , time1 - time0
    
    CALL CPU_TIME(time0)
    call quicksort(arr)
    CALL CPU_TIME(time1)
    print*, "Time Elapsed for quicksort -> (s):" , time1 - time0

    CALL CPU_TIME(time0)
    call bubble_sort(arr)
    CALL CPU_TIME(time1)
    print*, "Time Elapsed for bubble sort -> (s):" , time1 - time0

    CALL CPU_TIME(time0)
    call insertion_sort(arr)
    CALL CPU_TIME(time1)
    print*, "Time Elapsed for insertion sort -> (s):" , time1 - time0
    

end program floating_nums_checksum