
! Implement a binary search tree (BST) and test and benchmark it in a similar fashion to the
! linked list and hash table sections (16 and 17). Since tree traversal is most easily done with
! recursions, use recursive subroutines and functions for that. Implement functionality to add
! items to the tree, locate items by value (the “key” entry of the pair data type), and to free all
! allocated storage. Compare lookup performance to array, linked list and hash table.


! -- INSTRUCTIONS --
! Compile
! gfortran -c list_types.f90
! gfortran -c BSTModule.f90
! gfortran -c 21_bst.f90

! Link 
! gfortran -o 21_bst.x 21_bst.f90 BSTModule.o list_types.o

! Run
! ./21_bst.x < ../data/d3_1.dat

! Check for leaks
! leaks --atExit -- ./21_bst.x < ../data/d3_1.dat



PROGRAM bst_benchmark
    USE list_types
    USE BinarySearchTree
    IMPLICIT NONE

    INTEGER :: N, i, k, idx
    REAL :: chk_file, chk_calc, t1, t2
    TYPE(pair), ALLOCATABLE :: pairs(:)
    INTEGER, ALLOCATABLE :: keys(:)
    TYPE(Node), POINTER :: root => NULL()
    TYPE(pair) :: res
    
    INTEGER, PARAMETER :: nlook = 5000, repeat = 1000

    READ(*,*) N
    ALLOCATE(pairs(N), keys(nlook))
    READ(*,*) (pairs(i), i=1,N)
    READ(*,*) chk_file

    DO i = 1, N
        CALL insert_node(root, pairs(i))
    END DO

    
    DO i = 1, nlook
        idx = MOD(i * 12345, N) + 1  
        keys(i) = pairs(idx)%key
    END DO

    chk_calc = 0
    CALL CPU_TIME(t1)
    DO k = 1, repeat
        DO i = 1, nlook
            res = search_node(root, keys(i))
            chk_calc = chk_calc + res%key
        END DO
    END DO
    CALL CPU_TIME(t2)

    WRITE(*, '(A, F12.6, A)') "BST Lookup Time: ", (t2-t1)*1000.0, " ms"
    WRITE(*, *) "Checksum:", chk_calc

    
    CALL free_tree(root)
    DEALLOCATE(pairs, keys)

END PROGRAM bst_benchmark