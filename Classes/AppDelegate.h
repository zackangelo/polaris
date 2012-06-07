//
//  AppDelegate.h
//  Polaris
//
//  Created by Zachary Angelo on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MainViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> { 
    @private
    MainViewController *_mainViewCo;
    
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray *videoStreams;

@end
