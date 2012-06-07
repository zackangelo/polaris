//
//  PLFrame.h
//  Polaris
//
//  Created by Zachary Angelo on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <libavformat/avformat.h>
#import <libavcodec/avcodec.h>

@class PLStream;

#define MAX_PLANES AV_NUM_DATA_POINTERS

@interface PLFrame : NSObject { 
    @private
//    AVFrame *_avFrame;
    PLStream *_stream;
    
    int _width,_height; //dimensions in pixels
    double _timestamp;  //frame offset in seconds
    
    int _frameIndex;    
    
    u_int8_t *_pixelBuffers[MAX_PLANES];
    int _linesizes[MAX_PLANES];
}

- (id) initWithAVFrame:(AVFrame *)avFrame stream:(PLStream*)stream;

//- (CGImageRef) createCGImage;

- (void) destroy;

@property(nonatomic,readonly) int width;
@property(nonatomic,readonly) int height;
@property(nonatomic,readonly) int frameIndex;
@property(nonatomic,readonly) PLStream *stream;
@property(assign,nonatomic) double timestamp;
@property(nonatomic,readonly) u_int8_t *yImageData;
@property(nonatomic,readonly) u_int8_t *uImageData;
@property(nonatomic,readonly) u_int8_t *vImageData;


@end
