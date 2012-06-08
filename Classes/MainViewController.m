//
//  MainViewController.m
//  polaris
//
//  Created by Zachary Angelo on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "VideoStream.h"
#import "AppDelegate.h"

static NSNumberFormatter *numFormat;
static NSNumberFormatter *percFormat;

@implementation MainViewController
@synthesize telemetryScrollView;
@synthesize pageControl;
@synthesize videoPlayer;
@synthesize a1BlockDisp = _a1BlockDisp;
@synthesize a1BlockLoad = _a1BlockLoad;
@synthesize a2BlockDisp = _a2BlockDisp;
@synthesize a2BlockLoad = _a2BlockLoad;
@synthesize b1BlockDisp = _b1BlockDisp;
@synthesize b1BlockLoad = _b1BlockLoad;
@synthesize b2BlockLoad = _b2BlockLoad;
@synthesize b2BlockDisp = _b2BlockDisp;
@synthesize ca1BlockLoad = _ca1BlockLoad;
@synthesize ca1BlockDisp = _ca1BlockDisp;
@synthesize ca2BlockLoad = _ca2BlockLoad;
@synthesize ca2BlockDisp = _ca2BlockDisp;
@synthesize cb1BlockLoad = _cb1BlockLoad;
@synthesize cb1BlockDisp = _cb1BlockDisp;
@synthesize cb2BlockLoad = _cb2BlockLoad;
@synthesize cb2BlockDisp = _cb2BlockDisp;
@synthesize totalLoad = _totalLoad;
@synthesize netLoad = _netLoad;
@synthesize t1Perc = _t1Perc;
@synthesize t1Deg = _t1Deg;
@synthesize t2Perc = _t2Perc;
@synthesize t2Deg = _t2Deg;
@synthesize t3Perc = _t3Perc;
@synthesize t3Deg = _t3Deg;
@synthesize t4Perc = _t4Perc;
@synthesize t4Deg = _t4Deg;
@synthesize t5Perc = _t5Perc;
@synthesize t5Deg = _t5Deg;
@synthesize t6Perc = _t6Perc;
@synthesize t6Deg = _t6Deg;
@synthesize t7Perc = _t7Perc;
@synthesize t7Deg = _t7Deg;
@synthesize t8Perc = _t8Perc;
@synthesize t8Deg = _t8Deg;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Polaris";
        
        if(!numFormat) { 
            numFormat = [[NSNumberFormatter alloc] init];
            numFormat.numberStyle = NSNumberFormatterNoStyle;
        }
        
        if(!percFormat) { 
            percFormat = [[NSNumberFormatter alloc] init];
            percFormat.numberStyle = NSNumberFormatterPercentStyle;
        }
        
        AppDelegate *app = [UIApplication sharedApplication].delegate;
        _videoStreams = app.videoStreams;
        
        if(_videoStreams && [_videoStreams count]) { 
            _currentStream = [_videoStreams objectAtIndex:0];
        }
        
        _dataFetcher = [[DataFetcher alloc] init];
    }
    return self;
}

- (void)viewDidDisappear:(BOOL)animated { 
    NSLog(@"View did disappear.");
}

- (void) didPressStreams:(id)sender { 
    [self presentModalViewController:_streamNavCo animated:YES];
}

- (void) setLoadValue:(NSDecimalNumber *)n forLabel:(UILabel*)label { 
    label.text = [[numFormat stringFromNumber:n] stringByAppendingString:@" tons"];
}

- (void) setDispValue:(NSDecimalNumber *)n forLabel:(UILabel*)label { 
    label.text = [[numFormat stringFromNumber:n] stringByAppendingString:@" ft"];
}

- (void) setPercentValue:(NSDecimalNumber *)n forLabel:(UILabel*)label { 
    label.text = [[numFormat stringFromNumber:n] stringByAppendingString:@"%"];
}

- (void) setAngleValue:(NSDecimalNumber *)n forLabel:(UILabel *)label { 
    label.text = [[numFormat stringFromNumber:n] stringByAppendingString:@"\u00B0"];
}

