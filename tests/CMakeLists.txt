cmake_minimum_required(VERSION 3.10)

project(hello_world)

add_executable(hello_world)

target_sources(hello_world PRIVATE hello_world.cpp)

