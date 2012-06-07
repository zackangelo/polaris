//
//  PLStatusOverlayView.h
//  polaris
//
//  Created by Zachary Angelo on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLStatusOverlayView : UIView { 
    @private
    UILabel *_overlayLabel;
    UIActivityIndicatorView *_activity;
    UIColor *_overlayColor;
}


@end
