//
//  AppDelegate.m
//  Polaris
//
//  Created by Zachary Angelo on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "VideoStream.h"

#import <libavcodec/avcodec.h>
#import <libavformat/avformat.h>
#import <libswscale/swscale.h>

@implementation AppDelegate

@synthesize videoStreams;
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    libav_test();
    
    VideoStream *vm2stream = [[VideoStream alloc] init];
    vm2stream.url = @"rtsp://video.vbar.com:1935/rtp-live/vb10k-vm2.stream";
    vm2stream.name = @"VM2 Camera";
    
    VideoStream *vm1stream = [[VideoStream alloc] init];
    vm1stream.url = @"rtsp://video.vbar.com:1935/rtp-live/vb10k-vm1.stream";
    vm1stream.name = @"VM1 Camera";
    
    VideoStream *aftGantryStream = [[VideoStream alloc] init];
    aftGantryStream.url = @"rtsp://video.vbar.com:1935/rtp-live/vb10k-aftgantry.stream";
    aftGantryStream.name = @"Aft Gantry Camera";
    
    VideoStream *bowGantryStream = [[VideoStream alloc] init];
    bowGantryStream.url = @"rtsp://video.vbar.com:1935/rtp-live/vb10k-bowgantry.stream";
    bowGantryStream.name = @"Bow Gantry Camera";
    
    VideoStream *rov1Stream = [[VideoStream alloc] init];
    rov1Stream.url = @"rtsp://video.vbar.com:1935/rtp-live/rov1.stream";
    rov1Stream.name = @"Oceaneering MIL20 ROV";
    
    VideoStream *rov2Stream = [[VideoStream alloc] init];
    rov2Stream.url = @"rtsp://video.vbar.com:1935/rtp-live/rov2.stream";
    rov2Stream.name = @"Oceaneering MAG ROV";
    
    self.videoStreams = [NSArray arrayWithObjects:vm2stream, vm1stream, aftGantryStream, bowGantryStream, rov1Stream, rov2Stream, nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
//    
//    MainViewController *mainViewCo = [[MainViewController alloc] init];
//    
//    self.window.rootViewController = mainViewCo;

//    VideoStreamViewController *videoStreamViewCo = [[VideoStreamViewController alloc] init];
//    
//    self.window.rootViewController = videoStreamViewCo;
//    [self.window makeKeyAndVisible];
    
    
    _mainViewCo = [[MainViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *navCo = [[UINavigationController alloc] initWithRootViewController:_mainViewCo];
    
    self.window.rootViewController = navCo;
    [self.window makeKeyAndVisible];
    
    [_mainViewCo startReceiving];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    NSLog(@"Application will resign active, stopping data and video.");
    [_mainViewCo stopReceiving];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"Application resuming, starting data and video.");
    [_mainViewCo startReceiving];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"Application will terminate, stopping data and video.");
    
}

@end
