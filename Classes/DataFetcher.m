//
//  DataFetcher.m
//  polaris
//
//  Created by Zachary Angelo on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataFetcher.h"
#import "NSObject+SBJson.h"

@implementation DataFetcher

@synthesize responseBlock;

- (id) init { 
    self = [super init];
    
    if(self) { 
        _isFetching = NO;
        
        _request = [NSMutableURLRequest requestWithURL:
                                               [NSURL URLWithString:@"http://vb10k.vbar.com/api/rest/VesselDataLatest"]];
        
    }
    
    return self;
}

- (void) startFetching { 
    _isFetching = YES;
    [self fetchNext];
}

- (void) fetchNext { 
    _conn = [NSURLConnection connectionWithRequest:_request delegate:self];
    
    if(_conn) { 
        _data = [NSMutableData data];        
    } else {
        NSLog(@"%@: Connection creation failed.",NSStringFromClass([self class]));
    }
}


- (void) stopFetching { 
    _isFetching = NO;
}


// Connection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    _responseStatusCode = httpResponse.statusCode;
    [_data setLength: 0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)receivedData
{
    [_data appendData:receivedData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // receivedData is declared as a method instance elsewhere
    _data = nil;
    
    NSLog(@"%@: Connection failed! Error - %@ %@",
          NSStringFromClass([self class]),
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{    
    NSString *dataString = 
    [[NSString alloc] initWithBytes:[_data bytes] 
                             length:[_data length] 
                           encoding:NSUTF8StringEncoding];
    
    _data = nil;

    if(_responseStatusCode == 200) { 
        
        
        
        if([dataString length] > 0) { 
            
            NSDictionary *responseMap = [dataString JSONValue];
              
            NSArray *dataArray = [responseMap objectForKey:@"data"];
            NSDictionary *latestData = [dataArray objectAtIndex:0];
                        
            if(self.responseBlock) { 
                self.responseBlock(latestData);
            }
            
            _conn = nil;
            
            if(_isFetching) { 
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self fetchNext];
                });
            }
        }       
    } else { 
        NSLog(@"%@: Request failed, status code: %i",NSStringFromClass([self class]),_responseStatusCode);
    }
}


@end
