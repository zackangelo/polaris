//
//  PLBlockingQueue.h
//  Polaris
//
//  Created by Zachary Angelo on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    kNoWorkQueued = 0,
    kWorkQueued = 1
};

enum { 
    kQueueReady = 0,
    kQueueFull = 1
};


@interface PLBlockingQueue : NSObject  { 
    @private
    NSMutableArray *queue;
    
    NSConditionLock *queueLock;
    NSConditionLock *_writeLock;
    
    int _maxSize;
}

- (id) initWithSize:(int)maxSize;
- (id)dequeueNow;
//- (id)dequeueUntil:(NSDate *)timeoutDate;
- (void)queue:(id)unitOfWork;

@end
