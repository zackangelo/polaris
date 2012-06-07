//
//  PLFrame.m
//  Polaris
//
//  Created by Zachary Angelo on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PLFrame.h"
#import "PLStream.h"

@implementation PLFrame 

@synthesize timestamp = _timestamp;
@synthesize width = _width;
@synthesize height = _height;
@synthesize frameIndex = _frameIndex;
@synthesize stream = _stream;

//copies relevant and needed data out of libav frame data structure
- (void) copyAVFrameData:(AVFrame *)avFrame { 
    //copy data pointers
    for(int i=0;i<MAX_PLANES;i++) { 
        _linesizes[i] = avFrame->linesize[i] * 3;
    }
    
//    size_t pixBufSz = _linesizes[0] * avFrame->height;
//    _pixelBuffers[0] = malloc(pixBufSz);
//    memcpy(_pixelBuffers[0], avFrame->data[0], pixBufSz);
    
    //TODO width/height acquisition should be based on pixel format, but we'll just grab the 
    //first one for now because we know we're working with YUV
    _width = avFrame->linesize[0];
    _height = avFrame->height;
    
    _frameIndex = avFrame->display_picture_number;
    
    _timestamp = avFrame->pkt_pts * _stream.timeBase;
    
//    _pixelBuffers[0] = [self monoImageDataFromY:avFrame->data[0]];
    size_t yChanSize = avFrame->linesize[0] * _height;
    size_t uChanSize = avFrame->linesize[2] * (_height / 2);
    size_t vChanSize = avFrame->linesize[1] * (_height / 2);

    
    _pixelBuffers[0] = [_stream.lumPixelBufferPool requestBufferOfSize:yChanSize];
    _pixelBuffers[1] = [_stream.chromPixelBufferPool requestBufferOfSize:vChanSize];
    _pixelBuffers[2] = [_stream.chromPixelBufferPool requestBufferOfSize:uChanSize];
    
    memcpy(_pixelBuffers[0], avFrame->data[0], yChanSize);
    memcpy(_pixelBuffers[1], avFrame->data[2], vChanSize);
    memcpy(_pixelBuffers[2], avFrame->data[1], uChanSize);
}

- (id) initWithAVFrame:(AVFrame *)avFrame stream:(PLStream *)stream { 
    self = [super init];
    
    if(self) { 
        _stream = stream;
        [self copyAVFrameData:avFrame];
    }
    
    return self;
}

- (u_int8_t *)yImageData { 
    return _pixelBuffers[0];
}

- (u_int8_t *)uImageData { 
    return _pixelBuffers[2];
}

- (u_int8_t *)vImageData { 
    return _pixelBuffers[1];
}

//- (u_int8_t *)imageData { 
//    return _pixelBuffers[0];
//}

//- (u_int8_t *)monoImageDataFromY:(u_int8_t *)yBuf  { 
//    size_t yChanSize = self.width * self.height;
//    size_t sizeInBytes = yChanSize * 3; //(self.width * self.height * 3);
//    u_int8_t *imageBuf =  [_stream.pixelBufferPool requestBufferOfSize:sizeInBytes];//malloc(sizeInBytes); //
//    
//    if(!imageBuf) { 
//        NSLog(@"Couldn't obtain pixel buffer!");
//        return 0;
//    }
//    
//    int z = 0;
//    for(int i=0;i<yChanSize;i++) {
//        char yVal = yBuf[i];
//        imageBuf[z] = yVal;
//        imageBuf[z+1] = yVal;
//        imageBuf[z+2] = yVal;
//        
//        z += 3;
//    }
//    
//    return imageBuf;
//}

- (void) destroy { 
    [_stream.lumPixelBufferPool returnBuffer:_pixelBuffers[0]];
    [_stream.chromPixelBufferPool returnBuffer:_pixelBuffers[1]];
    [_stream.chromPixelBufferPool returnBuffer:_pixelBuffers[2]];
    
    _pixelBuffers[0] = NULL;
    _pixelBuffers[1] = NULL;
    _pixelBuffers[2] = NULL;
}

- (void) dealloc { 
}

@end
