//
//  PLStream.m
//  Polaris
//
//  Created by Zachary Angelo on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PLStream.h"

@implementation PLStream

@synthesize frameRate = _frameRate;
@synthesize timeBase = _timeBase;
@synthesize frameDuration = _frameDuration;
@synthesize lumPixelBufferPool = _lumPixelBufferPool;
@synthesize chromPixelBufferPool = _chromPixelBufferPool;

@synthesize width = _width;
@synthesize height = _height;

- (void) copyFromAVStream:(AVStream *)avStream { 
    _frameRate = av_q2d(avStream->r_frame_rate);
    _timeBase = av_q2d(avStream->time_base);
    _frameDuration = 1 / _frameRate;
    
    _lumPixelBufferPool = nil;
}

- (id) initWithAVStream:(AVStream*)avStream { 
    self = [super init];
    
    if(self) { 
        [self copyFromAVStream:avStream];
        
        _lumPixelBufferPool = [[PLPixelBufferPool alloc] initWithPoolSize:24*4];
        _chromPixelBufferPool = [[PLPixelBufferPool alloc] initWithPoolSize:24*8];
    }
    
    return self;
}

- (void) updateStreamWidth:(int)width height:(int)height { 
    if(width != _width || height != _height) { 
        //TODO alloc new pool
    }
    
    _width = width;
    _height = height;
}

//- (void) allocateBufferPool:(size_t)bufferSize { 
//    NSLog(@"Allocating buffer pool...");
//    _pixelBufferPool = [[PLPixelBufferPool alloc] initWithPoolSize:24*4 bufferSize:bufferSize];
//}

@end
