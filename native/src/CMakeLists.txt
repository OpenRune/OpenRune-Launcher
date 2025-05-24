if(MSVC)
    add_compile_options(/W4)
else()
    add_compile_options(-Wall)
endif()

# --- Read gradle.properties two dirs up ---
file(READ "${CMAKE_CURRENT_SOURCE_DIR}/../../gradle.properties" GRADLE_PROPS_CONTENTS)

# Extract 'finalName' property from gradle.properties
string(REGEX MATCH "finalName=([^\n\r]*)" _match "${GRADLE_PROPS_CONTENTS}")
string(REGEX REPLACE "finalName=([^\n\r]*)" "\\1" FINAL_NAME "${_match}")

if(NOT FINAL_NAME)
    message(FATAL_ERROR "finalName not found in gradle.properties")
endif()

message(STATUS "Using finalName from gradle.properties: ${FINAL_NAME}")

# --- Define executable target ---
add_executable(packr WIN32 packr.cpp)
set_target_properties(packr PROPERTIES OUTPUT_NAME "${FINAL_NAME}")

if(WIN32)
    set_target_properties(packr PROPERTIES LINK_FLAGS "/LARGEADDRESSAWARE")
    target_sources(packr PUBLIC win32/packr_win32.cpp win32/runelite.manifest win32/runelite.rc)
    set_property(TARGET packr PROPERTY MSVC_RUNTIME_LIBRARY "MultiThreaded") # multi-threaded statically-linked runtime
elseif(APPLE)
    target_sources(packr PUBLIC macos/packr_macos.cpp)

    find_library(CORE_FOUNDATION CoreFoundation)
    target_link_libraries(packr ${CORE_FOUNDATION})
else()
    target_sources(packr PUBLIC linux/packr_linux.cpp)
    target_link_libraries(packr dl pthread Threads::Threads)
endif()
target_link_libraries(packr dropt)
