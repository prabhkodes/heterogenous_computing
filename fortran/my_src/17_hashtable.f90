! Now implement a hash table using linked lists as buckets. Use at least 150 “buckets” and use
! the provided hashing function hashfunc() in hashfunc.f90 which is based on a C language
! hashing function for integers in inthash.c. This function needs to have a number of buckets that
! is a power of two, so use the next_size() function from the hashfunc module to compute that
! number. Add this to the testing and benchmarking framework as in section 16 and implement
! the same 4 types of operations. Discuss the performance of looking up elements by value in the
! three data structures.

! -- INSTRUCTIONS --
! Compile C:       gcc -c inthash.c
! Compile Fortran: gfortran -c hashfunc.f90 hash_map_helpers.f90
! Link:             gfortran -o 17_hashtable.x 17_hashtable.f90 inthash.o hashfunc.o hash_map_helpers.o
! Run              ./17_hashtable.x < ../data/d3_1.dat
! check for leaks using: leaks --atExit -- ./17_hashtable.x < ../data/d3_1.dat

program hash_table_implementation
    use hash_map_helpers
    use hashfunc
    implicit none
    
    integer :: N, i, bucket_idx_key, table_size
    real :: checksum_file
    
    type(HashNode), pointer :: buckets_array(:)
    type(HashNode), pointer :: head_ptr
    type(Dictionary), allocatable :: pair_arr(:)

    ! 1. Data Setup
    read(*,*) N
    allocate(pair_arr(N))
    read(*,*) (pair_arr(i)%key, pair_arr(i)%value, i=1,N)
    read(*,*) checksum_file

    ! 2. Sizing (Power of 2)
    table_size = next_size(150)
    allocate(buckets_array(table_size))
    
    ! Initialize buckets as empty
    do i = 1, table_size
        buckets_array(i)%key = -1 
        buckets_array(i)%next_add => NULL()
    end do

    ! 3. Hash and Store
    do i = 1, N
        bucket_idx_key = inthash(pair_arr(i)%key, table_size) + 1
        
        if (buckets_array(bucket_idx_key)%key == -1) then
            ! First item in bucket
            buckets_array(bucket_idx_key)%key = pair_arr(i)%key
            buckets_array(bucket_idx_key)%value = pair_arr(i)%value
        else
            ! Collision: push to the chain
            head_ptr => buckets_array(bucket_idx_key)
            call node_push_back(head_ptr, pair_arr(i)%key, pair_arr(i)%value)
        end if
    end do

    ! 4. Output and Cleanup
    call print_hashmap(buckets_array, table_size)
    
    call free_hashmap(buckets_array, table_size)
    deallocate(buckets_array, pair_arr)

    print *, "Hashmap successfully built and freed."
end program hash_table_implementation