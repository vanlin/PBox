
add_library(Qt5::QSGD3D12Adaptation MODULE IMPORTED)

set(_Qt5QSGD3D12Adaptation_MODULE_DEPENDENCIES "Quick;Quick;Quick;Gui;Gui;Qml;Core;Core")

foreach(_module_dep ${_Qt5QSGD3D12Adaptation_MODULE_DEPENDENCIES})
    if(NOT Qt5${_module_dep}_FOUND)
        find_package(Qt5${_module_dep}
             ${_Qt5Quick_FIND_VERSION_EXACT}
            ${_Qt5Quick_DEPENDENCIES_FIND_QUIET}
            ${_Qt5Quick_FIND_DEPENDENCIES_REQUIRED}
            PATHS "${CMAKE_CURRENT_LIST_DIR}/.." NO_DEFAULT_PATH
        )
    endif()
endforeach()

_qt5_Quick_process_prl_file(
    "${_qt5Quick_install_prefix}/plugins/scenegraph/qsgd3d12backend.prl" RELEASE
    _Qt5QSGD3D12Adaptation_STATIC_RELEASE_LIB_DEPENDENCIES
    _Qt5QSGD3D12Adaptation_STATIC_RELEASE_LINK_FLAGS
)


set_property(TARGET Qt5::QSGD3D12Adaptation PROPERTY INTERFACE_SOURCES
    "${CMAKE_CURRENT_LIST_DIR}/Qt5Quick_QSGD3D12Adaptation_Import.cpp"
)

_populate_Quick_plugin_properties(QSGD3D12Adaptation RELEASE "scenegraph/qsgd3d12backend.lib" FALSE)

list(APPEND Qt5Quick_PLUGINS Qt5::QSGD3D12Adaptation)
set_property(TARGET Qt5::Quick APPEND PROPERTY QT_ALL_PLUGINS_scenegraph Qt5::QSGD3D12Adaptation)
# $<GENEX_EVAL:...> wasn't added until CMake 3.12, so put a version guard around it
if(CMAKE_VERSION VERSION_LESS "3.12")
    set(_manual_plugins_genex "$<TARGET_PROPERTY:QT_PLUGINS>")
    set(_plugin_type_genex "$<TARGET_PROPERTY:QT_PLUGINS_scenegraph>")
    set(_no_plugins_genex "$<TARGET_PROPERTY:QT_NO_PLUGINS>")
else()
    set(_manual_plugins_genex "$<GENEX_EVAL:$<TARGET_PROPERTY:QT_PLUGINS>>")
    set(_plugin_type_genex "$<GENEX_EVAL:$<TARGET_PROPERTY:QT_PLUGINS_scenegraph>>")
    set(_no_plugins_genex "$<GENEX_EVAL:$<TARGET_PROPERTY:QT_NO_PLUGINS>>")
endif()
set(_user_specified_genex
    "$<IN_LIST:Qt5::QSGD3D12Adaptation,${_manual_plugins_genex};${_plugin_type_genex}>"
)
set(_user_specified_genex_versionless
    "$<IN_LIST:Qt::QSGD3D12Adaptation,${_manual_plugins_genex};${_plugin_type_genex}>"
)
string(CONCAT _plugin_genex
    "$<$<OR:"
        # Add this plugin if it's in the list of manually specified plugins or in the list of
        # explicitly included plugin types.
        "${_user_specified_genex},"
        "${_user_specified_genex_versionless},"
        # Add this plugin if all of the following are true:
        # 1) the list of explicitly included plugin types is empty
        # 2) the QT_PLUGIN_EXTENDS property for the plugin is empty or equal to the current
        #    module name
        # 3) the user hasn't explicitly excluded the plugin.
        "$<AND:"
            "$<STREQUAL:${_plugin_type_genex},>,"
            "$<OR:"
                # FIXME: The value of CMAKE_MODULE_NAME seems to be wrong (e.g for Svg plugin
                # it should be Qt::Svg instead of Qt::Gui).
                "$<STREQUAL:$<TARGET_PROPERTY:Qt5::QSGD3D12Adaptation,QT_PLUGIN_EXTENDS>,Qt::Quick>,"
                "$<STREQUAL:$<TARGET_PROPERTY:Qt5::QSGD3D12Adaptation,QT_PLUGIN_EXTENDS>,>"
            ">,"
            "$<NOT:$<IN_LIST:Qt5::QSGD3D12Adaptation,${_no_plugins_genex}>>,"
            "$<NOT:$<IN_LIST:Qt::QSGD3D12Adaptation,${_no_plugins_genex}>>"
        ">"
    ">:Qt5::QSGD3D12Adaptation>"
)
set_property(TARGET Qt5::Quick APPEND PROPERTY INTERFACE_LINK_LIBRARIES
    ${_plugin_genex}
)
set_property(TARGET Qt5::QSGD3D12Adaptation APPEND PROPERTY INTERFACE_LINK_LIBRARIES
    "Qt5::Quick;Qt5::Quick;Qt5::Quick;Qt5::Gui;Qt5::Gui;Qt5::Qml;Qt5::Core;Qt5::Core"
)
set_property(TARGET Qt5::QSGD3D12Adaptation PROPERTY QT_PLUGIN_TYPE "scenegraph")
set_property(TARGET Qt5::QSGD3D12Adaptation PROPERTY QT_PLUGIN_EXTENDS "")
set_property(TARGET Qt5::QSGD3D12Adaptation PROPERTY QT_PLUGIN_CLASS_NAME "QSGD3D12Adaptation")
