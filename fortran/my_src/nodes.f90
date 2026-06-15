MODULE nodes
  IMPLICIT NONE
  PRIVATE

  TYPE node
      INTEGER :: val
      TYPE(node), POINTER :: next => NULL() ! Change 1: Default nullification
    CONTAINS
      PROCEDURE :: get
      PROCEDURE :: set
      PROCEDURE :: append
  END TYPE node
  
  INTERFACE node
      MODULE PROCEDURE node_default
      MODULE PROCEDURE node_copy
      MODULE PROCEDURE node_val
  END INTERFACE node

  PUBLIC :: node

CONTAINS

  TYPE(node) FUNCTION node_default()
    node_default%next => NULL()
    node_default%val = -1
  END FUNCTION node_default
  
  TYPE(node) FUNCTION node_copy(n)
    TYPE(node), INTENT(IN) :: n
    node_copy%next => NULL() 
    node_copy%val = n%val
  END FUNCTION node_copy

  TYPE(node) FUNCTION node_val(i)
    INTEGER, INTENT(IN) :: i
    node_val%next => NULL()
    node_val%val = i
  END FUNCTION node_val

  INTEGER FUNCTION get(self)
    CLASS(node), INTENT(IN) :: self
    get = self%val
  END FUNCTION get

  SUBROUTINE set(self, i)
    CLASS(node), INTENT(INOUT) :: self
    INTEGER, INTENT(IN) :: i
    self%val = i
  END SUBROUTINE set

  SUBROUTINE append(self, n)
    CLASS(node), TARGET :: self
    TYPE(node), POINTER :: n
    TYPE(node), POINTER :: ptr
    
    ptr => self
    DO WHILE (ASSOCIATED(ptr%next))
        ptr => ptr%next
    END DO
    ptr%next => n
    IF (ASSOCIATED(n)) n%next => NULL() 
  END SUBROUTINE append

END MODULE nodes