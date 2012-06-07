//
//  PLBufferPool.m
//  Polaris
//
//  Created by Zachary Angelo on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PLPixelBufferPool.h"

@implementation PLPixelBufferPoolEntry 

- (id) init { 
    self = [super init];
    return self;
}

@end

@implementation PLPixelBufferPool

- (id) initWithPoolSize:(int)poolSize { 
    self = [super init];
    
    if(self) { 
        _bufferSize = 0;
        _poolSize = poolSize;
        _pool = [[NSMutableArray alloc] initWithCapacity:poolSize];
    }
    
    return self;
}

- (void) allocatePoolWithSize:(size_t)bufferSize; { 
    for(int i=0;i<_poolSize;i++) { 
        PLPixelBufferPoolEntry *e = [[PLPixelBufferPoolEntry alloc] init];
        e->ptr = malloc(bufferSize);
        e->available = YES;
        
        [_pool addObject:e];
    }   
    
    _bufferSize = bufferSize;
}

- (u_int8_t*)requestBufferOfSize:(size_t)bufferSize {
    if(_bufferSize == 0) { 
        NSLog(@"Allocating buffer pool of size %zu",bufferSize);
        [self allocatePoolWithSize:bufferSize];
    }
    
    if(bufferSize != _bufferSize) { 
        NSLog(@"Attempted to request a buffer from a pool with a different size already set.");
        return 0;
    }
    
    for(PLPixelBufferPoolEntry *e in _pool) { 
        if(e->available) { 
            e->available = NO;
            return e->ptr;
        }
    }
    
    return 0;
}

- (void) returnBuffer:(u_int8_t*) buffer { 
    for(PLPixelBufferPoolEntry *e in _pool) { 
        if(e->ptr == buffer) {
            e->available = YES;
            return;
        }
    }
}

- (void) dealloc { 
    NSLog(@"Deallocating buffer pool...");
    for(PLPixelBufferPoolEntry *e in _pool) { 
        free(e->ptr);
    }
}

@end
