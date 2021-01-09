cmake_minimum_required(VERSION 3.1)
project(libshout LANGUAGES C VERSION 2.4.5)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

add_library(libshout
    src/codec_opus.c
    src/codec_vorbis.c
    src/connection.c
    src/format_mp3.c
    src/format_ogg.c
    src/format_webm.c
    src/proto_http.c
    src/proto_icy.c
    src/proto_roaraudio.c
    src/proto_xaudiocast.c
    src/queue.c
    src/shout.c
    src/tls.c
    src/util.c
)
target_include_directories(libshout PRIVATE src src/common)

target_compile_definitions(libshout
    PRIVATE
        VERSION="${CMAKE_PROJECT_VERSION}"
        LIBSHOUT_MAJOR=${CMAKE_PROJECT_VERSION_MAJOR}
        LIBSHOUT_MINOR=${CMAKE_PROJECT_VERSION_MINOR}
        LIBSHOUT_MICRO=${CMAKE_PROJECT_VERSION_PATCH}
)

# Configure shout.h
set(SHOUT_THREADSAFE 1)
set(SHOUT_TLS 1)
configure_file(include/shout/shout.h.in "${CMAKE_CURRENT_BINARY_DIR}/include/shout/shout.h" @ONLY)
target_include_directories(libshout BEFORE PRIVATE include "${CMAKE_CURRENT_BINARY_DIR}/include")

# Required system dependencies
find_package(Ogg REQUIRED)
target_link_libraries(libshout PRIVATE Ogg::ogg)
find_package(Vorbis REQUIRED)
target_link_libraries(libshout PRIVATE Vorbis::vorbis Vorbis::vorbisenc Vorbis::vorbisfile)

# Optional system dependencies
find_package(OpenSSL)
if(TARGET OpenSSL::SSL)
    target_compile_definitions(libshout PRIVATE HAVE_OPENSSL)
    target_link_libraries(libshout PRIVATE OpenSSL::SSL OpenSSL::Crypto)
endif()

option(SPEEX "Speex support" OFF)
if(SPEEX)
    target_sources(libshout src/codec_speex.c)
    # TODO: Add support for finding speex headers and linking
endif()

option(THEORA "Theora support" OFF)
if(THEORA)
    target_sources(libshout src/codec_theora.c)
    # TODO: Add support for finding theora headers and linking
    #find_package(unofficial-theora)
    #if(TARGET unofficial::theora::theora)
    #    target_compile_definitions(libshout PRIVATE HAVE_THEORA)
    #    target_link_libraries(libshout PRIVATE unofficial::theora::theora unofficial::theora::theoradec unofficial::theora::theoraenc)
    #endif()
endif()

# Dependencies in common directory
add_subdirectory(src/common/httpp)
target_link_libraries(libshout PRIVATE icecast-httpp)
add_subdirectory(src/common/net)
target_link_libraries(libshout PRIVATE icecast-net)
add_subdirectory(src/common/timing)
target_link_libraries(libshout PRIVATE icecast-timing)

# Installation / Packaging
include(GNUInstallDirs)
install(TARGETS libshout
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
)
install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/include/shout/shout.h"
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/shout"
)
