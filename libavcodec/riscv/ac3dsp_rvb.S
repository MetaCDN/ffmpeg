/*
 * Copyright © 2023 Rémi Denis-Courmont.
 *
 * This file is part of FFmpeg.
 *
 * FFmpeg is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * FFmpeg is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with FFmpeg; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

<<<<<<<< HEAD:libavcodec/riscv/ac3dsp_rvb.S
#include "config.h"
#include "libavutil/riscv/asm.S"

func ff_extract_exponents_rvb, zbb
1:
        lw       t0, (a1)
        addi     a0, a0, 1
        neg      t1, t0
        addi     a1, a1, 4
        max      t0, t0, t1
        addi     a2, a2, -1
        clz      t0, t0
        addi     t0, t0, 24 - __riscv_xlen
        sb       t0, -1(a0)
        bgtz    a2, 1b
========
#include "libavutil/riscv/asm.S"

func ff_llvid_add_bytes_rvv, zve32x
1:
        vsetvli t0, a2, e8, m8, ta, ma
        vle8.v  v0, (a1)
        sub     a2, a2, t0
        vle8.v  v8, (a0)
        add     a1, t0, a1
        vadd.vv v8, v0, v8
        vse8.v  v8, (a0)
        add     a0, t0, a0
        bnez    a2, 1b
>>>>>>>> 0a87bd02ee6c22384961c68ca4a97f9981043885:libavcodec/riscv/llviddsp_rvv.S

        ret
endfunc
