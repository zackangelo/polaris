//
//  PLDecoderThread.m
//  Polaris
//
//  Created by Zachary Angelo on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PLVideoDecoder.h"
#import "PLPlaybackQueue.h"
#import "PLVideoPlayer.h"
#import "PLStream.h"
#import "PLFrame.h"


void printLibAvError(int returnCode) { 
    static char err[256];
    av_strerror(returnCode, err, 256);
    NSLog(@"LibAV Error: %s",err);
}

@implementation PLVideoDecoder

@synthesize delegate = _delegate;

+ (void) initialize { 
    av_log_set_level(AV_LOG_DEBUG);    
    av_register_all();
    avformat_network_init();
}

- (id) init { 
    self = [super init];
    
    if(self) { 
        
    }
    
    return self;
}

- (BOOL) isDecoding { 
    return (_decoderThread != nil);
}

- (void) playVideoAtUrl:(NSString*)url { 
    if(_decoderThread) { 
        NSLog(@"Attempted to play with a thread already active.");
    } else { 
        NSLog(@"Loading video at URL %@",url);
        
        _url = url;
        [NSThread detachNewThreadSelector:@selector(setupDecoder) toTarget:self withObject:nil];
    }
}

- (void) stop { 
    if(_decoderThread) { 
        [_decoderThread cancel];
    } else { 
        NSLog(@"Attempted to stop a decoder with no thread active.");
    }
}

- (void) setupDecoder {
    int ret; 
    
    _decoderThread = [NSThread currentThread];
    
    _pFormatCtx = avformat_alloc_context();
    
//    char *movieUrl = "rtsp://video.vbar.com:1935/rtp-live/vb10k-vm2.stream";
    
    AVDictionary *opts = NULL;     
    av_dict_set(&opts, "rtsp_transport", "tcp", 0);     
    
    // Open video stream
    ret = avformat_open_input(&_pFormatCtx, [_url UTF8String], NULL, &opts);
    if(ret != 0) {
        printLibAvError(ret);
        return;
    }    
    
//    AVCodecContext *pCodecCtx = NULL;
    _videoStreamIndex = -1;
    
    //find the first video stream in this media
    for(int i=0;i<_pFormatCtx->nb_streams;i++) { 
        if(_pFormatCtx->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO) { 
            //            NSLog(@"Video stream is index: %i",i);
            _videoStreamIndex = i;
            break;
        }
    }
    
    //did we get one? 
    if(_videoStreamIndex == -1) { 
        NSLog(@"No video stream found.");
        return;
    }
    
    _pCodecCtx = _pFormatCtx->streams[_videoStreamIndex]->codec;
    
    AVCodec *pCodec = avcodec_find_decoder(_pCodecCtx->codec_id);
    
    if(pCodec == NULL) { 
        NSLog(@"Unsupported codec!");
    }

    ret = avcodec_open2(_pCodecCtx, pCodec, NULL);
    
    if(ret != 0) { 
        printLibAvError(ret);
        return;
    }
    
    AVStream *avStream = _pFormatCtx->streams[_videoStreamIndex];
    
    _stream = [[PLStream alloc] initWithAVStream:avStream];
    _frameQueue = [[PLPlaybackQueue alloc] initWithStream:_stream size:24*3];
    
    [self decode];
    
    _decoderThread = nil;
    NSLog(@"Decoder thread death imminent for URL %@",_url);
    
    _stream = nil;
    _frameQueue = nil;
    
    avcodec_close(_pCodecCtx);
    avformat_close_input(&_pFormatCtx);
    
    if(_delegate) { 
        dispatch_async(dispatch_get_main_queue(), ^{ 
            [_delegate videoDecoderDidStop:self];
        });
    }

}

- (void) decode { 
    AVPacket packet;    
    AVFrame *pFrame;
    pFrame = avcodec_alloc_frame();
    
    int gotPicture;
    
    double _frameCountStartTime = 0.0;
    int _framesLastSecond = 0;
    int _frameCount = 0;
    
    while(![_decoderThread isCancelled] && av_read_frame(_pFormatCtx, &packet) >= 0) { 
        double currentTime = CACurrentMediaTime();
        if(_framesLastSecond == 0) { 
            _frameCountStartTime = currentTime;
        }
        
//        av_pkt_dump_log2(pFormatCtx, AV_LOG_DEBUG, &packet, 0, avStream);
        if(packet.stream_index == _videoStreamIndex) {  //only decode video
            avcodec_decode_video2(_pCodecCtx, (AVFrame*)pFrame, &gotPicture, &packet);
        
            if(gotPicture) {
                PLFrame *plFrame = [[PLFrame alloc] initWithAVFrame:pFrame stream:_stream];
                
                //is this the first frame? 
                if(_frameCount++ == 0) { 
                    if(_delegate) { 
                        dispatch_async(dispatch_get_main_queue(), ^{ 
                            [_delegate videoDecoderDidStartPlaying:self];
                        });
                    }
                }
                
                //did the stream dimensions change? 
                if(plFrame.width != _stream.width || plFrame.height != _stream.height) { 
                    [_stream updateStreamWidth:plFrame.width height:plFrame.height];
                    
                    if(_delegate) { 
                        dispatch_async(dispatch_get_main_queue(), ^{ 
                            [_delegate videoDecoder:self didChangeWidth:plFrame.width height:plFrame.height];
                        });
                    }
                }
                
                [_frameQueue queueFrame:plFrame];
                
                _framesLastSecond++;
                
                if(currentTime - _frameCountStartTime > 1.0) { 
//                    NSLog(@"Decoder FPS: %i",_framesLastSecond);
                    _framesLastSecond = 0;
                }
            }
        }
        
        av_free_packet(&packet);
    }
    
    av_free(pFrame);
    pFrame = NULL;
}

// CALLED FROM PLAYER THREAD
- (PLFrame*) nextFrame { 
    if(_frameQueue) { 
        return [_frameQueue dequeueFrame];
    } else { 
        return nil;
    }
}


@end
