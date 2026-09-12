cmake_minimum_required(VERSION 3.20)

project(GEMMOptimizationLab VERSION 0.1.0 LANGUAGES CXX)

option(GEMM_ENABLE_SANITIZERS "Enable AddressSanitizer and UndefinedBehaviorSanitizer" OFF)
set(GEMM_OPT_LEVEL "default" CACHE STRING "Optimization-level label recorded by benchmarks")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(GEMM_ENABLE_SANITIZERS)
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        # 目录级选项必须在创建任何 target 前设置，确保核心静态库也被插桩。
        add_compile_options(-fsanitize=address,undefined -fno-omit-frame-pointer)
        add_link_options(-fsanitize=address,undefined)
    else()
        message(FATAL_ERROR "Sanitizers are supported only with GCC or Clang")
    endif()
endif()

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
target_compile_definitions(gemm_benchmark PRIVATE
    GEMM_BUILD_TYPE="${CMAKE_BUILD_TYPE}"
    GEMM_COMPILER_ID="${CMAKE_CXX_COMPILER_ID}"
    GEMM_COMPILER_VERSION="${CMAKE_CXX_COMPILER_VERSION}"
    GEMM_OPT_LEVEL="${GEMM_OPT_LEVEL}"
)

include(CTest)
if(BUILD_TESTING)
    add_executable(gemm_tests tests/test_gemm.cpp)
    target_link_libraries(gemm_tests PRIVATE gemm_baseline)
    add_test(NAME gemm_correctness COMMAND gemm_tests)
endif()
