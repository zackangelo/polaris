//
//  VideoStreamTableViewController.h
//  polaris
//
//  Created by Zachary Angelo on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoStream.h"

typedef void (^StreamSelectBlock)(VideoStream *stream);
typedef void (^StreamCancelBlock)();

@interface VideoStreamTableViewController : UITableViewController { 
    @private
    NSArray *_videoStreams;
}

@property(copy,nonatomic) StreamSelectBlock selectBlock;
@property(copy,nonatomic) StreamCancelBlock cancelBlock;

@end
