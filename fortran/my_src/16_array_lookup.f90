! Integrate the provided file 16_array_lookup.f90 file into your build system from parts 1 and 2.
! 16_array_lookup.f90 provides a framework for testing and benchmarking data structures and
! looking up the previously stored data in random order. The file expects to read d3_#.dat files
! with data pairs. You need to implement operations 1) to initialize the data structure, 2) to add
! items to the list, 3) to look up items by value (i.e. the “key” element of the pair type); this should
! be a function returning the pair, and 4) to deallocate the data structure completely.

! -- INSTRUCTIONS --
! Benchmarks data lookups in Arrays vs. Linked Lists.
!
! Compile Types:   gfortran -c list_types.f90
! Compile Nodes:   gfortran -c nodes.f90
! Compile Tools:   gfortran -c list_tools.f90
! Compile Main:    gfortran -o 16_array_lookup.x 16_array_lookup.f90 list_types.o nodes.o list_tools.o
! Run Using:       ./16_array_lookup.x < ../data/d3_1.dat
! Check for mem leaks on macos using: leaks --atExit -- ./16_array_lookup.x < ../data/d3_1.dat


PROGRAM array_lookup_benchmark
    USE list_types
    USE nodes
    USE list_tools
    IMPLICIT NONE

    INTEGER :: N, i, k, search_key
    REAL :: checksum_file, checksum_calc, r, time1, time2
    INTEGER, ALLOCATABLE :: lookup_keys(:)
    TYPE(pair), ALLOCATABLE :: pair_arr(:)
    TYPE(pair) :: found_pair
    TYPE(node), POINTER :: head_node => NULL(), temp_node => NULL(), current_node => NULL()
    
    INTEGER, PARAMETER :: nlook = 5000
    INTEGER, PARAMETER :: repeat_count = 1000 ! Adjust to control benchmark duration

    ! 1. Initialize & Read Data
    IF (.NOT. isatty(0)) THEN
        READ(*,*) N
    ELSE
        PRINT *, "Error: Please provide a data file via redirection (<)"
        STOP
    END IF

    ALLOCATE(pair_arr(N))
    READ(*,*) (pair_arr(i), i=1,N)
    READ(*,*) checksum_file

    ! 2. Build Linked List
    ALLOCATE(head_node)
    head_node%val = pair_arr(1)%key
    NULLIFY(head_node%next)
    
    current_node => head_node
    DO i = 2, N
        ALLOCATE(temp_node)
        temp_node%val = pair_arr(i)%key
        NULLIFY(temp_node%next)
        current_node%next => temp_node
        current_node => temp_node
    END DO

    ! 3. Prepare Random Lookup Keys
    CALL RANDOM_SEED()
    ALLOCATE(lookup_keys(nlook))
    DO i=1,nlook
        CALL RANDOM_NUMBER(r)
        lookup_keys(i) = pair_arr(INT(r*N)+1)%key
    END DO

    PRINT *, "Benchmarking N=", N, " items..."

    ! --- Benchmark 1: Array Linear Lookup ---
    checksum_calc = 0
    CALL CPU_TIME(time1)
    DO k=1, repeat_count
        DO i=1,nlook
            found_pair = lookup_array(pair_arr, lookup_keys(i))
            checksum_calc = checksum_calc + found_pair%key
        END DO
    END DO
    CALL CPU_TIME(time2)
    WRITE(*,FMT=666) nlook * repeat_count, 'Array Lookups', (time2-time1)*1000.0
    WRITE(*,*) 'Checksum result:', checksum_calc

    ! --- Benchmark 2: Linked List Lookup ---
    checksum_calc = 0
    CALL CPU_TIME(time1)
    DO k=1, repeat_count
        DO i=1,nlook
            search_key = lookup_keys(i)
            temp_node => head_node
            DO WHILE (ASSOCIATED(temp_node))
                IF (temp_node%val == search_key) EXIT
                temp_node => temp_node%next
            END DO
            checksum_calc = checksum_calc + search_key
        END DO
    END DO
    CALL CPU_TIME(time2)
    WRITE(*,FMT=666) nlook * repeat_count, 'List Lookups', (time2-time1)*1000.0
    WRITE(*,*) 'Checksum result:', checksum_calc

    DEALLOCATE(pair_arr, lookup_keys)
    
    current_node => head_node
    DO WHILE (ASSOCIATED(current_node))
        temp_node => current_node%next
        DEALLOCATE(current_node)
        current_node => temp_node
    END DO

    666 FORMAT (' Performing',I10,1X,A20,1X,'took:',F12.6,' ms')   

END PROGRAM array_lookup_benchmark