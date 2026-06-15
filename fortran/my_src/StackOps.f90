MODULE StackOps
    IMPLICIT NONE
    PRIVATE
    PUBLIC :: StackArray, StackList

    TYPE :: StackArray
        INTEGER, ALLOCATABLE :: storage(:)
        INTEGER :: top = 0
    CONTAINS
        PROCEDURE :: init => arr_init
        PROCEDURE :: copy => arr_copy
        PROCEDURE :: push => arr_push
        PROCEDURE :: pop  => arr_pop
        PROCEDURE :: length => arr_len
        PROCEDURE :: free_mem => arr_free
    END TYPE StackArray

    TYPE :: Node
        INTEGER :: val
        TYPE(Node), POINTER :: next => NULL()
    END TYPE Node

    TYPE :: StackList
        TYPE(Node), POINTER :: head => NULL()
        INTEGER :: count = 0
    CONTAINS
        PROCEDURE :: init => list_init
        PROCEDURE :: push => list_push
        PROCEDURE :: pop  => list_pop
        PROCEDURE :: length => list_len
        PROCEDURE :: free_mem => list_free
    END TYPE StackList

CONTAINS

    ! --- Array Implementation ---
    SUBROUTINE arr_init(self, size)
        CLASS(StackArray), INTENT(INOUT) :: self
        INTEGER, INTENT(IN) :: size
        IF (ALLOCATED(self%storage)) DEALLOCATE(self%storage)
        ALLOCATE(self%storage(size))
        self%top = 0
    END SUBROUTINE arr_init

    SUBROUTINE arr_copy(self, other)
        CLASS(StackArray), INTENT(OUT) :: self
        CLASS(StackArray), INTENT(IN)  :: other
        IF (ALLOCATED(other%storage)) THEN
            ALLOCATE(self%storage(SIZE(other%storage)))
            self%storage = other%storage
            self%top = other%top
        END IF
    END SUBROUTINE arr_copy

    SUBROUTINE arr_push(self, value)
        CLASS(StackArray), INTENT(INOUT) :: self
        INTEGER, INTENT(IN) :: value
        self%top = self%top + 1
        self%storage(self%top) = value
    END SUBROUTINE arr_push

    FUNCTION arr_pop(self) RESULT(res)
        CLASS(StackArray), INTENT(INOUT) :: self
        INTEGER :: res
        res = self%storage(self%top)
        self%top = self%top - 1
    END FUNCTION arr_pop

    INTEGER FUNCTION arr_len(self)
        CLASS(StackArray), INTENT(IN) :: self
        arr_len = self%top
    END FUNCTION arr_len

    SUBROUTINE arr_free(self)
        CLASS(StackArray), INTENT(INOUT) :: self
        IF (ALLOCATED(self%storage)) DEALLOCATE(self%storage)
        self%top = 0
    END SUBROUTINE arr_free

    ! --- Linked List Implementation ---
    SUBROUTINE list_init(self, size)
        CLASS(StackList), INTENT(INOUT) :: self
        INTEGER, INTENT(IN) :: size
        CALL self%free_mem()
    END SUBROUTINE list_init

    SUBROUTINE list_push(self, value)
        CLASS(StackList), INTENT(INOUT) :: self
        INTEGER, INTENT(IN) :: value
        TYPE(Node), POINTER :: nn
        ALLOCATE(nn)
        nn%val = value
        nn%next => self%head
        self%head => nn
        self%count = self%count + 1
    END SUBROUTINE list_push

    FUNCTION list_pop(self) RESULT(res)
        CLASS(StackList), INTENT(INOUT) :: self
        TYPE(Node), POINTER :: tmp
        INTEGER :: res
        res = self%head%val
        tmp => self%head
        self%head => self%head%next
        DEALLOCATE(tmp)
        self%count = self%count - 1
    END FUNCTION list_pop

    INTEGER FUNCTION list_len(self)
        CLASS(StackList), INTENT(IN) :: self
        list_len = self%count
    END FUNCTION list_len

    SUBROUTINE list_free(self)
        CLASS(StackList), INTENT(INOUT) :: self
        TYPE(Node), POINTER :: tmp
        DO WHILE (ASSOCIATED(self%head))
            tmp => self%head
            self%head => self%head%next
            DEALLOCATE(tmp)
        END DO
        self%count = 0
    END SUBROUTINE list_free

END MODULE StackOps