//
//  DataFetcher.h
//  polaris
//
//  Created by Zachary Angelo on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DataResponseBlock)(NSDictionary *d);

@interface DataFetcher : NSObject { 
    @private
    BOOL _isFetching;
    NSMutableURLRequest *_request;
    NSURLConnection *_conn;
    NSMutableData *_data;
    
    NSInteger _responseStatusCode;
}

@property(copy,nonatomic) DataResponseBlock responseBlock;

- (void) startFetching; 
- (void) stopFetching; 

@end
