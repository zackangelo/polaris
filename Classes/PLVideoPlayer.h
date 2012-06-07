//
//  PLVideoPlayer.h
//  Polaris
//
//  Created by Zachary Angelo on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "PLVideoDecoder.h"
#import "PLStatusOverlayView.h"

@class PLFrame;

@interface PLVideoPlayer : UIView<PLVideoDecoderDelegate> { 
    @private
    CADisplayLink *_displayLink;
    PLVideoDecoder *_decoder;
    PLFrame *_currentFrame;
    
    PLStatusOverlayView *_statusOverlay; 
    
    BOOL _centerVideo;
    
    double _frameCountStartTime;
    int _framesLastSecond;
    
//    int _frameCounter;
    NSString *_nextUrl;
    
//    CGDataProviderRef _dataProvider;
    
    CAEAGLLayer *_glLayer;
    EAGLContext *_glContext;
    GLuint _glColorBuffer;
    GLuint _glFrameBuffer;
    
    GLint _frameBufferWidth;
    GLint _frameBufferHeight;
    
    
    GLuint _glVertexBuffer;
    GLuint _glTexCoordBuffer;
    
    GLuint _glPositionAttrib;
    GLuint _glTexCoordAttrib;
    
    GLuint _glOrthoUniform;
    
//    GLuint _glFrameTexUniform;    
//    GLuint _glFrameTex;
    
    //image channel texture
    GLuint _glYTexUniform;
    GLuint _glYTex;
    
    GLuint _glUTexUniform;
    GLuint _glUTex;
    
    GLuint _glVTexUniform;
    GLuint _glVTex;
}

@property(assign,nonatomic) BOOL centerVideo;

- (id)initWithFrame:(CGRect)frame;

- (void) playVideoAtUrl:(NSString*)videoUrl;
- (void) renderFrame;
- (void) stop;

@end

