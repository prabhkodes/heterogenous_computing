module list_tools
    use list_types
    implicit none

    logical, parameter :: ascending = .true.
    logical, parameter :: descending = .false.
    logical, parameter :: bykey = .true.
    logical, parameter :: byvalue = .false.

    interface is_sorted
        module procedure is_sorted_real
        module procedure is_sorted_integer
        module procedure is_sorted_pair
    end interface

contains

    function is_sorted_pair(arr, asc, by) result(res)
        type(pair), intent(in) :: arr(:)
        logical, intent(in), optional :: asc, by
        logical :: res, do_asc, do_key
        integer :: i, N

        N = SIZE(arr, 1)
        do_asc = .true.
        if (present(asc)) do_asc = asc
        
        do_key = .true.
        if (present(by)) do_key = by

        res = .true.
        do i = 2, N
            if (do_key) then
                if (do_asc) then
                    if (arr(i-1)%key > arr(i)%key) res = .false.
                else
                    if (arr(i-1)%key < arr(i)%key) res = .false.
                end if
            else
                if (do_asc) then
                    if (arr(i-1)%val > arr(i)%val) res = .false.
                else
                    if (arr(i-1)%val < arr(i)%val) res = .false.
                end if
            end if
            if (.not. res) return
        end do
    end function is_sorted_pair

    function is_sorted_real(arr, asc) result(res)
        real(4), intent(in) :: arr(:)
        logical, intent(in), optional :: asc
        logical :: res, do_asc
        integer :: i, N

        N = SIZE(arr, 1)
        do_asc = .true.
        if (present(asc)) do_asc = asc

        res = .true.
        do i = 2, N
            if (do_asc) then
                if (arr(i-1) > arr(i)) then
                    res = .false.
                    return
                end if
            else
                if (arr(i-1) < arr(i)) then
                    res = .false.
                    return
                end if
            end if
        end do
    end function is_sorted_real

    function is_sorted_integer(arr, asc) result(res)
        integer, intent(in) :: arr(:)
        logical, intent(in), optional :: asc
        logical :: res, do_asc
        integer :: i, N

        N = SIZE(arr, 1)
        do_asc = .true.
        if (present(asc)) do_asc = asc

        res = .true.
        do i = 2, N
            if (do_asc) then
                if (arr(i-1) > arr(i)) then
                    res = .false.
                    return
                end if
            else
                if (arr(i-1) < arr(i)) then
                    res = .false.
                    return
                end if
            end if
        end do
    end function is_sorted_integer

    subroutine swap(a, b)
        real(4), intent(inout) :: a, b
        real(4) :: tmp
        tmp = a
        a = b
        b = tmp
    end subroutine swap

    function lookup_array(arr, target_key) result(res)
        type(pair), intent(in) :: arr(:)
        integer, intent(in) :: target_key
        type(pair) :: res
        integer :: i
        
        res%key = -1 ! Default if not found
        res%val = 0.0
        
        do i = 1, size(arr)
            if (arr(i)%key == target_key) then
                res = arr(i)
                return
            end if
        end do
    end function lookup_array

END MODULE list_tools