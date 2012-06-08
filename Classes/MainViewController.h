//
//  MainViewController.h
//  polaris
//
//  Created by Zachary Angelo on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVideoPlayer.h"
#import "VideoStreamTableViewController.h"
#import "DataFetcher.h"

@class VideoStream;

@interface MainViewController : UIViewController { 
    @private
    NSArray *_videoStreams;
    
    VideoStreamTableViewController *_streamTableViewCo;
    UINavigationController *_streamNavCo;
    DataFetcher *_dataFetcher;
    
    NSDictionary *_latestData;
    
    VideoStream *_currentStream;
}


@property (weak, nonatomic) IBOutlet UIScrollView *telemetryScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet PLVideoPlayer *videoPlayer;
@property (weak, nonatomic) IBOutlet UILabel *a1BlockDisp;
@property (weak, nonatomic) IBOutlet UILabel *a1BlockLoad;
@property (weak, nonatomic) IBOutlet UILabel *a2BlockDisp;
@property (weak, nonatomic) IBOutlet UILabel *a2BlockLoad;
@property (weak, nonatomic) IBOutlet UILabel *b1BlockDisp;
@property (weak, nonatomic) IBOutlet UILabel *b1BlockLoad;
@property (weak, nonatomic) IBOutlet UILabel *b2BlockLoad;
@property (weak, nonatomic) IBOutlet UILabel *b2BlockDisp;
@property (weak, nonatomic) IBOutlet UILabel *ca1BlockLoad;
@property (weak, nonatomic) IBOutlet UILabel *ca1BlockDisp;
@property (weak, nonatomic) IBOutlet UILabel *ca2BlockLoad;
@property (weak, nonatomic) IBOutlet UILabel *ca2BlockDisp;
@property (weak, nonatomic) IBOutlet UILabel *cb1BlockLoad;
@property (weak, nonatomic) IBOutlet UILabel *cb1BlockDisp;
@property (weak, nonatomic) IBOutlet UILabel *cb2BlockLoad;
@property (weak, nonatomic) IBOutlet UILabel *cb2BlockDisp;
@property (weak, nonatomic) IBOutlet UILabel *totalLoad;
@property (weak, nonatomic) IBOutlet UILabel *netLoad;
@property (weak, nonatomic) IBOutlet UILabel *t1Perc;
@property (weak, nonatomic) IBOutlet UILabel *t1Deg;
@property (weak, nonatomic) IBOutlet UILabel *t2Perc;
@property (weak, nonatomic) IBOutlet UILabel *t2Deg;
@property (weak, nonatomic) IBOutlet UILabel *t3Perc;
@property (weak, nonatomic) IBOutlet UILabel *t3Deg;
@property (weak, nonatomic) IBOutlet UILabel *t4Perc;
@property (weak, nonatomic) IBOutlet UILabel *t4Deg;
@property (weak, nonatomic) IBOutlet UILabel *t5Perc;
@property (weak, nonatomic) IBOutlet UILabel *t5Deg;
@property (weak, nonatomic) IBOutlet UILabel *t6Perc;
@property (weak, nonatomic) IBOutlet UILabel *t6Deg;
@property (weak, nonatomic) IBOutlet UILabel *t7Perc;
@property (weak, nonatomic) IBOutlet UILabel *t7Deg;
@property (weak, nonatomic) IBOutlet UILabel *t8Perc;
@property (weak, nonatomic) IBOutlet UILabel *t8Deg;


- (void) startReceiving;
- (void) stopReceiving;

@end
