cmake_minimum_required(VERSION 3.10)

project(HelloWorld)

add_executable(HelloWorld)

find_package(Boost REQUIRED)

target_link_libraries(HelloWorld PRIVATE ${Boost_LIBRARIES})

target_include_directories(HelloWorld PRIVATE ${Boost_INCLUDE_DIRS})

target_sources(HelloWorld PRIVATE hello_world.cpp)

