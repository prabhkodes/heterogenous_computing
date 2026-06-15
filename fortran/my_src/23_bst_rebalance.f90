! Implement the following strategy to rebalance the tree: 1) extract the content of the tree into a
! sorted array; 2) allocate a new root node; 3) determine the middle of the array and assign the
! data at this location to the new root node; 4) rebuild the tree by calling a function that takes an
! array of data elements with the part of the array before the middle and the part of the array after
! the middle element; this function determines the middle of the passed in array and adds it to the
! tree and then recursively calls itself on the two remaining parts. 5) free the old tree and assign
! the root node pointer with the location of the new tree.
! Benchmark the tree lookup performance after the rebalancing and compare depth and number
! of open leafs before and after the rebalancing.


! # 1. Clean and Compile
! rm -f *.o *.mod 23_bst_rebalance.x
! gfortran -c list_types.f90
! gfortran -c BSTModule.f90
! gfortran -c 23_bst_rebalance.f90

! # 2. Link
! gfortran -o 23_bst_rebalance.x 23_bst_rebalance.f90 BSTModule.o list_types.o

! # 3. Run and Verify Leaks
! leaks --atExit -- ./23_bst_rebalance.x < ../data/d3_1.dat


PROGRAM bst_rebalance
    USE list_types
    USE BinarySearchTree
    IMPLICIT NONE

    INTEGER :: N, i, k, idx, total_nodes
    TYPE(pair), ALLOCATABLE :: pairs(:), sorted_pairs(:)
    INTEGER, ALLOCATABLE :: lookup_keys(:)
    TYPE(Node), POINTER :: old_root => NULL(), new_root => NULL()
    TYPE(pair) :: res  ! <--- ADDED THIS LINE TO FIX COMPILER ERROR
    REAL :: chk_file, t1, t2
    INTEGER, PARAMETER :: nlook = 5000, repeat = 500

    ! 1. Read Data
    READ(*,*) N
    ALLOCATE(pairs(N), lookup_keys(nlook))
    READ(*,*) (pairs(i), i=1,N)
    READ(*,*) chk_file

    ! 2. Build Original (potentially unbalanced) Tree
    DO i = 1, N
        CALL insert_node(old_root, pairs(i))
    END DO

    PRINT *, "--- Tree Stats BEFORE Rebalancing ---"
    PRINT *, "Depth: ", get_depth(old_root)

    ! 3. Rebalance Strategy
    total_nodes = count_nodes(old_root)
    ALLOCATE(sorted_pairs(total_nodes))
    idx = 0
    CALL extract_to_array(old_root, sorted_pairs, idx)
    
    ! Build perfectly balanced tree from the sorted array
    CALL build_balanced(new_root, sorted_pairs, 1, total_nodes)
    
    ! Free old tree and swap pointers
    CALL free_tree(old_root)
    old_root => new_root
    
    PRINT *, "--- Tree Stats AFTER Rebalancing ---"
    PRINT *, "Depth: ", get_depth(old_root)

    ! 4. Benchmark Lookups
    DO i = 1, nlook
        idx = MOD(i * 12345, N) + 1
        lookup_keys(i) = pairs(idx)%key
    END DO

    CALL CPU_TIME(t1)
    DO k = 1, repeat
        DO i = 1, nlook
            res = search_node(old_root, lookup_keys(i))
        END DO
    END DO
    CALL CPU_TIME(t2)

    WRITE(*, '(A, F12.6, A)') "Balanced BST Lookup Time: ", (t2-t1)*1000.0, " ms"

    ! 5. Final Cleanup
    CALL free_tree(old_root)
    DEALLOCATE(pairs, sorted_pairs, lookup_keys)

END PROGRAM bst_rebalance