cmake_minimum_required(VERSION 3.10)

project(hello_world)

add_executable(hello_world)

find_package(Boost REQUIRED)

target_link_libraries(hello_world PRIVATE ${Boost_LIBRARIES})

target_include_directories(hello_world PRIVATE ${Boost_INCLUDE_DIRS})

target_sources(hello_world PRIVATE hello_world.cpp)

