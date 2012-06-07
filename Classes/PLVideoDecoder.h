//
//  PLDecoderThread.h
//  Polaris
//
//  Created by Zachary Angelo on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>

#include "PLVideoDecoderDelegate.h"

@class PLFrame;
@class PLPlaybackQueue;
@class PLStream;

@interface PLVideoDecoder : NSObject { 
    @private
    int _videoStreamIndex;
    PLPlaybackQueue *_frameQueue;
    PLStream *_stream;
    
    NSString *_url;
    
    NSThread *_videoDecoderThread;
    
    AVFormatContext *_pFormatCtx;
    AVCodecContext *_pCodecCtx;
    
    NSThread *_decoderThread;
    
    __weak id<PLVideoDecoderDelegate> _delegate;
}

+ (void) initialize;
- (id) init;

// Returns the next frame if it is ready to be played. 
- (PLFrame*) nextFrame;

- (void) stop;
- (void) playVideoAtUrl:(NSString*)url;
- (BOOL) isDecoding; 

@property(weak,nonatomic) id<PLVideoDecoderDelegate> delegate;

@end
