//
//  PLPlaybackQueue.m
//  Polaris
//
//  Created by Zachary Angelo on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PLPlaybackQueue.h"

#import "PLFrame.h"
#import "PLBlockingQueue.h"

#import <QuartzCore/QuartzCore.h>

@implementation PLPlaybackQueue 

- (id) initWithStream:(PLStream *)stream size:(int)size { 
    self = [super init];
    
    if(self) { 
        _size = size;
        _stream = stream;
        
        _nextFrameToPlay = nil;
        _nextFramePlaysAt = 0.0;
        _lastFramePlayed = nil;
        _lastFramePlayedAt = 0.0;
        
        _frameClock = 0.0;
        
        _queue = [[PLBlockingQueue alloc] initWithSize:size];
    }
    
    return self;
}

- (PLFrame*) dequeueFrame {
    double currentTime = CACurrentMediaTime();
    
    if(_frameClockLastDequeue > 0.0) 
        _frameClock += currentTime - _frameClockLastDequeue;
    
    _frameClockLastDequeue = currentTime;
    
//    NSLog(@"Frame clock: %f",_frameClock);
    
    if(_nextFrameToPlay == nil) { 
        _nextFrameToPlay = [_queue dequeueNow];
    }
    
    if(_nextFrameToPlay != nil) { 
//        NSLog(@"Next frame TS: %f",_nextFrameToPlay.timestamp);
        if(_frameClock >= _nextFrameToPlay.timestamp) { 
            PLFrame *f = _nextFrameToPlay;
            _nextFrameToPlay = nil;
            
            return f;
        }
    }
    
    return nil;
}

//// Returns a frame if one is ready to be played
//- (PLFrame *) dequeueFrame { 
////    return [_queue dequeueNow];
//    double currentTime = CACurrentMediaTime();
//    
//    //let's take a look at the next frame if we don't have it already
//    if(_nextFrameToPlay == nil) { 
//        _nextFrameToPlay = [_queue dequeueNow];
//        
//        if(!_lastFramePlayed) { 
//            _nextFramePlaysAt = 0.0; //play immediately if we haven't played a frame
//        } else { 
//            _nextFramePlaysAt = _lastFramePlayedAt + (_nextFrameToPlay.timestamp - _lastFramePlayed.timestamp);
//        }
//    }
//    
//    if(_nextFrameToPlay != nil) {
////        NSLog(@"cur: %f, next_at: %f",currentTime,_nextFramePlaysAt);
//        if(currentTime > _nextFramePlaysAt) {
////            NSLog(@"Frame accuracy: %f ms",(currentTime - _nextFramePlaysAt) * 1000);
//            
//           _lastFramePlayed = _nextFrameToPlay;
//            _nextFrameToPlay = nil;
//            _lastFramePlayedAt = CACurrentMediaTime();
//            return _lastFramePlayed;
//        } else { 
//            NSLog(@"have frame, waiting.");
//        }
//    } 
//    
//    return nil;
//}

- (void) queueFrame:(PLFrame *)plFrame { 
    [_queue queue:plFrame];
}

@end
