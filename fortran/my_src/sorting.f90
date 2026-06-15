module sorting
    use list_tools
    implicit none
    private
    
    public :: simplesort, quicksort, quicksort_alt, bubble_sort, &
              insertion_sort, merge_sort, hybrid_sort

contains

    subroutine simplesort(dat)
        real, dimension(:), intent(inout) :: dat
        integer :: num, i, j
        num = SIZE(dat, 1)
        if (num < 2) return
        do i = 1, num - 1
            do j = i + 1, num
                if (dat(i) > dat(j)) call swap(dat(i), dat(j))
            end do
        end do
        if (.not. is_sorted(dat)) print *, "WARNING: simplesort failed to sort array!"
    end subroutine simplesort

    subroutine quicksort(dat)
        real, dimension(:), intent(inout) :: dat
        if (SIZE(dat, 1) < 2) return
        call quicksort_recurse(dat, 1, SIZE(dat, 1), .false.) ! Use standard pivot
        if (.not. is_sorted(dat)) print *, "WARNING: quicksort failed to sort array!"
    end subroutine quicksort

    ! CHANGE 2: Added the alt wrapper
    subroutine quicksort_alt(dat)
        real, dimension(:), intent(inout) :: dat
        if (SIZE(dat, 1) < 2) return
        call quicksort_recurse(dat, 1, SIZE(dat, 1), .true.) ! Use alt pivot
        if (.not. is_sorted(dat)) print *, "WARNING: quicksort_alt failed to sort array!"
    end subroutine quicksort_alt

    recursive subroutine quicksort_recurse(dat, left, right, alt)
        real, dimension(:), intent(inout) :: dat
        integer, intent(in) :: left, right
        logical, intent(in) :: alt
        integer :: p
        if (left < right) then
            p = partition(dat, left, right, alt)
            call quicksort_recurse(dat, left, p - 1, alt)
            call quicksort_recurse(dat, p + 1, right, alt)
        end if
    end subroutine quicksort_recurse

    ! CHANGE 3: Updated partition logic for pivot strategy
    function partition(dat, left, right, alt) result(i)
        real, dimension(:), intent(inout) :: dat
        integer :: i, j, left, right, mid
        logical, intent(in) :: alt
        real :: pivot
        
        if (alt) then
            mid = left + (right - left) / 2
            call swap(dat(mid), dat(right))
        end if
        
        pivot = dat(right)
        i = left
        do j = left, right - 1
            if (dat(j) < pivot) then
                call swap(dat(i), dat(j))
                i = i + 1
            end if
        end do
        call swap(dat(i), dat(right))
    end function partition

    subroutine bubble_sort(dat)
        real, dimension(:), intent(inout) :: dat
        integer :: N, i, j
        N = SIZE(dat, 1)
        do i = 1, N
            do j = 1, N - 1
                if (dat(j) > dat(j+1)) call swap(dat(j), dat(j+1))
            end do
        end do
        if (.not. is_sorted(dat)) print *, "WARNING: bubble_sort failed to sort array!"
    end subroutine bubble_sort

    subroutine insertion_sort(dat)
        real, dimension(:), intent(inout) :: dat
        real :: key
        integer :: N, i, j
        N = SIZE(dat, 1)
        do i = 2, N
            key = dat(i)
            j = i - 1
            do while (j > 0 .and. dat(j) > key)
                dat(j+1) = dat(j)
                j = j - 1
            end do
            dat(j+1) = key
        end do
        if (.not. is_sorted(dat)) print *, "WARNING: insertion_sort failed to sort array!"
    end subroutine insertion_sort

    subroutine merge_sort(dat)
        real, dimension(:), intent(inout) :: dat
        real, allocatable :: temp(:)
        integer :: n, sz, low, mid, high
        
        n = size(dat)
        if (n < 2) return
        
        allocate(temp(n))
        
        ! Iterative merging: sz is the size of the sub-lists (1, 2, 4, 8...)
        sz = 1
        do while (sz < n)
            low = 1
            do while (low < n)
                mid = min(low + sz - 1, n)
                high = min(low + 2*sz - 1, n)
                
                call merge(dat, temp, low, mid, high)
                low = low + 2*sz
            end do
            sz = sz * 2
        end do
        
        deallocate(temp)
        
        if (.not. is_sorted(dat)) print *, "WARNING: merge_sort failed!"
    end subroutine merge_sort

    subroutine merge(dat, temp, low, mid, high)
        real, dimension(:), intent(inout) :: dat
        real, dimension(:), intent(inout) :: temp
        integer, intent(in) :: low, mid, high
        integer :: i, j, k

        i = low
        j = mid + 1
        
        ! Merge the two halves into temp array
        do k = low, high
            if (i <= mid .and. (j > high .or. dat(i) <= dat(j))) then
                temp(k) = dat(i)
                i = i + 1
            else
                temp(k) = dat(j)
                j = j + 1
            end if
        end do
        
        ! Copy back to original array
        dat(low:high) = temp(low:high)
    end subroutine merge

    subroutine hybrid_sort(dat)
        real, dimension(:), intent(inout) :: dat
        real, allocatable :: temp(:)
        integer :: n, sz, i, low, mid, high, chunk_end
        
        n = size(dat)
        if (n < 2) return
        
        
        do i = 1, n, 32
            chunk_end = min(i + 31, n)
            call insertion_sort_range(dat, i, chunk_end)
        end do
        
        
        allocate(temp(n))
        sz = 32
        do while (sz < n)
            low = 1
            do while (low < n)
                mid = min(low + sz - 1, n)
                high = min(low + 2*sz - 1, n)
                
                if (mid < high) then
                    call merge(dat, temp, low, mid, high)
                end if
                low = low + 2*sz
            end do
            sz = sz * 2
        end do
        deallocate(temp)
        
        if (.not. is_sorted(dat)) print *, "WARNING: hybrid_sort failed!"
    end subroutine hybrid_sort

    ! Internal helper for hybrid sort: insertion sort on a specific range
    subroutine insertion_sort_range(dat, left, right)
        real, dimension(:), intent(inout) :: dat
        integer, intent(in) :: left, right
        real :: key
        integer :: i, j
        
        do i = left + 1, right
            key = dat(i)
            j = i - 1
            do while (j >= left .and. dat(j) > key)
                dat(j+1) = dat(j)
                j = j - 1
            end do
            dat(j+1) = key
        end do
    end subroutine insertion_sort_range
end module sorting