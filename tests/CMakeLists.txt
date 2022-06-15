cmake_minimum_required(VERSION 3.10)

project(hello_world)

add_executable(hello_world)

find_package(Boost REQUIRED COMPONENTS headers)

target_link_libraries(hello_world PRIVATE Boost::headers)

target_sources(hello_world PRIVATE hello_world.cpp)

