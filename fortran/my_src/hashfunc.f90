MODULE hashfunc
  USE, INTRINSIC :: ISO_C_BINDING, ONLY: c_int
  INTERFACE
      FUNCTION inthash(key, size) BIND(C,name='inthash')
        IMPORT :: c_int
        IMPLICIT NONE
        INTEGER(c_int), VALUE, INTENT(in) :: key, size
        INTEGER(c_int) :: inthash
      END FUNCTION inthash
  END INTERFACE
CONTAINS
  FUNCTION next_size(size)
    IMPLICIT NONE
    INTEGER, INTENT(in) :: size
    INTEGER :: next_size

    next_size = 1
    DO WHILE (next_size < size)
        next_size = ISHFT(next_size, 1)
    END DO
  END FUNCTION next_size
END MODULE hashfunc