- (void)updateData { 
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _streamTableViewCo = [[VideoStreamTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    _streamNavCo = [[UINavigationController alloc] initWithRootViewController:_streamTableViewCo];
    
    __weak MainViewController *weakSelf = self;
    
    _streamTableViewCo.selectBlock = ^(VideoStream *stream) { 
        weakSelf->_currentStream = stream;
        
        [weakSelf.videoPlayer playVideoAtUrl:stream.url];
        [weakSelf dismissModalViewControllerAnimated:YES];
    };
    
    _streamTableViewCo.cancelBlock = ^ { 
        [weakSelf dismissModalViewControllerAnimated:YES];
    };
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Streams" style:UIBarButtonItemStylePlain target:self action:@selector(didPressStreams:)];
    
    _dataFetcher.responseBlock = ^(NSDictionary *d) { 
        [weakSelf setLoadValue:[d objectForKey:@"a1Load"] forLabel:weakSelf->_a1BlockLoad];
        [weakSelf setDispValue:[d objectForKey:@"a1Disp"] forLabel:weakSelf->_a1BlockDisp];
        [weakSelf setLoadValue:[d objectForKey:@"a2Load"] forLabel:weakSelf->_a2BlockLoad];
        [weakSelf setDispValue:[d objectForKey:@"a2Disp"] forLabel:weakSelf->_a2BlockDisp];
        
        [weakSelf setLoadValue:[d objectForKey:@"b1Load"] forLabel:weakSelf->_b1BlockLoad];
        [weakSelf setDispValue:[d objectForKey:@"b1Disp"] forLabel:weakSelf->_b1BlockDisp];
        [weakSelf setLoadValue:[d objectForKey:@"b2Load"] forLabel:weakSelf->_b2BlockLoad];
        [weakSelf setDispValue:[d objectForKey:@"b2Disp"] forLabel:weakSelf->_b2BlockDisp]; 
        
        [weakSelf setLoadValue:[d objectForKey:@"a1cLoad"] forLabel:weakSelf->_ca1BlockLoad];
        [weakSelf setDispValue:[d objectForKey:@"a1cDisp"] forLabel:weakSelf->_ca1BlockDisp];
        [weakSelf setLoadValue:[d objectForKey:@"a2cLoad"] forLabel:weakSelf->_ca2BlockLoad];
        [weakSelf setDispValue:[d objectForKey:@"a2cDisp"] forLabel:weakSelf->_ca2BlockDisp];
        
        [weakSelf setLoadValue:[d objectForKey:@"b1cLoad"] forLabel:weakSelf->_cb1BlockLoad];
        [weakSelf setDispValue:[d objectForKey:@"b1cDisp"] forLabel:weakSelf->_cb1BlockDisp];
        [weakSelf setLoadValue:[d objectForKey:@"b2cLoad"] forLabel:weakSelf->_cb2BlockLoad];
        [weakSelf setDispValue:[d objectForKey:@"b2cDisp"] forLabel:weakSelf->_cb2BlockDisp]; 
        
        double a1Load = [[d objectForKey:@"a1Load"] doubleValue];
        double a2Load = [[d objectForKey:@"a2Load"] doubleValue];
        double b1Load = [[d objectForKey:@"b1Load"] doubleValue];
        double b2Load = [[d objectForKey:@"b2Load"] doubleValue];
        
        NSDecimalNumber *totalLoad = [[NSDecimalNumber alloc] initWithDouble:a1Load+a2Load+b1Load+b2Load];
        
        double gaNetLoad = [[d objectForKey:@"gaNetLoad"] doubleValue];
        double gbNetLoad = [[d objectForKey:@"gbNetLoad"] doubleValue];
        
        NSDecimalNumber *netLoad = [[NSDecimalNumber alloc] initWithDouble:gaNetLoad+gbNetLoad];
        
        [weakSelf setLoadValue:totalLoad forLabel:weakSelf->_totalLoad];
        [weakSelf setLoadValue:netLoad forLabel:weakSelf->_netLoad];
        
        [weakSelf setAngleValue:[d objectForKey:@"t1deg"] forLabel:weakSelf->_t1Deg];
        [weakSelf setAngleValue:[d objectForKey:@"t2deg"] forLabel:weakSelf->_t2Deg];
        [weakSelf setAngleValue:[d objectForKey:@"t3deg"] forLabel:weakSelf->_t3Deg];
        [weakSelf setAngleValue:[d objectForKey:@"t4deg"] forLabel:weakSelf->_t4Deg];
        [weakSelf setAngleValue:[d objectForKey:@"t5deg"] forLabel:weakSelf->_t5Deg];
        [weakSelf setAngleValue:[d objectForKey:@"t6deg"] forLabel:weakSelf->_t6Deg];
        [weakSelf setAngleValue:[d objectForKey:@"t7deg"] forLabel:weakSelf->_t7Deg];
        [weakSelf setAngleValue:[d objectForKey:@"t8deg"] forLabel:weakSelf->_t8Deg];
        
        [weakSelf setPercentValue:[d objectForKey:@"t1perc"] forLabel:weakSelf->_t1Perc];
        [weakSelf setPercentValue:[d objectForKey:@"t2perc"] forLabel:weakSelf->_t2Perc];
        [weakSelf setPercentValue:[d objectForKey:@"t3perc"] forLabel:weakSelf->_t3Perc];
        [weakSelf setPercentValue:[d objectForKey:@"t4perc"] forLabel:weakSelf->_t4Perc];
        [weakSelf setPercentValue:[d objectForKey:@"t5perc"] forLabel:weakSelf->_t5Perc];
        [weakSelf setPercentValue:[d objectForKey:@"t6perc"] forLabel:weakSelf->_t6Perc];
        [weakSelf setPercentValue:[d objectForKey:@"t7perc"] forLabel:weakSelf->_t7Perc];
        [weakSelf setPercentValue:[d objectForKey:@"t8perc"] forLabel:weakSelf->_t8Perc];
    };
    
    self.telemetryScrollView.contentSize = CGSizeMake(320 * 3,90);
//    [self.videoPlayer playVideoAtUrl:@"rtsp://video.vbar.com:1935/rtp-live/vb10k-vm2.stream"];
}

- (void)viewDidUnload
{
    [self.videoPlayer stop];
    
    [self setPageControl:nil];
    [self setVideoPlayer:nil];
    [self setA1BlockDisp:nil];
    [self setA1BlockLoad:nil];
    [self setA2BlockDisp:nil];
    [self setA2BlockLoad:nil];
    [self setB1BlockDisp:nil];
    [self setB1BlockLoad:nil];
    [self setB2BlockLoad:nil];
    [self setB2BlockDisp:nil];
    [self setCa1BlockLoad:nil];
    [self setCa1BlockDisp:nil];
    [self setCa2BlockLoad:nil];
    [self setCa2BlockDisp:nil];
    [self setCb1BlockLoad:nil];
    [self setCb1BlockDisp:nil];
    [self setCb2BlockLoad:nil];
    [self setCb2BlockDisp:nil];
    [self setTotalLoad:nil];
    [self setNetLoad:nil];
    [self setT1Perc:nil];
    [self setT1Deg:nil];
    [self setT2Perc:nil];
    [self setT2Deg:nil];
    [self setT3Perc:nil];
    [self setT3Deg:nil];
    [self setT4Perc:nil];
    [self setT4Deg:nil];
    [self setT5Perc:nil];
    [self setT5Deg:nil];
    [self setT6Perc:nil];
    [self setT6Deg:nil];
    [self setT7Perc:nil];
    [self setT7Deg:nil];
    [self setT8Perc:nil];
    [self setT8Deg:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.telemetryScrollView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) stopReceiving { 
    [_dataFetcher stopFetching];
    [self.videoPlayer stop];
}

- (void) startReceiving { 
    [_dataFetcher startFetching];
    if(_currentStream) {
        [self.videoPlayer playVideoAtUrl:_currentStream.url];
    }
}


#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.telemetryScrollView.frame.size.width;
    int page = floor((self.telemetryScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}


@end
