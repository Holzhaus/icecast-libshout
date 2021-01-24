cmake_minimum_required(VERSION 3.1)
project(Shout LANGUAGES C VERSION 2.4.5)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

add_library(shout
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
target_include_directories(shout PRIVATE src src/common)

target_compile_definitions(shout
    PRIVATE
        VERSION="${CMAKE_PROJECT_VERSION}"
        LIBSHOUT_MAJOR=${CMAKE_PROJECT_VERSION_MAJOR}
        LIBSHOUT_MINOR=${CMAKE_PROJECT_VERSION_MINOR}
        LIBSHOUT_MICRO=${CMAKE_PROJECT_VERSION_PATCH}
)
if(MSVC AND BUILD_SHARED_LIBS)
  target_compile_definitions(shout PRIVATE LIBSHOUT_DLLEXPORT)
endif()

# Configure shout.h
set(SHOUT_THREADSAFE 1)
set(SHOUT_TLS 1)
configure_file(include/shout/shout.h.in "${CMAKE_CURRENT_BINARY_DIR}/include/shout/shout.h" @ONLY)
target_include_directories(shout BEFORE PRIVATE include "${CMAKE_CURRENT_BINARY_DIR}/include")

# Required system dependencies
find_package(Ogg REQUIRED)
target_link_libraries(shout PRIVATE Ogg::ogg)
find_package(Vorbis REQUIRED)
target_link_libraries(shout PRIVATE Vorbis::vorbis Vorbis::vorbisenc Vorbis::vorbisfile)

# Optional system dependencies
find_package(OpenSSL)
if(TARGET OpenSSL::SSL)
    target_compile_definitions(shout PRIVATE HAVE_OPENSSL)
    target_link_libraries(shout PRIVATE OpenSSL::SSL OpenSSL::Crypto)
endif()

option(SPEEX "Speex support" OFF)
if(SPEEX)
    target_sources(shout src/codec_speex.c)
    # TODO: Add support for finding speex headers and linking
endif()

option(THEORA "Theora support" OFF)
if(THEORA)
    target_sources(shout src/codec_theora.c)
    # TODO: Add support for finding theora headers and linking
    #find_package(unofficial-theora)
    #if(TARGET unofficial::theora::theora)
    #    target_compile_definitions(shout PRIVATE HAVE_THEORA)
    #    target_link_libraries(shout PRIVATE unofficial::theora::theora unofficial::theora::theoradec unofficial::theora::theoraenc)
    #endif()
endif()

# Dependencies in common directory
add_subdirectory(src/common/httpp)
target_link_libraries(shout PRIVATE icecast-httpp)
add_subdirectory(src/common/net)
target_link_libraries(shout PRIVATE icecast-net)
add_subdirectory(src/common/timing)
target_link_libraries(shout PRIVATE icecast-timing)

# Header files
include(CheckIncludeFile)

check_include_file(arpa/inet.h HAVE_ARPA_INET_H)
if(HAVE_ARPA_INET_H)
    target_compile_definitions(shout PRIVATE HAVE_ARPA_INET_H)
endif()

check_include_file(inttypes.h HAVE_INTTYPES_H)
if(HAVE_INTTYPES_H)
    target_compile_definitions(shout PRIVATE HAVE_INTTYPES_H)
endif()

check_include_file(stdint.h HAVE_STDINT_H)
if(HAVE_STDINT_H)
    target_compile_definitions(shout PRIVATE HAVE_STDINT_H)
endif()

check_include_file(strings.h HAVE_STRINGS_H)
if(HAVE_STRINGS_H)
    target_compile_definitions(shout PRIVATE HAVE_STRINGS_H)
endif()

check_include_file(sys/select.h HAVE_SYS_SELECT_H)
if(HAVE_SYS_SELECT_H)
    target_compile_definitions(shout PRIVATE HAVE_SYS_SELECT_H)
endif()

check_include_file(sys/socket.h HAVE_SYS_SOCKET_H)
if(HAVE_SYS_SOCKET_H)
    target_compile_definitions(shout PRIVATE HAVE_SYS_SOCKET_H)
endif()

check_include_file(winsock2.h HAVE_WINSOCK2_H)
if(HAVE_WINSOCK2_H)
    target_compile_definitions(shout PRIVATE HAVE_WINSOCK2_H)
endif()

# Symbols
include(CheckSymbolExists)

check_symbol_exists(strcasestr "string.h" HAVE_STRCASESTR)
if(HAVE_STRCASESTR)
    target_compile_definitions(shout PRIVATE HAVE_STRCASESTR)
endif()

check_symbol_exists(X509_check_host "openssl/x509v3.h" HAVE_X509_CHECK_HOST)
if(HAVE_X509_CHECK_HOST)
    target_compile_definitions(shout PRIVATE XXX_HAVE_X509_check_host)
endif()

#
# Installation / Packaging
#
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# Library files
install(TARGETS shout
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
)

# Header files
install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/include/shout/shout.h"
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/shout"
)

# CMake config
configure_package_config_file(ShoutConfig.cmake.in
    "${CMAKE_CURRENT_BINARY_DIR}/ShoutConfig.cmake"
    INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/Shout"
    PATH_VARS CMAKE_INSTALL_LIBDIR
)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/ShoutConfigVersion.cmake"
    VERSION "${CMAKE_PROJECT_VERSION}"
    COMPATIBILITY SameMajorVersion
)
install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/ShoutConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/ShoutConfigVersion.cmake"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/Shout"
)
