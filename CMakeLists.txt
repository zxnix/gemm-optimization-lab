cmake_minimum_required(VERSION 3.20)

project(GEMMOptimizationLab VERSION 0.1.0 LANGUAGES CXX)

find_package(Threads REQUIRED)

option(GEMM_ENABLE_SANITIZERS "Enable AddressSanitizer and UndefinedBehaviorSanitizer" OFF)
option(GEMM_ENABLE_THREAD_SANITIZER "Enable ThreadSanitizer" OFF)
set(GEMM_OPT_LEVEL "default" CACHE STRING "Optimization-level label recorded by benchmarks")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(GEMM_ENABLE_SANITIZERS AND GEMM_ENABLE_THREAD_SANITIZER)
    message(FATAL_ERROR "AddressSanitizer and ThreadSanitizer cannot be enabled together")
endif()

if(GEMM_ENABLE_SANITIZERS)
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        # 目录级选项必须在创建任何 target 前设置，确保核心静态库也被插桩。
        add_compile_options(-fsanitize=address,undefined -fno-omit-frame-pointer)
        add_link_options(-fsanitize=address,undefined)
    else()
        message(FATAL_ERROR "Sanitizers are supported only with GCC or Clang")
    endif()
endif()

if(GEMM_ENABLE_THREAD_SANITIZER)
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        add_compile_options(-fsanitize=thread -fno-omit-frame-pointer)
        add_link_options(-fsanitize=thread)
    else()
        message(FATAL_ERROR "ThreadSanitizer is supported only with GCC or Clang")
    endif()
endif()

add_library(gemm_baseline
    src/kernels/gemm_naive.cpp
    src/kernels/gemm_ikj.cpp
    src/kernels/gemm_blocked.cpp
    src/kernels/gemm_packed.cpp
    src/kernels/gemm_microkernel.cpp
    src/verification/verification.cpp
)
target_include_directories(gemm_baseline PUBLIC ${PROJECT_SOURCE_DIR}/include)
target_link_libraries(gemm_baseline PUBLIC Threads::Threads)
target_compile_options(gemm_baseline PRIVATE
    $<$<CXX_COMPILER_ID:GNU,Clang>:-Wall;-Wextra;-Wpedantic>
)

add_library(gemm_benchmark_support
    src/benchmark/benchmark_options.cpp
    src/benchmark/benchmark_output.cpp
    src/benchmark/benchmark_runner.cpp
    src/benchmark/benchmark_statistics.cpp
    src/benchmark/kernel_registry.cpp
)
target_include_directories(gemm_benchmark_support PUBLIC
    ${PROJECT_SOURCE_DIR}/src/benchmark
)
target_link_libraries(gemm_benchmark_support PUBLIC gemm_baseline)
target_compile_options(gemm_benchmark_support PRIVATE
    $<$<CXX_COMPILER_ID:GNU,Clang>:-Wall;-Wextra;-Wpedantic;-Wswitch-enum>
)
target_compile_definitions(gemm_benchmark_support PRIVATE
    GEMM_BUILD_TYPE="${CMAKE_BUILD_TYPE}"
    GEMM_COMPILER_ID="${CMAKE_CXX_COMPILER_ID}"
    GEMM_COMPILER_VERSION="${CMAKE_CXX_COMPILER_VERSION}"
    GEMM_OPT_LEVEL="${GEMM_OPT_LEVEL}"
)

add_executable(gemm_benchmark
    src/benchmark/benchmark_main.cpp
)
target_link_libraries(gemm_benchmark PRIVATE gemm_benchmark_support)
target_compile_options(gemm_benchmark PRIVATE
    $<$<CXX_COMPILER_ID:GNU,Clang>:-Wall;-Wextra;-Wpedantic>
)

include(CTest)
if(BUILD_TESTING)
    add_executable(gemm_tests tests/test_gemm.cpp)
    target_link_libraries(gemm_tests PRIVATE gemm_baseline)
    add_test(NAME gemm_correctness COMMAND gemm_tests)

    add_executable(gemm_kernel_registry_tests tests/test_kernel_registry.cpp)
    target_link_libraries(
        gemm_kernel_registry_tests PRIVATE gemm_benchmark_support)
    target_compile_options(gemm_kernel_registry_tests PRIVATE
        $<$<CXX_COMPILER_ID:GNU,Clang>:-Wall;-Wextra;-Wpedantic;-Wswitch-enum>
    )
    add_test(NAME gemm_kernel_registry COMMAND gemm_kernel_registry_tests)

    add_executable(
        gemm_benchmark_options_tests tests/test_benchmark_options.cpp)
    target_link_libraries(
        gemm_benchmark_options_tests PRIVATE gemm_benchmark_support)
    target_compile_options(gemm_benchmark_options_tests PRIVATE
        $<$<CXX_COMPILER_ID:GNU,Clang>:-Wall;-Wextra;-Wpedantic>
    )
    add_test(
        NAME gemm_benchmark_options COMMAND gemm_benchmark_options_tests)
endif()
