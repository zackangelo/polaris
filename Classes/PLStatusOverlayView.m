//
//  PLStatusOverlayView.m
//  polaris
//
//  Created by Zachary Angelo on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PLStatusOverlayView.h"

@implementation PLStatusOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _overlayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
        _overlayColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        _overlayLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _overlayLabel.text = @"Buffering...";
        _overlayLabel.textColor = [UIColor whiteColor];
        _overlayLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_overlayLabel];
        [self addSubview:_activity];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
}

- (void)drawRect:(CGRect)rect
{
    [_overlayColor setFill];
//    UIRectFill(self.frame);
}


@end
