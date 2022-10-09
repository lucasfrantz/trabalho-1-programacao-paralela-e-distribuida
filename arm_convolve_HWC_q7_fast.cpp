/*
 * Copyright (C) 2010-2018 Arm Limited or its affiliates. All rights reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Licensed under the Apache License, Version 2.0 (the License); you may
 * not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an AS IS BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* ----------------------------------------------------------------------
 * Project:      CMSIS NN Library
 * Title:        arm_convolve_HWC_q7_fast.c
 * Description:  Fast Q7 version of convolution
 *
 * $Date:        17. January 2018
 * $Revision:    V.1.0.0
 *
 * Target Processor:  Cortex-M cores
 *
 * -------------------------------------------------------------------- */
#include <omp.h>
#include <stdint.h>
#include <stdio.h>
#include "arm_math.h"
#include "arm_nnfunctions.h"

// int NUM_THREADS = 1;

/**
 *  @ingroup groupNN
 */

/**
 * @addtogroup NNConv
 * @{
 */

  /**
   * @brief Fast Q7 convolution function
   * @param[in]       Im_in       pointer to input tensor
   * @param[in]       dim_im_in   input tensor dimention
   * @param[in]       ch_im_in    number of input tensor channels
   * @param[in]       wt          pointer to kernel weights
   * @param[in]       ch_im_out   number of filters, i.e., output tensor channels
   * @param[in]       dim_kernel  filter kernel size
   * @param[in]       padding     padding sizes
   * @param[in]       stride      convolution stride
   * @param[in]       bias        pointer to bias
   * @param[in]       bias_shift  amount of left-shift for bias
   * @param[in]       out_shift   amount of right-shift for output
   * @param[in,out]   Im_out      pointer to output tensor
   * @param[in]       dim_im_out  output tensor dimension
   * @param[in,out]   bufferA     pointer to buffer space for input
   * @param[in,out]   bufferB     pointer to buffer space for output
   * @return     The function returns either
   * <code>ARM_MATH_SIZE_MISMATCH</code> or <code>ARM_MATH_SUCCESS</code> based on the outcome of size checking.
   *
   * @details
   *
   * <b>Buffer size:</b>
   *
   * bufferA size: 2*ch_im_in*dim_kernel*dim_kernel
   *
   * bufferB size: 0
   *
   * <b>Input dimension constraints:</b>
   *
   * ch_im_in is multiple of 4    ( because of the SIMD32 read and swap )
   *
   * ch_im_out is multipe of 2    ( bacause 2x2 mat_mult kernel )
   *
   * The im2col converts the Q7 tensor input into Q15 column, which is stored in
   * bufferA. There is reordering happenning during this im2col process with
   * arm_q7_to_q15_reordered_no_shift. For every four elements, the second and
   * third elements are swapped.
   *
   * The computation kernel arm_nn_mat_mult_kernel_q7_q15_reordered does the
   * GEMM computation with the reordered columns.
   *
   * To speed-up the determination of the padding condition, we split the
   * computation into 3x3 parts, i.e., {top, mid, bottom} X {left, mid, right}.
   * This reduces the total number of boundary condition checks and improves
   * the data copying performance.
   */

arm_status
arm_convolve_HWC_q7_fast(const q7_t * Im_in,
                         const uint16_t dim_im_in,
                         const uint16_t ch_im_in,
                         const q7_t * wt,
                         const uint16_t ch_im_out,
                         const uint16_t dim_kernel,
                         const uint16_t padding,
                         const uint16_t stride,
                         const q7_t * bias,
                         const uint16_t bias_shift,
                         const uint16_t out_shift,
                         q7_t * Im_out,
                         const uint16_t dim_im_out,
                         q15_t * bufferA,
                         q7_t * bufferB)
{
    (void)bufferB;
    /* Run the following code as reference implementation for Cortex-M0 and Cortex-M3 */

    uint16_t  i, j, k, l, m, n;
    int       conv_out;
    signed char in_row, in_col;

    if (ch_im_in % 4 != 0 || ch_im_out % 2 != 0)
    {
        /* check if the input dimension meets the constraints */
        return ARM_MATH_SIZE_MISMATCH;
    }

    int n_thread = int(NUM_THREADS);
// int n_thread = NUM_THREADS, tid = -1;
    int tid = -1;
    int ch_im_out_p = ch_im_out/n_thread;
    int dim_im_in_p = dim_im_in/n_thread;
    int dim_im_out_p = dim_im_out/n_thread;
    int dim_kernel_p = dim_kernel/n_thread;
    int ch_im_in_p = ch_im_in/n_thread;
    #pragma omp parallel if(n_thread >= 1) num_threads(n_thread) default(shared) private(tid, i, j, k, in_row, in_col, conv_out, n, l) \
                                                    shared(n_thread, ch_im_out, dim_im_out, bias, bias_shift, out_shift, dim_kernel, stride, padding, \
                                                    dim_im_in, ch_im_in, Im_in, Im_out)
    {
        tid = omp_get_thread_num();


        for (i = ch_im_out_p * tid; i < ch_im_out; i++)
        {
            for (j = dim_im_out_p * tid; j < dim_im_out; j++)
            {
                for (k = dim_im_out_p * tid; k < dim_im_out; k++)
                {
                    conv_out = (bias[i] << bias_shift) + NN_ROUND(out_shift);
                    for (m = dim_kernel_p * tid; m < dim_kernel; m++)
                    {
                        for (n = dim_kernel_p * tid; n < dim_kernel; n++)
                        {
                            // if-for implementation
                            in_row = stride * j + m - padding;
                            in_col = stride * k + n - padding;
                            if (in_row >= 0 && in_col >= 0 && in_row < dim_im_in_p && in_col < dim_im_in_p)
                            {
                                for (l = ch_im_in_p * tid; l < ch_im_in_p; l++)
                                {
                                    conv_out +=
                                        Im_in[(in_row * dim_im_in_p + in_col) * ch_im_in_p +
                                            l] * wt[i * ch_im_in_p * dim_kernel_p * dim_kernel_p + (m * dim_kernel_p +
                                                                                                n) * ch_im_in_p + l];
                                }
                            }
                        }
                    }
                    Im_out[i + (j * dim_im_out_p + k) * ch_im_out_p] = (q7_t) __SSAT((conv_out >> out_shift), 8);
                }
            }
        }
    }

    /* Return to application */
    return ARM_MATH_SUCCESS;
}

/**
 * @} end of NNConv group
 */
