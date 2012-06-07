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
    };
    
    self.telemetryScrollView.contentSize = CGSizeMake(320 * 2,90);
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
