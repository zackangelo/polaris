//
//  PLBufferPool.h
//  Polaris
//
//  Created by Zachary Angelo on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLPixelBufferPoolEntry : NSObject { 
    @public
    u_int8_t *ptr;
    BOOL available;
}

@end

@interface PLPixelBufferPool : NSObject  { 
    @private
    NSMutableArray *_pool;
    size_t _bufferSize;
    int _poolSize;
}

- (id) initWithPoolSize:(int)poolSize;
- (u_int8_t*)requestBufferOfSize:(size_t)bufferSize;
- (void) returnBuffer:(u_int8_t*)buffer;

@end
