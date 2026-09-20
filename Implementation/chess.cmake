set(CHESS_NAME Chess)

file(GLOB CHESS_SOURCES ${CMAKE_CURRENT_LIST_DIR}/src/*.cpp)
file(GLOB CHESS_INCS    ${CMAKE_CURRENT_LIST_DIR}/src/*.h)

file(GLOB CHESS_INC_TD     ${MY_INC}/td/*.h)
file(GLOB CHESS_INC_GUI    ${MY_INC}/gui/*.h)
file(GLOB CHESS_INC_THREAD ${MY_INC}/thread/*.h)
file(GLOB CHESS_INC_CNT    ${MY_INC}/cnt/*.h)
file(GLOB CHESS_INC_FO     ${MY_INC}/fo/*.h)
file(GLOB CHESS_INC_XML    ${MY_INC}/xml/*.h)

# Application icon
set(CHESS_PLIST ${CMAKE_CURRENT_LIST_DIR}/res/appIcon/AppIcon.plist)
if(WIN32)
    set(CHESS_WINAPP_ICON ${CMAKE_CURRENT_LIST_DIR}/res/appIcon/winAppIcon.rc)
else()
    set(CHESS_WINAPP_ICON ${CMAKE_CURRENT_LIST_DIR}/res/appIcon/winAppIcon.cpp)
endif()

add_executable(${CHESS_NAME}
    ${CHESS_INCS} ${CHESS_SOURCES}
    ${CHESS_INC_TD} ${CHESS_INC_THREAD} ${CHESS_INC_CNT}
    ${CHESS_INC_FO} ${CHESS_INC_GUI} ${CHESS_INC_XML}
    ${CHESS_WINAPP_ICON})

target_compile_features(${CHESS_NAME} PRIVATE cxx_std_20)   # natID headers use C++20 concepts

source_group("src"          FILES ${CHESS_SOURCES})
source_group("inc"          FILES ${CHESS_INCS})
source_group("inc\\td"      FILES ${CHESS_INC_TD})
source_group("inc\\cnt"     FILES ${CHESS_INC_CNT})
source_group("inc\\fo"      FILES ${CHESS_INC_FO})
source_group("inc\\gui"     FILES ${CHESS_INC_GUI})
source_group("inc\\thread"  FILES ${CHESS_INC_THREAD})
source_group("inc\\xml"     FILES ${CHESS_INC_XML})

target_link_libraries(${CHESS_NAME}
    debug     ${MU_LIB_DEBUG}   debug     ${NATGUI_LIB_DEBUG}
    optimized ${MU_LIB_RELEASE} optimized ${NATGUI_LIB_RELEASE})

setTargetPropertiesForGUIApp(${CHESS_NAME} ${CHESS_PLIST})
setAppIcon(${CHESS_NAME} ${CMAKE_CURRENT_LIST_DIR})
setIDEPropertiesForGUIExecutable(${CHESS_NAME} ${CMAKE_CURRENT_LIST_DIR})
setPlatformDLLPath(${CHESS_NAME})

# setIDEPropertiesForGUIExecutable() in DevEnv/Common.cmake writes
#     VS_DEBUGGER_COMMAND_ARGUMENTS "-devResPath=${DevResPathLoc}"
# but its parameter is named devResPath, so DevResPathLoc is undefined and the
# app is launched with an empty resource path. natGUI then fails while loading
# res/DevRes.xml and crashes inside the gui::Application constructor. Setting
# the argument again here overrides it with the correct folder.
# (macOS uses ${devResPath} correctly, so this is a Windows-only fix.)
if(MSVC)
    set_target_properties(${CHESS_NAME} PROPERTIES
        VS_DEBUGGER_COMMAND_ARGUMENTS "-devResPath=${CMAKE_CURRENT_LIST_DIR}")
endif()

# The GUI executable is /SUBSYSTEM:WINDOWS but uses a plain main();
# src/main.cpp includes <gui/WinMain.h>, this makes the entry point explicit.
if(MSVC)
    target_link_options(${CHESS_NAME} PRIVATE "/ENTRY:mainCRTStartup")
endif()
