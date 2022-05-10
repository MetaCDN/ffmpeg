/*
 * v408 decoder
 * Copyright (c) 2012 Carl Eugen Hoyos
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

#include "config_components.h"

#include "avcodec.h"
#include "codec_internal.h"
#include "internal.h"

static av_cold int v408_decode_init(AVCodecContext *avctx)
{
    avctx->pix_fmt = AV_PIX_FMT_YUVA444P;

    return 0;
}

static int v408_decode_frame(AVCodecContext *avctx, AVFrame *pic,
                             int *got_frame, AVPacket *avpkt)
{
    const uint8_t *src = avpkt->data;
    uint8_t *y, *u, *v, *a;
    int i, j, ret;

    if (avpkt->size < 4 * avctx->height * avctx->width) {
        av_log(avctx, AV_LOG_ERROR, "Insufficient input data.\n");
        return AVERROR(EINVAL);
    }

    if ((ret = ff_get_buffer(avctx, pic, 0)) < 0)
        return ret;

    pic->key_frame = 1;
    pic->pict_type = AV_PICTURE_TYPE_I;

    y = pic->data[0];
    u = pic->data[1];
    v = pic->data[2];
    a = pic->data[3];

    for (i = 0; i < avctx->height; i++) {
        for (j = 0; j < avctx->width; j++) {
            if (avctx->codec_id==AV_CODEC_ID_AYUV) {
                v[j] = *src++;
                u[j] = *src++;
                y[j] = *src++;
                a[j] = *src++;
            } else {
                u[j] = *src++;
                y[j] = *src++;
                v[j] = *src++;
                a[j] = *src++;
            }
        }

        y += pic->linesize[0];
        u += pic->linesize[1];
        v += pic->linesize[2];
        a += pic->linesize[3];
    }

    *got_frame = 1;

    return avpkt->size;
}

#if CONFIG_AYUV_DECODER
<<<<<<< HEAD
const FFCodec ff_ayuv_decoder = {
    .p.name       = "ayuv",
    .p.long_name  = NULL_IF_CONFIG_SMALL("Uncompressed packed MS 4:4:4:4"),
    .p.type       = AVMEDIA_TYPE_VIDEO,
    .p.id         = AV_CODEC_ID_AYUV,
=======
const AVCodec ff_ayuv_decoder = {
    .name         = "ayuv",
    .long_name    = NULL_IF_CONFIG_SMALL("Uncompressed packed MS 4:4:4:4"),
    .type         = AVMEDIA_TYPE_VIDEO,
    .id           = AV_CODEC_ID_AYUV,
>>>>>>> refs/remotes/origin/master
    .init         = v408_decode_init,
    FF_CODEC_DECODE_CB(v408_decode_frame),
    .p.capabilities = AV_CODEC_CAP_DR1,
    .caps_internal  = FF_CODEC_CAP_INIT_THREADSAFE,
};
#endif
#if CONFIG_V408_DECODER
<<<<<<< HEAD
const FFCodec ff_v408_decoder = {
    .p.name       = "v408",
    .p.long_name  = NULL_IF_CONFIG_SMALL("Uncompressed packed QT 4:4:4:4"),
    .p.type       = AVMEDIA_TYPE_VIDEO,
    .p.id         = AV_CODEC_ID_V408,
=======
const AVCodec ff_v408_decoder = {
    .name         = "v408",
    .long_name    = NULL_IF_CONFIG_SMALL("Uncompressed packed QT 4:4:4:4"),
    .type         = AVMEDIA_TYPE_VIDEO,
    .id           = AV_CODEC_ID_V408,
>>>>>>> refs/remotes/origin/master
    .init         = v408_decode_init,
    FF_CODEC_DECODE_CB(v408_decode_frame),
    .p.capabilities = AV_CODEC_CAP_DR1,
    .caps_internal  = FF_CODEC_CAP_INIT_THREADSAFE,
};
#endif
