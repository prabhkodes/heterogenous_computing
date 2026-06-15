! Now add the following features to your BST implementation: a function to count the number of
! nodes (i.e. stored items), a subroutine to extract the content of the tree, ordered by value, into
! an array of suitable size provided by the calling code, a subroutine to print out the “depth” of the
! tree and number of nodes with only one leaf.

! # Compile
! gfortran -c list_types.f90
! gfortran -c BSTModule.f90
! gfortran -c 22_bst_features.f90

! # Link
! gfortran -o 22_bst_features.x 22_bst_features.f90 BSTModule.o list_types.o

! # Run and Leak Check
! leaks --atExit -- ./22_bst_features.x < ../data/d3_1.dat

PROGRAM bst_features
    USE list_types
    USE BinarySearchTree
    IMPLICIT NONE

    INTEGER :: N, i, idx, total_nodes
    TYPE(pair), ALLOCATABLE :: pairs(:), sorted_pairs(:)
    TYPE(Node), POINTER :: root => NULL()
    REAL :: chk_file

    READ(*,*) N
    ALLOCATE(pairs(N))
    READ(*,*) (pairs(i), i=1,N)
    READ(*,*) chk_file

    DO i = 1, N
        CALL insert_node(root, pairs(i))
    END DO

    ! Feature 1: Count nodes
    total_nodes = count_nodes(root)
    WRITE(*,*) "Total nodes in tree: ", total_nodes

    ! Feature 2: Tree Depth and Single-Child nodes
    WRITE(*,*) "Tree Depth:         ", get_depth(root)
    WRITE(*,*) "Nodes with 1 child: ", count_single_child(root)

    ! Feature 3: Extract ordered data to array
    ALLOCATE(sorted_pairs(total_nodes))
    idx = 0
    CALL extract_to_array(root, sorted_pairs, idx)

    WRITE(*,*) "First 3 sorted keys: ", (sorted_pairs(i)%key, i=1, MIN(3, total_nodes))

    CALL free_tree(root)
    DEALLOCATE(pairs, sorted_pairs)
END PROGRAM bst_features