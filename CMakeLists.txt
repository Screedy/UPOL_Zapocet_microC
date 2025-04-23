cmake_minimum_required(VERSION 3.27)
project(UPOL_Zapocet_microC)

set(CMAKE_CXX_STANDARD 20)

add_executable(UPOL_Zapocet_microC main.cpp
        mikroC.h mikroC.l mikroC.y mikroC.lex.cpp mikroC.tab.cpp mikroC.tab.hpp)
