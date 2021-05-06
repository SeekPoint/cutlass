/***************************************************************************************************
 * Copyright (c) 2017-2021, NVIDIA CORPORATION.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted
 * provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright notice, this list of
 *       conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright notice, this list of
 *       conditions and the following disclaimer in the documentation and/or other materials
 *       provided with the distribution.
 *     * Neither the name of the NVIDIA CORPORATION nor the names of its contributors may be used
 *       to endorse or promote products derived from this software without specific prior written
 *       permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL NVIDIA CORPORATION BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TOR (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 **************************************************************************************************/

#include "b2b_conv2d_fprop_implicit_gemm_s8ncxhwx_s8cxrskx_s8ncxhwx_tensor_op_s32_sm75.h"
#include "b2b_conv2d_fprop_implicit_gemm_s8ncxhwx_s8cxrskx_s8ncxhwx_tensor_op_s32_sm80.h"
#include "b2b_conv2d_fprop_implicit_gemm_f16nhwc_f16nhwc_f16nhwc_tensor_op_f16_sm75.h"
#include "b2b_conv2d_fprop_implicit_gemm_f16nhwc_f16nhwc_f16nhwc_tensor_op_f16_sm80.h"

int run() {

  cudaDeviceProp props;

  cudaError_t error = cudaGetDeviceProperties(&props, 0);
  if (error != cudaSuccess) {
    std::cerr << "cudaGetDeviceProperties() returned an error: " << cudaGetErrorString(error) << std::endl;
    return -1;
  }

  if (!(props.major * 10 + props.minor >= 75)) {
    std::cerr << "Turing Tensor Ops must be run on a machine with compute capability at least 75."
              << std::endl;

    // Returning zero so this test passes on older Toolkits. Its actions are no-op.
    return 0;
  }

#if defined(CUTLASS_ARCH_MMA_SM80_SUPPORTED)
  std::cout << "Running on SM80" << std::endl;
  run_nonfused_conv2d_fprop_optimized_f16_sm80();
  run_fused_conv2d_fprop_optimized_f16_sm80();
  run_nonfused_conv2d_fprop_optimized_s8_sm80();
  run_fused_conv2d_fprop_optimized_s8_sm80();
#elif defined(CUTLASS_ARCH_MMA_SM75_SUPPORTED)
  std::cout << "Running on SM75" << std::endl;
  run_nonfused_conv2d_fprop_optimized_f16_sm75();
  run_fused_conv2d_fprop_optimized_f16_sm75();
  run_nonfused_conv2d_fprop_optimized_s8_sm75();
  run_fused_conv2d_fprop_optimized_s8_sm75();
#endif

  return 0;
}

int main() {

  bool notSupported = false;

  // Turing Tensor Core operations exposed with mma.sync are first available in CUDA 10.2.
  //
  // CUTLASS must be compiled with CUDA 10.2 Toolkit to run these examples.
  if (!(__CUDACC_VER_MAJOR__ > 10 || (__CUDACC_VER_MAJOR__ == 10 && __CUDACC_VER_MINOR__ >= 2))) {
    std::cerr << "Tensor Core operations used in this example must be compiled with CUDA 10.2 Toolkit or later." << std::endl;

    notSupported = true;

  }

  cudaDeviceProp props;

  cudaError_t error = cudaGetDeviceProperties(&props, 0);
  if (error != cudaSuccess) {
    std::cerr << "cudaGetDeviceProperties() returned an error: " << cudaGetErrorString(error) << std::endl;
    return -1;
  }

  if (!(props.major * 10 + props.minor >= 75)) {
    std::cerr << "Tensor Ops used in this example must be run on a machine with compute capability at least 75."
              << std::endl;

    notSupported = true;
  }

  if (notSupported) {
    // Returning zero so this test passes on older Toolkits. Its actions are no-op.
    return 0;
  }
    
  return run();
}
