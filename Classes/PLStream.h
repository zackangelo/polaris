//
//  PLStream.h
//  Polaris
//
//  Created by Zachary Angelo on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <libavcodec/avcodec.h>
#import <libavformat/avformat.h>

#import "PLPixelBufferPool.h"

enum { 
    kStreamTypeVideo,
    kStreamTypeAudio
};

@interface PLStream : NSObject { 
    @private
    double _frameRate;
    double _timeBase;
    double _frameDuration;
    
    //current width and height
    int _width;
    int _height;
    
    PLPixelBufferPool *_lumPixelBufferPool;
    PLPixelBufferPool *_chromPixelBufferPool;
}

@property(nonatomic,readonly) double frameRate; //frameRate in frames per second
@property(nonatomic,readonly) double timeBase;  //units used in pts values
@property(nonatomic,readonly) double frameDuration; //frame duration in seconds
@property(readonly,nonatomic) int width;
@property(readonly,nonatomic) int height;

- (id) initWithAVStream:(AVStream*)avStream;

- (void) updateStreamWidth:(int)width height:(int)height;

@property(readonly,nonatomic) PLPixelBufferPool* lumPixelBufferPool;
@property(readonly,nonatomic) PLPixelBufferPool* chromPixelBufferPool;

@end
