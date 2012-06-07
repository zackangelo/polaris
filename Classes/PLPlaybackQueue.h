//
//  PLPlaybackQueue.h
//  Polaris
//
//  Created by Zachary Angelo on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLBlockingQueue.h"
#import "PLStream.h"

@class PLFrame;

@interface PLPlaybackQueue : NSObject { 
    @private
    PLBlockingQueue *_queue;
    PLStream *_stream;
    int _size;
    
    PLFrame *_nextFrameToPlay;
    double _nextFramePlaysAt;
    
    PLFrame *_lastFramePlayed;
    double _lastFramePlayedAt;
    
    double _frameClock;
    double _frameClockRef;
    double _frameClockLastDequeue;
}

- (id) initWithStream:(PLStream *)stream size:(int)size;
- (PLFrame *) dequeueFrame;
- (void) queueFrame:(PLFrame *)plFrame;


@end
