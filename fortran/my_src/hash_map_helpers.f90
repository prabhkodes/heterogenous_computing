MODULE hash_map_helpers
    IMPLICIT NONE
    
    TYPE HashNode    
        integer :: key
        real :: value
        type(HashNode), pointer :: next_add => NULL() 
    END TYPE HashNode

    ! This type is used to represent the entries in the data file
    TYPE Dictionary
        integer :: key
        real :: value
    END TYPE Dictionary

    PUBLIC :: HashNode, Dictionary, node_push_back, print_hashmap, free_hashmap

CONTAINS

    FUNCTION make_new_node(key, value) RESULT (new_node)
        type(HashNode), pointer :: new_node
        INTEGER, INTENT(IN) :: key
        REAL, INTENT(IN) :: value

        allocate(new_node)
        new_node%next_add => NULL()
        new_node%key = key
        new_node%value = value
    END FUNCTION make_new_node

    SUBROUTINE node_push_back(head_node, key, value)
        type(HashNode), pointer :: head_node
        type(HashNode), pointer :: current_node
        integer, intent(in) :: key
        real, intent(in) :: value

        IF (.not. ASSOCIATED(head_node)) then
            head_node => make_new_node(key, value)
            return
        END IF

        current_node => head_node
        do while (ASSOCIATED(current_node%next_add)) 
            current_node => current_node%next_add
        end do
        
        current_node%next_add => make_new_node(key, value)
    END SUBROUTINE node_push_back

    SUBROUTINE print_hashmap(buckets_array, table_size)
        TYPE(HashNode), POINTER :: buckets_array(:)
        INTEGER, INTENT(IN) :: table_size
        TYPE(HashNode), POINTER :: current_node
        INTEGER :: i

        DO i = 1, table_size
            IF (.NOT. ASSOCIATED(buckets_array(i)%next_add) .and. buckets_array(i)%key == -1) CYCLE

            WRITE(*,*) "Bucket ", i, ":"
            current_node => buckets_array(i)
            DO WHILE (ASSOCIATED(current_node))
                IF (current_node%key /= -1) THEN
                    WRITE(*,*) "   Key:", current_node%key, "Value:", current_node%value
                END IF
                current_node => current_node%next_add
            END DO
        END DO
    END SUBROUTINE print_hashmap

    SUBROUTINE free_hashmap(buckets_array, table_size)
        TYPE(HashNode), POINTER :: buckets_array(:)
        INTEGER, INTENT(IN) :: table_size
        TYPE(HashNode), POINTER :: current_node, temp
        INTEGER :: i

        DO i = 1, table_size
            current_node => buckets_array(i)%next_add
            DO WHILE (ASSOCIATED(current_node))
                temp => current_node
                current_node => current_node%next_add
                DEALLOCATE(temp)
            END DO
        END DO
    END SUBROUTINE free_hashmap

END MODULE hash_map_helpers