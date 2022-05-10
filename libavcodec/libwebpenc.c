/*
 * WebP encoding support via libwebp
 * Copyright (c) 2013 Justin Ruggles <justin.ruggles@gmail.com>
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

/**
 * @file
 * WebP encoder using libwebp (WebPEncode API)
 */

<<<<<<< HEAD
#include "codec_internal.h"
=======
>>>>>>> refs/remotes/origin/master
#include "encode.h"
#include "libwebpenc_common.h"

typedef LibWebPContextCommon LibWebPContext;

static av_cold int libwebp_encode_init(AVCodecContext *avctx)
{
    return ff_libwebp_encode_init_common(avctx);
}

static int libwebp_encode_frame(AVCodecContext *avctx, AVPacket *pkt,
                                const AVFrame *frame, int *got_packet)
{
    LibWebPContext *s  = avctx->priv_data;
    WebPPicture *pic = NULL;
    AVFrame *alt_frame = NULL;
    WebPMemoryWriter mw = { 0 };

    int ret = ff_libwebp_get_frame(avctx, s, frame, &alt_frame, &pic);
    if (ret < 0)
        goto end;

    WebPMemoryWriterInit(&mw);
    pic->custom_ptr = &mw;
    pic->writer     = WebPMemoryWrite;

    ret = WebPEncode(&s->config, pic);
    if (!ret) {
        av_log(avctx, AV_LOG_ERROR, "WebPEncode() failed with error: %d\n",
               pic->error_code);
        ret = ff_libwebp_error_to_averror(pic->error_code);
        goto end;
    }

    ret = ff_get_encode_buffer(avctx, pkt, mw.size, 0);
    if (ret < 0)
        goto end;
    memcpy(pkt->data, mw.mem, mw.size);

    *got_packet = 1;

end:
#if (WEBP_ENCODER_ABI_VERSION > 0x0203)
    WebPMemoryWriterClear(&mw);
#else
    free(mw.mem); /* must use free() according to libwebp documentation */
#endif
    WebPPictureFree(pic);
    av_freep(&pic);
    av_frame_free(&alt_frame);

    return ret;
}

static int libwebp_encode_close(AVCodecContext *avctx)
{
    LibWebPContextCommon *s  = avctx->priv_data;
    av_frame_free(&s->ref);

    return 0;
}

<<<<<<< HEAD
const FFCodec ff_libwebp_encoder = {
    .p.name         = "libwebp",
    .p.long_name    = NULL_IF_CONFIG_SMALL("libwebp WebP image"),
    .p.type         = AVMEDIA_TYPE_VIDEO,
    .p.id           = AV_CODEC_ID_WEBP,
    .p.capabilities = AV_CODEC_CAP_DR1,
    .p.pix_fmts     = ff_libwebpenc_pix_fmts,
    .p.priv_class   = &ff_libwebpenc_class,
    .p.wrapper_name = "libwebp",
=======
const AVCodec ff_libwebp_encoder = {
    .name           = "libwebp",
    .long_name      = NULL_IF_CONFIG_SMALL("libwebp WebP image"),
    .type           = AVMEDIA_TYPE_VIDEO,
    .id             = AV_CODEC_ID_WEBP,
    .capabilities   = AV_CODEC_CAP_DR1,
    .pix_fmts       = ff_libwebpenc_pix_fmts,
    .priv_class     = &ff_libwebpenc_class,
>>>>>>> refs/remotes/origin/master
    .priv_data_size = sizeof(LibWebPContext),
    .defaults       = ff_libwebp_defaults,
    .init           = libwebp_encode_init,
    FF_CODEC_ENCODE_CB(libwebp_encode_frame),
    .close          = libwebp_encode_close,
<<<<<<< HEAD
=======
    .wrapper_name   = "libwebp",
>>>>>>> refs/remotes/origin/master
};
