# This file is part of Mixxx, Digital DJ'ing software.
# Copyright (C) 2001-2020 Mixxx Development Team
# Distributed under the GNU General Public Licence (GPL) version 2 or any later
# later version. See the LICENSE file for details.

#[=======================================================================[.rst:
FindVorbis
----------

Finds the Vorbis library.

Result Variables
^^^^^^^^^^^^^^^^

This will define the following variables:

``Vorbis_FOUND``
    True if the system has the Vorbis library.
``Vorbis_INCLUDE_DIRS``
    Include directories needed to use Vorbis.
``Vorbis_LIBRARIES``
    Libraries needed to link to Vorbis.

Cache Variables
^^^^^^^^^^^^^^^

The following cache variables may also be set:

``Vorbis_vorbis_INCLUDE_DIR``
    The directory containing ``vorbis/vorbis.h``.
``Vorbis_vorbis_LIBRARY``
    The path to the vorbis library.
``Vorbis_vorbisenc_INCLUDE_DIR``
    The directory containing ``vorbis/vorbisenc.h``.
``Vorbis_vorbisfile_LIBRARY``
    The path to the vorbisfile library.
``Vorbis_vorbisfile_INCLUDE_DIR``
    The directory containing ``vorbis/vorbisfile.h``.
``Vorbis_vorbisenc_LIBRARY``
    The path to the vorbisenc library.

#]=======================================================================]
include(FindPackageHandleStandardArgs)

# vorbis
find_path(Vorbis_vorbis_INCLUDE_DIR
    NAMES vorbis/codec.h
    DOC "Vorbis include directory"
)
mark_as_advanced(Vorbis_vorbis_INCLUDE_DIR)
find_library(Vorbis_vorbis_LIBRARY NAMES vorbis DOC "Vorbis library")
mark_as_advanced(Vorbis_vorbis_LIBRARY)
if(Vorbis_vorbis_INCLUDE_DIR AND Vorbis_vorbis_LIBRARY)
    set(Vorbis_vorbis_FOUND TRUE)
endif()

# vorbisenc
find_path(Vorbis_vorbisenc_INCLUDE_DIR
    NAMES vorbis/vorbisenc.h
    DOC "Vorbisenc include directory"
)
mark_as_advanced(Vorbis_vorbisenc_INCLUDE_DIR)
find_library(Vorbis_vorbisenc_LIBRARY NAMES vorbisenc DOC "Vorbisenc library")
mark_as_advanced(Vorbis_vorbisenc_LIBRARY)
if(Vorbis_vorbisenc_INCLUDE_DIR AND Vorbis_vorbisenc_LIBRARY)
    set(Vorbis_vorbisenc_FOUND TRUE)
endif()

# vorbisfile
find_path(Vorbis_vorbisfile_INCLUDE_DIR
    NAMES vorbis/vorbisfile.h
    DOC "Vorbisfile include directory"
)
mark_as_advanced(Vorbis_vorbisfile_INCLUDE_DIR)
find_library(Vorbis_vorbisfile_LIBRARY NAMES vorbisfile DOC "Vorbisfile library")
mark_as_advanced(Vorbis_vorbisfile_LIBRARY)
if(Vorbis_vorbisfile_INCLUDE_DIR AND Vorbis_vorbisfile_LIBRARY)
    set(Vorbis_vorbisfile_FOUND TRUE)
endif()

# Handle components
if(NOT Vorbis_FIND_COMPONENTS)
    set(Vorbis_FIND_COMPONENTS vorbis vorbisenc vorbisfile)
    set(Vorbis_FIND_REQUIRED_vorbis TRUE)
    set(Vorbis_FIND_REQUIRED_vorbisenc TRUE)
    set(Vorbis_FIND_REQUIRED_vorbisfile TRUE)
endif()
find_package_handle_standard_args(Vorbis HANDLE_COMPONENTS)
foreach(component ${Vorbis_FIND_COMPONENTS})
    if(NOT TARGET Vorbis::${component})
        add_library(Vorbis::${component} UNKNOWN IMPORTED)
        set_target_properties(Vorbis::${component}
            PROPERTIES
            IMPORTED_LOCATION "${Vorbis_${component}_LIBRARY}"
            INTERFACE_INCLUDE_DIRECTORIES "${Vorbis_${component}_INCLUDE_DIR}"
        )
    endif()
endforeach()
