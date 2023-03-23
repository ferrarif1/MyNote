cmake_minimum_required(VERSION 2.8.1)

project(EasyBitcoin)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++03")

include_directories(./include)

IF(${WIN32})
    link_directories(./lib)
ENDIF(${WIN32})

link_libraries(crypto)

file(GLOB SOURCE_FILES
    "*.cpp"
)

add_library(EasyBitcoin ${SOURCE_FILES})
add_executable(EasyBitcoinTests ${SOURCE_FILES} ./testing/main.cpp)
add_executable(EasyBitcoinScriptTests ${SOURCE_FILES} ./testing/script_test.cpp)