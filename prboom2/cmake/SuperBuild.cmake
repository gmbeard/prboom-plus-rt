include(ExternalProject)

get_filename_component(_DEP_PREFIX ${CMAKE_CURRENT_LIST_FILE} DIRECTORY)
get_filename_component(_DEP_PREFIX ${_DEP_PREFIX} DIRECTORY)
get_filename_component(_DEP_PREFIX ${_DEP_PREFIX} DIRECTORY)

find_package(DLSS QUIET)
if(NOT DLSS_FOUND)
    ExternalProject_Add(
        DLSSProject
        SOURCE_DIR ${_DEP_PREFIX}/DLSS
        BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/DLSS/build
        INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/DLSS/install
        BUILD_ALWAYS ON
        CMAKE_ARGS
            -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
    )

    ExternalProject_Add_Step(
        DLSSProject
        COPY_RUNTIME
        COMMENT "Copying DLSS runtime to ${CMAKE_CURRENT_BINARY_DIR}/rel"
        DEPENDEES install
        COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/rel/
        COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/DLSS/install/lib/libnvidia-ngx-dlss.so.2.4.0 ${CMAKE_CURRENT_BINARY_DIR}/rel/
    )
else()
    add_custom_target(DLSSProject)
endif()

find_package(RTGL1 QUIET)
if(NOT RTGL1_FOUND)
    ExternalProject_Add(
        RTGL1Project
        DEPENDS
            DLSSProject
        SOURCE_DIR ${_DEP_PREFIX}/RayTracedGL1
        BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/RTGL1/build
        INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/RTGL1/install
        BUILD_ALWAYS ON
        CMAKE_ARGS
            -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
            -DRTGL1_SUPERBUILD=OFF
            -DDLSS_DIR=${CMAKE_CURRENT_BINARY_DIR}/DLSS/install/lib/cmake/DLSS
            -DRG_WITH_SURFACE_XLIB=ON
    )
else()
    add_custom_target(RTGL1Project)
endif()

ExternalProject_Add(
    RuntimeContent
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/runtime-content
    INSTALL_COMMAND ""
    BUILD_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_BINARY_DIR}/runtime-content/ovrd ${CMAKE_CURRENT_BINARY_DIR}/ovrd
    CONFIGURE_COMMAND ""
    URL "https://github.com/sultim-t/prboom-plus-rt/releases/download/v2.6.1-rt1.0.2/prboom-rt-1.0.2a.zip"
)

ExternalProject_Add(
    ThisProject
    DEPENDS
        DLSSProject
        RTGL1Project
    SOURCE_DIR ${PROJECT_SOURCE_DIR}
    BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}
    INSTALL_COMMAND ""
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    CMAKE_ARGS
        -DPRBOOM_SUPERBUILD=OFF
        -DDLSS_DIR=${CMAKE_CURRENT_BINARY_DIR}/DLSS/install/lib/cmake/DLSS
        -DRayTracedGL1_DIR=${CMAKE_CURRENT_BINARY_DIR}/RTGL1/install/lib/cmake/RayTracedGL1
)

set(PRBOOM_SUPERBUILD OFF)
