//
//  PLVideoDecoderDelegate.h
//  polaris
//
//  Created by Zachary Angelo on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLVideoDecoder;

@protocol PLVideoDecoderDelegate <NSObject>

- (void) connectionDidFail;
- (void) videoDecoder:(PLVideoDecoder*)aDecoder didChangeWidth:(int)width height:(int)height;
- (void) videoDecoderDidStop:(PLVideoDecoder*)aDecoder;
- (void) videoDecoderDidStartPlaying:(PLVideoDecoder*)aDecoder;

//- (void) videoIsLoading:(PLVideoDecoder*)aDecoder;
//- (void) videoIsPaused:(PLVideoDecoder*)aDecoder;
//- (void) videoIsPlaying:(PLVideoDecoder*)aDecoder;
//- (void) videoIsStopped:(PLVideoDecoder*)aDecoder;

@end
