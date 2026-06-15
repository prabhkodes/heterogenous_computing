! Implement a stack class for integers using a dynamically allocated array as backing storage.
! Implement a default constructor and a copy constructor, a free() function, and push(), pop() and
! length() methods. Write a test program that instantiates one stack object, fills it with data, then
! instantiates a second via the copy constructor from the first, and adds more data to both. Empty
! both stacks in a while loop each. Finally free all allocated storage and end.

! -- INSTRUCTIONS --
! 1. Compile Module: gfortran -c StackOps.f90
! 2. Compile Main:   gfortran -o 18_stack_with_arr.x 18_stack_with_arr.f90 StackOps.o
! 3. Run Using:      ./18_stack_with_arr.x
! 4. Leak Check:     leaks --atExit -- ./18_stack_with_arr.x

PROGRAM stack_with_array
    USE StackOps
    IMPLICIT NONE

    ! CHANGED: From Stack to StackArray
    TYPE(StackArray) :: s1, s2
    INTEGER :: val

    PRINT *, "=== STACK TEST START ==="

    PRINT *, "Initializing S1 and pushing 10, 20, 30..."
    CALL s1%init(10)
    CALL s1%push(10)
    CALL s1%push(20)
    CALL s1%push(30)

    PRINT *, "Copying S1 to S2..."
    CALL s2%copy(s1)

    PRINT *, "Adding 40 to S1 and 99 to S2..."
    CALL s1%push(40)
    CALL s2%push(99)

    PRINT *, "Emptying S1 (LIFO order):"
    DO WHILE (s1%length() > 0)
        val = s1%pop()
        PRINT *, "  Popped from S1:", val
    END DO

    PRINT *, "Emptying S2 (LIFO order):"
    DO WHILE (s2%length() > 0)
        val = s2%pop()
        PRINT *, "  Popped from S2:", val
    END DO

    CALL s1%free_mem()
    CALL s2%free_mem()

    PRINT *, "=== STACK TEST END ==="
END PROGRAM stack_with_array