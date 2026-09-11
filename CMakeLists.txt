cmake_minimum_required(VERSION 3.20)

project(GEMMOptimizationLab VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_library(gemm_baseline
    src/gemm_naive.cpp
    src/verification.cpp
)
target_include_directories(gemm_baseline PUBLIC ${PROJECT_SOURCE_DIR}/include)
target_compile_options(gemm_baseline PRIVATE
    $<$<CXX_COMPILER_ID:GNU,Clang>:-Wall;-Wextra;-Wpedantic>
)

add_executable(gemm_benchmark src/main.cpp)
target_link_libraries(gemm_benchmark PRIVATE gemm_baseline)

include(CTest)
if(BUILD_TESTING)
    add_executable(gemm_tests tests/test_gemm.cpp)
    target_link_libraries(gemm_tests PRIVATE gemm_baseline)
    add_test(NAME gemm_correctness COMMAND gemm_tests)
endif()
