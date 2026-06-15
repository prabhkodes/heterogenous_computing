MODULE BinarySearchTree
    USE list_types
    IMPLICIT NONE
    
    TYPE :: Node
        TYPE(pair) :: node_pair
        TYPE(Node), POINTER :: lchild => NULL()
        TYPE(Node), POINTER :: rchild => NULL()
    END TYPE Node

CONTAINS

    RECURSIVE SUBROUTINE insert_node(root, p)
        TYPE(Node), POINTER, INTENT(INOUT) :: root
        TYPE(pair), INTENT(IN) :: p
        IF (.NOT. ASSOCIATED(root)) THEN
            ALLOCATE(root)
            root%node_pair = p
            root%lchild => NULL(); root%rchild => NULL()
        ELSE IF (p%key < root%node_pair%key) THEN
            CALL insert_node(root%lchild, p)
        ELSE
            CALL insert_node(root%rchild, p)
        END IF
    END SUBROUTINE insert_node

    RECURSIVE FUNCTION count_nodes(root) RESULT(n)
        TYPE(Node), POINTER, INTENT(IN) :: root
        INTEGER :: n
        IF (.NOT. ASSOCIATED(root)) THEN
            n = 0
        ELSE
            n = 1 + count_nodes(root%lchild) + count_nodes(root%rchild)
        END IF
    END FUNCTION count_nodes

    RECURSIVE FUNCTION get_depth(root) RESULT(d)
        TYPE(Node), POINTER, INTENT(IN) :: root
        INTEGER :: d
        IF (.NOT. ASSOCIATED(root)) THEN
            d = 0
        ELSE
            d = 1 + MAX(get_depth(root%lchild), get_depth(root%rchild))
        END IF
    END FUNCTION get_depth

    RECURSIVE SUBROUTINE extract_to_array(root, arr, idx)
        TYPE(Node), POINTER, INTENT(IN) :: root
        TYPE(pair), INTENT(INOUT) :: arr(:)
        INTEGER, INTENT(INOUT) :: idx
        IF (.NOT. ASSOCIATED(root)) RETURN
        CALL extract_to_array(root%lchild, arr, idx)
        idx = idx + 1
        arr(idx) = root%node_pair
        CALL extract_to_array(root%rchild, arr, idx)
    END SUBROUTINE extract_to_array

    ! --- The Rebalancing Logic ---
    RECURSIVE SUBROUTINE build_balanced(root, arr, first, last)
        TYPE(Node), POINTER, INTENT(INOUT) :: root
        TYPE(pair), INTENT(IN) :: arr(:)
        INTEGER, INTENT(IN) :: first, last
        INTEGER :: mid

        IF (first > last) THEN
            root => NULL()
            RETURN
        END IF

        mid = (first + last) / 2
        ALLOCATE(root)
        root%node_pair = arr(mid)
        
        CALL build_balanced(root%lchild, arr, first, mid - 1)
        CALL build_balanced(root%rchild, arr, mid + 1, last)
    END SUBROUTINE build_balanced

    RECURSIVE FUNCTION search_node(root, key) RESULT(res)
        TYPE(Node), POINTER, INTENT(IN) :: root
        INTEGER, INTENT(IN) :: key
        TYPE(pair) :: res
        IF (.NOT. ASSOCIATED(root)) THEN
            res%key = -1; RETURN
        END IF
        IF (key == root%node_pair%key) THEN
            res = root%node_pair
        ELSE IF (key < root%node_pair%key) THEN
            res = search_node(root%lchild, key)
        ELSE
            res = search_node(root%rchild, key)
        END IF
    END FUNCTION search_node

    RECURSIVE SUBROUTINE free_tree(root)
        TYPE(Node), POINTER, INTENT(INOUT) :: root
        IF (.NOT. ASSOCIATED(root)) RETURN
        CALL free_tree(root%lchild)
        CALL free_tree(root%rchild)
        DEALLOCATE(root)
        NULLIFY(root)
    END SUBROUTINE free_tree


    RECURSIVE FUNCTION count_single_child(root) RESULT(c)
        TYPE(Node), POINTER, INTENT(IN) :: root
        INTEGER :: c
        INTEGER :: current_is_single

        IF (.NOT. ASSOCIATED(root)) THEN
            c = 0
            RETURN
        END IF

        
        IF ((ASSOCIATED(root%lchild) .AND. .NOT. ASSOCIATED(root%rchild)) .OR. &
            (.NOT. ASSOCIATED(root%lchild) .AND. ASSOCIATED(root%rchild))) THEN
            current_is_single = 1
        ELSE
            current_is_single = 0
        END IF

        
        c = current_is_single + count_single_child(root%lchild) + count_single_child(root%rchild)
    END FUNCTION count_single_child

END MODULE BinarySearchTree