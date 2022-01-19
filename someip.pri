DATA_ENGINE_INTERFACE_SOMPIP_PATH = $$PWD/..
message("DATA_ENGINE_INTERFACE_SOMPIP_PATH = $${DATA_ENGINE_INTERFACE_SOMPIP_PATH}")

#DATA_ENGINE_INTERFACE_BOOST_PATH = $$PWD/../thirdparty/boost_1_76_0/boost/
#message("DATA_ENGINE_INTERFACE_BOOST_PATH = $${DATA_ENGINE_INTERFACE_BOOST_PATH}")

DEFINES += HAVE_PTHREAD

#QMAKE_CXXFLAGS += -DBOOST_ASIO_STATIC_CONSTEXPR

# 示例
#SOURCES_DIR_HEADER_FILES = $$files($$PWD/*.h)
#SOURCES_DIR_CPP_FILES = $$files($$PWD/*.cpp)
# files(pattern[, recursive=false])
# $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/endpoints/src/*.cpp)

#INCLUDEPATH += \
#    $${DATA_ENGINE_INTERFACE_BOOST_PATH}/ \
#    $${DATA_ENGINE_INTERFACE_BOOST_PATH}/asio/ \

#HEADERS += \
#    $$files($${DATA_ENGINE_INTERFACE_BOOST_PATH}/asio/*.hpp, true) \

#SOURCES += \
#    $$files($${DATA_ENGINE_INTERFACE_BOOST_PATH}/asio/*.cpp, true) \

INCLUDEPATH += \
    $${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/interface/ \
    $${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation \
    $${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/helper/1.74/ \

HEADERS += \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/interface/vsomeip/*.hpp, true) \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/interface/compat/*.hpp, true) \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/endpoints/include/*.hpp) \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/logger/include/*.hpp) \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/tracing/include/*.hpp) \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/message/include/*.hpp) \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/plugin/include/*.hpp) \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/routing/include/*.hpp) \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/runtime/include/*.hpp) \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/security/include/*.hpp) \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/utility/include/*.hpp) \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/configuration/include/*.hpp) \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/service_discovery/include/*.hpp) \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/helper/1.74/boost/*.hpp, true) \

SOURCES += \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/endpoints/src/*.cpp) \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/logger/src/*.cpp) \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/tracing/src/*.cpp) \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/message/src/*.cpp) \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/plugin/src/*.cpp) \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/routing/src/*.cpp) \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/runtime/src/*.cpp) \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/security/src/*.cpp) \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/utility/src/*.cpp) \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/configuration/src/*.cpp) \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/service_discovery/src/*.cpp) \
    $$files($${DATA_ENGINE_INTERFACE_SOMPIP_PATH}/thirdparty/vsomeip/implementation/helper/1.74/boost/*.cpp, true) \
