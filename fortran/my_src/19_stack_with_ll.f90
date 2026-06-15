! Program another stack class with the same API as in section 19 and use a linked list as backing
! storage this time. Discuss benefits and disadvantages of these two kinds of stack classes.

! -- INSTRUCTIONS --
! 1. Compile Module: gfortran -c StackOps.f90
! 2. Compile Main:   gfortran -o 19_stack_with_ll.x 19_stack_with_ll.f90 StackOps.o
! 3. Run Using:      ./19_stack_with_ll.x
! 4. Check leaks using: leaks --atExit -- ./19_stack_with_ll.x

PROGRAM stack_with_list
    USE StackOps
    IMPLICIT NONE

    TYPE(StackList) :: s1
    INTEGER :: val, i

    PRINT *, "=== LINKED LIST STACK TEST START ==="

    ! 1. Initialize and fill with data
    CALL s1%init(0) ! Size argument is ignored for lists
    PRINT *, "Pushing 10, 20, 30, 40, 50..."
    DO i = 1, 5
        CALL s1%push(i * 10)
    END DO

    PRINT *, "Current Stack Length:", s1%length()

    ! 2. Empty the stack in a while loop (LIFO behavior)
    PRINT *, "Emptying stack (LIFO order):"
    DO WHILE (s1%length() > 0)
        val = s1%pop()
        PRINT *, "  Popped:", val
    END DO

    ! 3. Final cleanup
    CALL s1%free_mem()
    PRINT *, "Stack freed. Final length:", s1%length()

    PRINT *, "=== LINKED LIST STACK TEST END ==="

END PROGRAM stack_with_list