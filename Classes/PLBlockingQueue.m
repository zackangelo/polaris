//
//  PLBlockingQueue.m
//  Polaris
//
//  Created by Zachary Angelo on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PLBlockingQueue.h"

@implementation PLBlockingQueue

- (id) initWithSize:(int)maxSize { 
    self = [super init];
    
    if(self) { 
        queue = [[NSMutableArray alloc] init];
        queueLock = [[NSConditionLock alloc] initWithCondition:kNoWorkQueued];
        
        _writeLock = [[NSConditionLock alloc] initWithCondition:kQueueReady];
        _maxSize = maxSize;
    }
    
    return self;
}

- (void) dealloc { 
    queue = nil;
    queueLock = nil;
}

- (id)dequeueNow { 
    id unitOfWork = nil;
    
    [queueLock lock];

    if([queue count]) { 
        unitOfWork = [queue objectAtIndex:0];
        [queue removeObjectAtIndex:0];
    } 
    
    [queueLock unlockWithCondition:kQueueReady];

    return unitOfWork;
}

//- (id)dequeueUntil:(NSDate *)timeoutDate { 
//    id unitOfWork = nil;
//    
//    if ([queueLock lockWhenCondition:kWorkQueued beforeDate:timeoutDate]) {
//        unitOfWork = [queue objectAtIndex:0];
//        [queue removeObjectAtIndex:0];
//        [queueLock unlockWithCondition:([queue count] ? kWorkQueued : kNoWorkQueued)];
//    }
//    
//    return unitOfWork;
//}

- (void)queue:(id)unitOfWork {
    [queueLock lockWhenCondition:kQueueReady];
    [queue addObject:unitOfWork];
    [queueLock unlockWithCondition:([queue count] >= _maxSize ? kQueueFull : kQueueReady)];
}

@end
