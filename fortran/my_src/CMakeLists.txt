cmake_minimum_required(VERSION 3.16)
project(FortranBuilds LANGUAGES C Fortran)

set(CMAKE_BUILD_TYPE RelWithDebInfo)

add_library(modules STATIC
    hash_map_helpers.f90
    StackOps.f90
    BSTModule.f90
    list_types.f90
    list_tools.f90
    nodes.f90
    sorting.f90
    hashfunc.f90
    inthash.c
)

file(GLOB PROGRAMS "[0-9][0-9]_*.f90")

foreach(src ${PROGRAMS})
    get_filename_component(exe ${src} NAME_WE)
    
    add_executable(${exe} ${src})
    target_link_libraries(${exe} PRIVATE modules)
endforeach()